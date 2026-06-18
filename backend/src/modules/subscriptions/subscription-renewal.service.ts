import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class SubscriptionRenewalService {
  private readonly logger = new Logger(SubscriptionRenewalService.name);

  constructor(private prisma: PrismaService) {}

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async processRenewals() {
    this.logger.log('بدء عملية التجديد التلقائي للاشتراكات...');

    const now = new Date();
    const dayAfter = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    const expiring = await this.prisma.subscription.findMany({
      where: {
        status: 'ACTIVE',
        autoRenew: true,
        endDate: { lte: dayAfter, gte: now },
      },
      include: { artisan: { select: { id: true, name: true } } },
    });

    this.logger.log(`تم العثور على ${expiring.length} اشتراك منتهي خلال 24 ساعة`);

    for (const sub of expiring) {
      try {
        const newEndDate = new Date(sub.endDate!.getTime() + 30 * 24 * 60 * 60 * 1000);
        await this.prisma.subscription.update({
          where: { id: sub.id },
          data: { endDate: newEndDate },
        });

        await this.prisma.auditLog.create({
          data: {
            userId: sub.artisanId,
            action: 'subscription.renew',
            metadata: { subscriptionId: sub.id, plan: sub.plan, newEndDate: newEndDate.toISOString() },
          },
        });

        this.logger.log(`تم تجديد اشتراك ${sub.artisan.name || sub.artisanId}`);
      } catch (err) {
        this.logger.error(`فشل تجديد اشتراك ${sub.artisanId}: ${(err as Error).message}`);
      }
    }

    return { processed: expiring.length };
  }
}
