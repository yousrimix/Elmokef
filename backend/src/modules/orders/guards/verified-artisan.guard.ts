import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';

/**
 * يسمح فقط للحرفيين الموثّقين (ArtisanProfile.isVerified = true) بتنفيذ الإجراء
 * يُستخدم لحماية endpoints التي تتعلق باستقبال الطلبات
 */
@Injectable()
export class VerifiedArtisanGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest();
    const userId = req.user?.id;

    if (!userId) {
      throw new ForbiddenException('غير مصرّح');
    }

    const profile = await this.prisma.artisanProfile.findUnique({
      where: { userId },
      select: { isVerified: true },
    });

    if (!profile || !profile.isVerified) {
      throw new ForbiddenException('فقط الحرفيين الموثّقين يمكنهم استقبال الطلبات');
    }

    return true;
  }
}
