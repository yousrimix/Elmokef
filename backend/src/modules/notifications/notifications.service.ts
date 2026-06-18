import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { FcmService } from './fcm.service';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    private prisma: PrismaService,
    private fcm: FcmService,
  ) {}

  async registerDevice(userId: string, dto: { fcmToken: string; platform?: string }) {
    const existing = await this.prisma.device.findUnique({ where: { token: dto.fcmToken } });
    if (existing) {
      if (existing.userId !== userId) {
        await this.prisma.device.update({ where: { id: existing.id }, data: { userId, isActive: true } });
      }
      return { registered: true, deviceId: existing.id };
    }
    const device = await this.prisma.device.create({
      data: { userId, token: dto.fcmToken, platform: dto.platform || 'unknown' },
    });
    return { registered: true, deviceId: device.id };
  }

  async unregisterDevice(userId: string, token: string) {
    const device = await this.prisma.device.findUnique({ where: { token } });
    if (!device) return { deleted: false, reason: 'الجهاز غير مسجل' };
    if (device.userId !== userId) throw new BadRequestException('هذا الجهاز لا يخصك');
    await this.prisma.device.update({ where: { id: device.id }, data: { isActive: false } });
    return { deleted: true };
  }

  async listNotifications(userId: string, cursor?: string, limit = 50) {
    const where: any = { userId };
    if (cursor) {
      const decoded = Buffer.from(cursor, 'base64').toString('utf-8');
      where.createdAt = { lt: new Date(decoded) };
    }
    const notifications = await this.prisma.notification.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: limit + 1,
    });
    const hasMore = notifications.length > limit;
    if (hasMore) notifications.pop();
    const nextCursor = hasMore && notifications.length
      ? Buffer.from(notifications[notifications.length - 1].createdAt.toISOString()).toString('base64')
      : null;
    return { data: notifications, nextCursor, hasMore };
  }

  async markAsRead(notificationId: string, userId: string) {
    const notification = await this.prisma.notification.findUnique({ where: { id: notificationId } });
    if (!notification) throw new NotFoundException('الإشعار غير موجود');
    if (notification.userId !== userId) throw new BadRequestException('هذا الإشعار لا يخصك');
    const updated = await this.prisma.notification.update({
      where: { id: notificationId },
      data: { isRead: true },
    });
    return updated;
  }

  async createAndSend(userId: string, title: string, body: string, data?: Record<string, any>) {
    const notification = await this.prisma.notification.create({
      data: { userId, title, body, data: data || {} },
    });
    const devices = await this.prisma.device.findMany({ where: { userId, isActive: true } });
    const tokens = devices.map((d) => d.token);
    if (tokens.length > 0) {
      this.fcm.sendToMultipleDevices(tokens, {
        title,
        body,
        data: data ? Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])) : undefined,
      });
    }
    return notification;
  }

  async sendToAllArtisans(title: string, body: string, data?: Record<string, any>) {
    const artisans = await this.prisma.user.findMany({
      where: { role: 'ARTISAN', isActive: true },
      select: { id: true },
    });
    const notifications = await Promise.all(
      artisans.map((a) =>
        this.prisma.notification.create({
          data: { userId: a.id, title, body, data: data || {} },
        }),
      ),
    );
    const devices = await this.prisma.device.findMany({
      where: { user: { role: 'ARTISAN', isActive: true }, isActive: true },
    });
    const tokens = [...new Set(devices.map((d) => d.token))];
    if (tokens.length > 0) {
      this.fcm.sendToMultipleDevices(tokens, {
        title,
        body,
        data: data ? Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])) : undefined,
      });
    }
    return { sent: notifications.length, pushDevices: tokens.length };
  }
}
