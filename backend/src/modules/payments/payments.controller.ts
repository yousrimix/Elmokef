import { Controller, Get, Post, Param, Body, Req, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard, Roles } from '../../common/guards/roles.guard';
import { IpWhitelistGuard } from '../../common/guards/ip-whitelist.guard';
import { Role } from '@prisma/client';
import { PaymentsService } from './payments.service';
import { InitPaymentDto, PaymentWebhookDto } from './dto';

@ApiTags('Payments')
@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post('init')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ARTISAN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'بدء عملية دفع — إعادة CMI form token' })
  initPayment(@Body() dto: InitPaymentDto, @Req() req: any) {
    return this.paymentsService.initPayment(req.user.userId, dto, req.ip, req.headers['user-agent']);
  }

  @Post('webhook')
  @UseGuards(IpWhitelistGuard)
  @ApiOperation({ summary: 'WebHook من بوابة CMI (IP Whitelist + HMAC)' })
  handleWebhook(@Body() dto: PaymentWebhookDto, @Req() req: any) {
    return this.paymentsService.handleWebhook(dto, req.headers['user-agent']);
  }

  @Get('status/:id')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'استعلام حالة الدفع (المالك أو ADMIN)' })
  getStatus(@Param('id') id: string, @Req() req: any) {
    return this.paymentsService.getStatus(id, req.user.userId, req.user.role);
  }
}
