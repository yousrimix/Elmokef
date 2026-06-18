import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RankingService } from '../ranking/ranking.service';

const PLAN_PRICES = { FREE: 0, PRO: 99, PREMIUM: 199 };
const PLAN_DURATION_DAYS = 30;

@Injectable()
export class SubscriptionsService {
  constructor(
    private prisma: PrismaService,
    private ranking: RankingService,
  ) {}

  getPlans() {
    return [
      { id: 'FREE', name: 'مجاني', price: 0, features: ['ظهور في البحث', 'ملف شخصي'], boost: 1.0 },
      { id: 'PRO', name: 'احترافي', price: 99, features: ['ظهور مميز', 'إحصائيات متقدمة', 'أولوية في الترتيب'], boost: 1.2 },
      { id: 'PREMIUM', name: 'ممتاز', price: 199, features: ['كل مميزات PRO', 'دعم فني 24/7', 'ترتيب أقصى'], boost: 1.5 },
    ];
  }

  async subscribe(artisanId: string, dto: { plan: string; paymentId?: string }) {
    const existing = await this.prisma.subscription.findUnique({ where: { artisanId } });
    const price = PLAN_PRICES[dto.plan as keyof typeof PLAN_PRICES] || 0;
    const endDate = new Date(Date.now() + PLAN_DURATION_DAYS * 24 * 60 * 60 * 1000);

    if (existing && existing.status === 'ACTIVE') {
      throw new BadRequestException('لديك اشتراك نشط حالياً. قم بالترقية أو الإلغاء أولاً.');
    }

    const result = existing
      ? await this.prisma.subscription.update({
          where: { artisanId },
          data: { plan: dto.plan as any, status: 'ACTIVE', startDate: new Date(), endDate, price, autoRenew: true, paymentId: dto.paymentId },
        })
      : await this.prisma.subscription.create({
          data: { artisanId, plan: dto.plan as any, price, endDate, paymentId: dto.paymentId },
        });

    await this.prisma.auditLog.create({
      data: { userId: artisanId, action: `subscription.${existing ? 'renew' : 'create'}`, metadata: { plan: dto.plan, price } },
    });

    this.ranking.recalculateScore(artisanId);
    return result;
  }

  async cancel(artisanId: string, reason?: string) {
    const sub = await this.prisma.subscription.findUnique({ where: { artisanId } });
    if (!sub || sub.status === 'CANCELLED') throw new NotFoundException('لا يوجد اشتراك نشط');

    const result = await this.prisma.subscription.update({
      where: { artisanId },
      data: { status: 'CANCELLED', autoRenew: false },
    });

    await this.prisma.auditLog.create({
      data: { userId: artisanId, action: 'subscription.cancel', metadata: { reason, previousPlan: sub.plan } },
    });

    this.ranking.recalculateScore(artisanId);
    return result;
  }

  async upgrade(artisanId: string, dto: { plan: string }) {
    const sub = await this.prisma.subscription.findUnique({ where: { artisanId } });
    if (!sub || sub.status !== 'ACTIVE') throw new BadRequestException('ليس لديك اشتراك نشط للترقية');

    const currentRank = ['FREE', 'PRO', 'PREMIUM'].indexOf(sub.plan);
    const targetRank = ['FREE', 'PRO', 'PREMIUM'].indexOf(dto.plan);
    if (targetRank <= currentRank) throw new BadRequestException('يمكنك الترقية فقط إلى باقة أعلى');

    const price = PLAN_PRICES[dto.plan as keyof typeof PLAN_PRICES] || 0;
    const endDate = new Date(Date.now() + PLAN_DURATION_DAYS * 24 * 60 * 60 * 1000);

    const result = await this.prisma.subscription.update({
      where: { artisanId },
      data: { plan: dto.plan as any, price, endDate },
    });

    await this.prisma.auditLog.create({
      data: { userId: artisanId, action: 'subscription.upgrade', metadata: { from: sub.plan, to: dto.plan, price } },
    });

    this.ranking.recalculateScore(artisanId);
    return result;
  }

  async getMySubscription(artisanId: string) {
    const sub = await this.prisma.subscription.findUnique({
      where: { artisanId },
      include: { payment: true },
    });
    if (!sub) return { plan: 'FREE', status: 'ACTIVE', autoRenew: false };
    return sub;
  }

  async findAll(query: { status?: string; plan?: string; cursor?: string; limit?: number }) {
    const limit = query.limit || 20;
    const where: any = {};
    if (query.status) where.status = query.status;
    if (query.plan) where.plan = query.plan;

    const subs = await this.prisma.subscription.findMany({
      where,
      include: { artisan: { select: { id: true, name: true, phone: true } }, payment: true },
      orderBy: { createdAt: 'desc' },
      take: limit + 1,
    });

    const hasMore = subs.length > limit;
    const items = hasMore ? subs.slice(0, limit) : subs;
    const nextCursor = hasMore ? Buffer.from(items[items.length - 1].id).toString('base64') : null;

    return { data: items, nextCursor, hasMore };
  }

  async handleWebhook(dto: { transactionId: string; status: string; artisanId: string; amount: number }) {
    const payment = await this.prisma.payment.create({
      data: {
        artisanId: dto.artisanId,
        amount: dto.amount,
        transactionId: dto.transactionId,
        status: dto.status === 'SUCCESS' ? 'COMPLETED' : 'FAILED',
        method: 'CMI',
      },
    });

    if (dto.status === 'SUCCESS') {
      await this.subscribe(dto.artisanId, { plan: 'PRO', paymentId: payment.id });
    }

    return { received: true, paymentId: payment.id };
  }
}
