import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { CommonModule } from './common/common.module';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './redis/redis.module';
import { AuthModule } from './modules/auth/auth.module';
import { ServicesModule } from './modules/services/services.module';
import { RankingModule } from './modules/ranking/ranking.module';
import { UploadModule } from './modules/upload/upload.module';
import { ArtisansModule } from './modules/artisans/artisans.module';
import { ReviewsModule } from './modules/reviews/reviews.module';
import { ComplaintsModule } from './modules/complaints/complaints.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { OrdersModule } from './modules/orders/orders.module';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    ConfigModule.forRoot({ isGlobal: true }),
    ThrottlerModule.forRoot({ throttlers: [{ ttl: 60000, limit: 100 }], errorMessage: 'طلبات كثيرة جداً. الرجاء المحاولة بعد 60 ثانية' }),
    CommonModule,
    PrismaModule,
    RedisModule,
    AuthModule,
    ServicesModule,
    RankingModule,
    UploadModule,
    ArtisansModule,
    ReviewsModule,
    ComplaintsModule,
    PaymentsModule,
    SubscriptionsModule,
    NotificationsModule,
    OrdersModule,
  ],
})
export class AppModule {}
