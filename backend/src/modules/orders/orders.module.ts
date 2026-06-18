import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { OrdersController } from './orders.controller';
import { OrdersService } from './orders.service';
import { OrdersGateway } from './orders.gateway';
import { VerifiedArtisanGuard } from './guards/verified-artisan.guard';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'super-secret-jwt-key-elmokef-2026',
      signOptions: { expiresIn: '7d' },
    }),
    NotificationsModule,
  ],
  controllers: [OrdersController],
  providers: [OrdersService, OrdersGateway, VerifiedArtisanGuard],
  exports: [OrdersService, OrdersGateway],
})
export class OrdersModule {}
