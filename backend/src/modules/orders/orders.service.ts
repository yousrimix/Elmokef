import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { OrderStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { OrdersGateway } from './orders.gateway';

@Injectable()
export class OrdersService {
  private readonly logger = new Logger(OrdersService.name);

  // مسموح بالانتقالات الآمنة للحالات
  private readonly allowedTransitions: Record<OrderStatus, OrderStatus[]> = {
    [OrderStatus.PENDING]: [OrderStatus.ACCEPTED, OrderStatus.DECLINED, OrderStatus.CANCELLED],
    [OrderStatus.ACCEPTED]: [OrderStatus.IN_PROGRESS, OrderStatus.CANCELLED],
    [OrderStatus.IN_PROGRESS]: [OrderStatus.COMPLETED, OrderStatus.CANCELLED],
    [OrderStatus.DECLINED]: [],
    [OrderStatus.COMPLETED]: [],
    [OrderStatus.CANCELLED]: [],
  };

  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
    private ordersGateway: OrdersGateway,
  ) {}

  /**
   * POST /orders — العميل ينشئ طلب خدمة
   */
  async create(
    clientId: string,
    dto: {
      artisanId: string;
      serviceId: string;
      description?: string;
      location?: { lat: number; lng: number };
      budget?: number;
      scheduledDate?: string;
    },
  ) {
    // التحقق من وجود الحرفي والخدمة
    const [artisan, service] = await Promise.all([
      this.prisma.artisanProfile.findUnique({
        where: { userId: dto.artisanId },
        include: { user: { select: { id: true, name: true, image: true, phone: true } } },
      }),
      this.prisma.service.findUnique({ where: { id: dto.serviceId } }),
    ]);

    if (!artisan) throw new NotFoundException('الحرفي غير موجود');
    if (!artisan.isVerified) throw new BadRequestException('الحرفي غير موثّق ولا يمكنه استقبال الطلبات حالياً');
    if (!service) throw new NotFoundException('الخدمة غير موجودة');

    // التحقق من أن الحرفي يقدم هذه الخدمة فعلاً
    const artisanService = await this.prisma.artisanService.findUnique({
      where: { artisanId_serviceId: { artisanId: dto.artisanId, serviceId: dto.serviceId } },
    });
    if (!artisanService) throw new BadRequestException('الحرفي لا يقدم هذه الخدمة');

    // إنشاء الطلب
    const order = await this.prisma.order.create({
      data: {
        clientId,
        artisanId: dto.artisanId,
        serviceId: dto.serviceId,
        description: dto.description || null,
        location: dto.location ? (dto.location as any) : null,
        budget: dto.budget ? new Prisma.Decimal(dto.budget) : null,
        scheduledDate: dto.scheduledDate ? new Date(dto.scheduledDate) : null,
      },
      include: {
        client: { select: { id: true, name: true, image: true, phone: true } },
        artisan: { select: { id: true, name: true, image: true, phone: true } },
        service: { select: { id: true, nameAr: true, nameFr: true } },
      },
    });

    // إرسال إشعار للحرفي عبر WebSocket
    this.ordersGateway.notifyNewOrder(order, {
      artisanName: artisan.user.name,
      artisanImage: artisan.user.image,
    });

    // إرسال إشعار Push (FCM)
    this.notificationsService.createAndSend(
      dto.artisanId,
      '📩 طلب خدمة جديد',
      `لديك طلب جديد لخدمة "${service.nameAr}" من ${order.client.name}`,
      { type: 'new_order', orderId: order.id },
    );

    // تحديث totalOrders للحرفي
    await this.prisma.artisanProfile.update({
      where: { userId: dto.artisanId },
      data: { totalOrders: { increment: 1 } },
    });

    this.logger.log(`📦 Order created: ${order.id} — client=${clientId} artisan=${dto.artisanId}`);
    return order;
  }

  /**
   * GET /orders/client — طلبات العميل
   */
  async findByClient(
    clientId: string,
    query: { status?: OrderStatus; cursor?: string; limit?: number },
  ) {
    const limit = query.limit || 20;
    const where: any = { clientId, deletedAt: null };

    if (query.status) {
      where.status = query.status;
    }

    if (query.cursor) {
      const decoded = Buffer.from(query.cursor, 'base64').toString('utf-8');
      where.createdAt = { lt: new Date(decoded) };
    }

    const orders = await this.prisma.order.findMany({
      where,
      include: {
        artisan: { select: { id: true, name: true, image: true, phone: true } },
        service: { select: { id: true, nameAr: true, nameFr: true, icon: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: limit + 1,
    });

    const hasMore = orders.length > limit;
    const items = hasMore ? orders.slice(0, limit) : orders;
    const nextCursor = hasMore
      ? Buffer.from(items[items.length - 1].createdAt.toISOString()).toString('base64')
      : null;

    return { data: items, nextCursor, hasMore };
  }

  /**
   * GET /orders/artisan — طلبات الحرفي (الواردة)
   */
  async findByArtisan(
    artisanId: string,
    query: { status?: OrderStatus; cursor?: string; limit?: number },
  ) {
    const limit = query.limit || 20;
    const where: any = { artisanId, deletedAt: null };

    if (query.status) {
      where.status = query.status;
    }

    if (query.cursor) {
      const decoded = Buffer.from(query.cursor, 'base64').toString('utf-8');
      where.createdAt = { lt: new Date(decoded) };
    }

    const orders = await this.prisma.order.findMany({
      where,
      include: {
        client: { select: { id: true, name: true, image: true, phone: true } },
        service: { select: { id: true, nameAr: true, nameFr: true, icon: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: limit + 1,
    });

    const hasMore = orders.length > limit;
    const items = hasMore ? orders.slice(0, limit) : orders;
    const nextCursor = hasMore
      ? Buffer.from(items[items.length - 1].createdAt.toISOString()).toString('base64')
      : null;

    return { data: items, nextCursor, hasMore };
  }

  /**
   * GET /orders/:id — تفاصيل الطلب
   */
  async findOne(id: string, userId: string, userRole: string) {
    const order = await this.prisma.order.findFirst({
      where: { id, deletedAt: null },
      include: {
        client: { select: { id: true, name: true, image: true, phone: true } },
        artisan: { select: { id: true, name: true, image: true, phone: true } },
        service: { select: { id: true, nameAr: true, nameFr: true, icon: true } },
      },
    });

    if (!order) throw new NotFoundException('الطلب غير موجود');

    // السماح بالوصول للعميل، الحرفي، أو المشرف فقط
    if (order.clientId !== userId && order.artisanId !== userId && userRole !== 'ADMIN') {
      throw new ForbiddenException('ليس لديك صلاحية الوصول لهذا الطلب');
    }

    return order;
  }

  /**
   * PATCH /orders/:id/status — تحديث حالة الطلب
   */
  async updateStatus(
    id: string,
    userId: string,
    dto: {
      status: 'ACCEPTED' | 'DECLINED' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';
      declinedReason?: string;
      artisanNote?: string;
    },
  ) {
    const order = await this.prisma.order.findFirst({
      where: { id, deletedAt: null },
      include: {
        client: { select: { id: true, name: true, image: true } },
        artisan: { select: { id: true, name: true, image: true } },
        service: { select: { id: true, nameAr: true } },
      },
    });

    if (!order) throw new NotFoundException('الطلب غير موجود');

    // التحقق من الصلاحية
    const isArtisan = order.artisanId === userId;
    const isClient = order.clientId === userId;

    if (!isArtisan && !isClient) {
      throw new ForbiddenException('ليس لديك صلاحية لتحديث هذا الطلب');
    }

    // قواعد خاصة للطرفين
    if (isClient && dto.status !== 'CANCELLED') {
      throw new ForbiddenException('يمكن للعميل فقط إلغاء الطلب');
    }

    if (dto.status === 'ACCEPTED' && !isArtisan) {
      throw new ForbiddenException('فقط الحرفي يمكنه قبول الطلب');
    }

    if (dto.status === 'IN_PROGRESS' && !isArtisan) {
      throw new ForbiddenException('فقط الحرفي يمكنه بدء العمل');
    }

    if (dto.status === 'COMPLETED' && !isArtisan) {
      throw new ForbiddenException('فقط الحرفي يمكنه تأكيد الإنجاز');
    }

    if (dto.status === 'DECLINED' && !isArtisan) {
      throw new ForbiddenException('فقط الحرفي يمكنه رفض الطلب');
    }

    // التحقق من الانتقال المسموح به
    const allowed = this.allowedTransitions[order.status];
    if (!allowed.includes(dto.status as OrderStatus)) {
      throw new BadRequestException(
        `لا يمكن تغيير الحالة من ${order.status} إلى ${dto.status}`,
      );
    }

    // إذا كان رفضاً، يجب تقديم سبب
    if (dto.status === 'DECLINED' && !dto.declinedReason) {
      throw new BadRequestException('يجب تقديم سبب الرفض');
    }

    // تجهيز بيانات التحديث
    const newStatus: OrderStatus = dto.status as OrderStatus;
    const updateData: any = { status: newStatus };

    if (dto.status === 'DECLINED') {
      updateData.declinedReason = dto.declinedReason;
    }

    if (dto.artisanNote) {
      updateData.artisanNote = dto.artisanNote;
    }

    if (dto.status === 'COMPLETED') {
      updateData.completedAt = new Date();
    }

    // تنفيذ التحديث
    const updatedOrder = await this.prisma.order.update({
      where: { id },
      data: updateData,
      include: {
        client: { select: { id: true, name: true, image: true } },
        artisan: { select: { id: true, name: true, image: true } },
        service: { select: { id: true, nameAr: true, nameFr: true } },
      },
    });

    // إرسال إشعار WebSocket للعميل
    this.ordersGateway.notifyOrderUpdated(updatedOrder);

    // إرسال إشعار Push
    const statusMessages: Record<string, string> = {
      ACCEPTED: 'تم قبول طلبك ✅',
      DECLINED: 'تم رفض الطلب ❌',
      IN_PROGRESS: 'بدأ الحرفي في العمل 🔧',
      COMPLETED: 'تم إنجاز الطلب 🎉',
      CANCELLED: 'تم إلغاء الطلب',
    };

    const notifyUserId = isArtisan ? order.clientId : order.artisanId;
    const notifyTitle = statusMessages[dto.status] || 'تحديث حالة الطلب';
    const notifyBody = isArtisan
      ? `طلب "${order.service.nameAr}" — ${statusMessages[dto.status] || 'تم التحديث'}`
      : `طلب "${order.service.nameAr}" — ${statusMessages[dto.status] || 'تم التحديث'}`;

    this.notificationsService.createAndSend(notifyUserId, notifyTitle, notifyBody, {
      type: 'order_status',
      orderId: order.id,
      status: dto.status,
    });

    this.logger.log(`📋 Order ${id}: ${order.status} → ${dto.status} by user ${userId}`);
    return updatedOrder;
  }

  /**
   * إلغاء الطلب (يمكن للعميل أو الحرفي)
   */
  async cancel(id: string, userId: string) {
    return this.updateStatus(id, userId, { status: 'CANCELLED' });
  }

  /**
   * حذف ناعم للطلب (ADMIN فقط)
   */
  async remove(id: string, userId: string, userRole: string) {
    if (userRole !== 'ADMIN') {
      throw new ForbiddenException('فقط المشرف يمكنه حذف الطلبات');
    }

    const order = await this.prisma.order.findFirst({ where: { id, deletedAt: null } });
    if (!order) throw new NotFoundException('الطلب غير موجود');

    await this.prisma.order.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    return { message: 'تم حذف الطلب' };
  }
}
