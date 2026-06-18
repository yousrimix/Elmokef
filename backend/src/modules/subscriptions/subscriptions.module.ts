import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { SubscriptionsController } from './subscriptions.controller';
import { SubscriptionsService } from './subscriptions.service';
import { SubscriptionRenewalService } from './subscription-renewal.service';
import { RankingModule } from '../ranking/ranking.module';

@Module({
  imports: [RankingModule],
  controllers: [SubscriptionsController],
  providers: [SubscriptionsService, SubscriptionRenewalService],
  exports: [SubscriptionsService],
})
export class SubscriptionsModule {}
