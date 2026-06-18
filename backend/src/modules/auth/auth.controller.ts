import { Controller, Post, Get, Body, Req, Res, UseGuards, UnauthorizedException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import type { Response, Request } from 'express';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { SendOtpDto, VerifyOtpDto, OAuthLoginDto } from './dto/auth.dto';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'تسجيل مستخدم جديد (دور عميل فقط — ADMIN ممنوع)' })
  async register(@Body() dto: RegisterDto, @Res({ passthrough: true }) res: Response) {
    const result = await this.authService.register(dto);
    this.setRefreshCookie(res, result.refreshToken);
    return result;
  }

  @Post('register/artisan')
  @ApiOperation({ summary: 'تسجيل حساب حرفي جديد' })
  async registerArtisan(@Body() dto: RegisterDto, @Res({ passthrough: true }) res: Response) {
    const result = await this.authService.registerAsArtisan(dto);
    this.setRefreshCookie(res, result.refreshToken);
    return result;
  }

  @Post('login')
  @ApiOperation({ summary: 'تسجيل الدخول (Email/Phone)' })
  async login(@Body() dto: LoginDto, @Res({ passthrough: true }) res: Response) {
    const result = await this.authService.login(dto);
    this.setRefreshCookie(res, result.refreshToken);
    return result;
  }

  @Post('refresh')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'تجديد رمز الوصول عبر Refresh Token (Cookie فقط)' })
  async refreshToken(@Req() req: Request, @Res({ passthrough: true }) res: Response) {
    const token = req.cookies?.refreshToken;
    if (!token) throw new UnauthorizedException('رمز التحديث غير موجود — يجب إرسال Cookie');
    const result = await this.authService.refreshToken(token);
    this.setRefreshCookie(res, result.refreshToken);
    return result;
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'تسجيل الخروج وإبطال جميع Refresh Tokens' })
  async logout(@Req() req: any, @Res({ passthrough: true }) res: Response) {
    const result = await this.authService.logout(req.user.id);
    res.clearCookie('refreshToken', { path: '/api/v1/auth' });
    return result;
  }

  @Post('oauth')
  @ApiOperation({ summary: 'تسجيل الدخول عبر OAuth (Google/Facebook) — مع verifyIdToken' })
  async oauthLogin(@Body() dto: OAuthLoginDto, @Res({ passthrough: true }) res: Response) {
    const result = await this.authService.oauthLogin(dto);
    this.setRefreshCookie(res, result.refreshToken);
    return result;
  }

  @Post('otp/send')
  @ApiOperation({ summary: 'إرسال رمز تحقق عبر SMS (Phone OTP)' })
  async sendOtp(@Body() dto: SendOtpDto) {
    return this.authService.sendOtp(dto.phone);
  }

  @Post('otp/verify')
  @ApiOperation({ summary: 'التحقق من رمز OTP وتسجيل الدخول' })
  async verifyOtp(@Body() dto: VerifyOtpDto, @Res({ passthrough: true }) res: Response) {
    const result = await this.authService.verifyOtp(dto.phone, dto.code);
    this.setRefreshCookie(res, result.refreshToken);
    return result;
  }

  @Get('profile')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'الملف الشخصي للمستخدم الحالي' })
  getProfile(@Req() req: any) {
    return this.authService.getProfile(req.user.id);
  }

  private setRefreshCookie(res: Response, token: string) {
    res.cookie('refreshToken', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      path: '/api/v1/auth',
      maxAge: 7 * 24 * 60 * 60 * 1000,
    });
  }
}
