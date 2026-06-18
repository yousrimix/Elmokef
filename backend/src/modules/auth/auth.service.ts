import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../prisma/prisma.service';
import { Role } from '@prisma/client';
import { initializeApp, getApps, App } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async register(dto: { name: string; phone: string; email?: string; password: string }) {
    const existingPhone = await this.prisma.user.findUnique({ where: { phone: dto.phone } });
    if (existingPhone) throw new ConflictException('رقم الهاتف مسجل مسبقاً');

    if (dto.email) {
      const existingEmail = await this.prisma.user.findUnique({ where: { email: dto.email } });
      if (existingEmail) throw new ConflictException('البريد الإلكتروني مسجل مسبقاً');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);
    const role = Role.CLIENT;

    const user = await this.prisma.user.create({
      data: {
        name: dto.name,
        phone: dto.phone,
        email: dto.email,
        password: hashedPassword,
        role,
        clientProfile: { create: {} },
      },
    });

    const tokens = await this.generateTokens(user.id, user.phone, user.role);
    await this.storeRefreshToken(user.id, tokens.refreshToken);

    return { user: { id: user.id, name: user.name, phone: user.phone, email: user.email, role: user.role }, ...tokens };
  }

  async registerAsArtisan(dto: { name: string; phone: string; email?: string; password: string }) {
    const existingPhone = await this.prisma.user.findUnique({ where: { phone: dto.phone } });
    if (existingPhone) throw new ConflictException('رقم الهاتف مسجل مسبقاً');

    if (dto.email) {
      const existingEmail = await this.prisma.user.findUnique({ where: { email: dto.email } });
      if (existingEmail) throw new ConflictException('البريد الإلكتروني مسجل مسبقاً');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);

    const user = await this.prisma.user.create({
      data: {
        name: dto.name,
        phone: dto.phone,
        email: dto.email,
        password: hashedPassword,
        role: Role.ARTISAN,
        artisanProfile: { create: {} },
      },
    });

    const tokens = await this.generateTokens(user.id, user.phone, user.role);
    await this.storeRefreshToken(user.id, tokens.refreshToken);

    return { user: { id: user.id, name: user.name, phone: user.phone, email: user.email, role: user.role }, ...tokens };
  }

  async login(dto: { email?: string; phone?: string; password: string }) {
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [{ email: dto.email || '' }, { phone: dto.phone || '' }],
        isActive: true,
        deletedAt: null,
      },
    });

    if (!user || !user.password) throw new UnauthorizedException('بيانات الدخول غير صحيحة');

    const isPasswordValid = await bcrypt.compare(dto.password, user.password);
    if (!isPasswordValid) throw new UnauthorizedException('بيانات الدخول غير صحيحة');

    const tokens = await this.generateTokens(user.id, user.phone, user.role);
    await this.storeRefreshToken(user.id, tokens.refreshToken);

    return { user: { id: user.id, name: user.name, phone: user.phone, email: user.email, role: user.role }, ...tokens };
  }

  async refreshToken(token: string) {
    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');

    const storedToken = await this.prisma.refreshToken.findFirst({
      where: { tokenHash, isRevoked: false, expiresAt: { gt: new Date() } },
      include: { user: true },
    });

    if (!storedToken) throw new UnauthorizedException('رمز التحديث غير صالح أو منتهي');

    await this.prisma.refreshToken.update({ where: { id: storedToken.id }, data: { isRevoked: true } });

    const tokens = await this.generateTokens(storedToken.user.id, storedToken.user.phone, storedToken.user.role);
    await this.storeRefreshToken(storedToken.user.id, tokens.refreshToken);

    return tokens;
  }

  async logout(userId: string) {
    await this.prisma.refreshToken.updateMany({
      where: { userId, isRevoked: false },
      data: { isRevoked: true },
    });
    return { message: 'تم تسجيل الخروج بنجاح' };
  }

  async oauthLogin(dto: { provider: string; token: string; email?: string; name?: string; phone?: string }) {
    const decoded = await this.verifyFirebaseToken(dto.token);
    const email = decoded.email || dto.email;
    if (!email) throw new UnauthorizedException('البريد الإلكتروني مطلوب لتسجيل الدخول عبر OAuth');

    let user = await this.prisma.user.findUnique({ where: { email } });

    if (!user) {
      user = await this.prisma.user.create({
        data: {
          name: dto.name || decoded.name || 'مستخدم جديد',
          phone: dto.phone || `oauth_${Date.now()}`,
          email,
          role: Role.CLIENT,
          isVerified: true,
          clientProfile: { create: {} },
        },
      });
    }

    const tokens = await this.generateTokens(user.id, user.phone, user.role);
    await this.storeRefreshToken(user.id, tokens.refreshToken);

    return { user: { id: user.id, name: user.name, phone: user.phone, email: user.email, role: user.role }, ...tokens };
  }

  async sendOtp(phone: string) {
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    await this.prisma.otpCode.create({ data: { phone, code, expiresAt } });

    const isDev = this.configService.get<string>('OTP_DEV_MODE') === 'true';

    if (isDev) {
      return { message: 'تم إرسال رمز التحقق', code };
    }

    return { message: 'تم إرسال رمز التحقق' };
  }

  async verifyOtp(phone: string, code: string) {
    const otp = await this.prisma.otpCode.findFirst({
      where: { phone, code, isUsed: false, expiresAt: { gt: new Date() } },
    });

    if (!otp) throw new UnauthorizedException('رمز التحقق غير صالح أو منتهي');

    await this.prisma.otpCode.update({ where: { id: otp.id }, data: { isUsed: true } });

    let user = await this.prisma.user.findUnique({ where: { phone } });

    if (!user) {
      user = await this.prisma.user.create({
        data: { name: `مستخدم ${phone.slice(-4)}`, phone, role: Role.CLIENT, isVerified: true, clientProfile: { create: {} } },
      });
    }

    const tokens = await this.generateTokens(user.id, user.phone, user.role);
    await this.storeRefreshToken(user.id, tokens.refreshToken);

    return { user: { id: user.id, name: user.name, phone: user.phone, role: user.role }, ...tokens };
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, name: true, phone: true, email: true, role: true, image: true, isVerified: true, createdAt: true },
    });
    if (!user) throw new UnauthorizedException('المستخدم غير موجود');
    return user;
  }

  private async verifyFirebaseToken(token: string): Promise<any> {
    try {
      if (!getApps().length) {
        initializeApp({ projectId: this.configService.get<string>('FIREBASE_PROJECT_ID') });
      }
      const decoded = await getAuth().verifyIdToken(token);
      const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
      if (decoded.aud !== projectId) {
        throw new UnauthorizedException('معرف التطبيق غير صالح');
      }
      if (decoded.iss !== `https://securetoken.google.com/${projectId}`) {
        throw new UnauthorizedException('مصدر التوكن غير صالح');
      }
      if (!decoded.exp || decoded.exp < Math.floor(Date.now() / 1000)) {
        throw new UnauthorizedException('التوكن منتهي الصلاحية');
      }
      return decoded;
    } catch (err) {
      if (err instanceof UnauthorizedException) throw err;
      throw new UnauthorizedException('رمز OAuth غير صالح أو منتهي الصلاحية');
    }
  }

  private async generateTokens(userId: string, phone: string, role: Role) {
    const payload = { sub: userId, phone, role };

    const accessToken = this.jwtService.sign(payload, {
      secret: process.env.JWT_SECRET || 'super-secret-jwt-key-elmokef-2026',
      expiresIn: (process.env.JWT_EXPIRES_IN || '15m') as any,
    });

    const refreshToken = this.jwtService.sign(payload, {
      secret: process.env.JWT_REFRESH_SECRET || 'super-secret-refresh-key-elmokef-2026',
      expiresIn: (process.env.JWT_REFRESH_EXPIRES_IN || '7d') as any,
    });

    return { accessToken, refreshToken };
  }

  private async storeRefreshToken(userId: string, token: string) {
    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    await this.prisma.refreshToken.create({
      data: { userId, tokenHash, expiresAt },
    });
  }
}
