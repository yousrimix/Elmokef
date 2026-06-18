import { Module } from '@nestjs/common';
import { PaymentsController } from './payments.controller';
import { PaymentsService } from './payments.service';
import { PaymentsGateway } from './payments.gateway';
import { SubscriptionsModule } from '../subscriptions/subscriptions.module';

@Module({
  imports: [SubscriptionsModule],
  controllers: [PaymentsController],
  providers: [PaymentsService, PaymentsGateway],
  exports: [PaymentsGateway],
})
export class PaymentsModule {}
