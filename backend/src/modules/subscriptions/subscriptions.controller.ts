import { Controller, Get, Post, Param, Body, Query, UseGuards, Req, ForbiddenException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard, Roles } from '../../common/guards/roles.guard';
import { Role } from '@prisma/client';
import { SubscriptionsService } from './subscriptions.service';
import { SubscribeDto, CancelSubscriptionDto, UpgradeDto, AdminSubscriptionFilterDto } from './dto';

@ApiTags('Subscriptions')
@Controller('subscriptions')
export class SubscriptionsController {
  constructor(private readonly subscriptionsService: SubscriptionsService) {}

  @Get('plans')
  @ApiOperation({ summary: 'قائمة الباقات المتاحة' })
  getPlans() {
    return this.subscriptionsService.getPlans();
  }

  @Post('subscribe')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ARTISAN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'اشتراك جديد (ARTISAN)' })
  subscribe(@Body() dto: SubscribeDto, @Req() req: any) {
    return this.subscriptionsService.subscribe(req.user.userId, dto);
  }

  @Post('cancel')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ARTISAN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'إلغاء الاشتراك (ARTISAN)' })
  cancel(@Body() dto: CancelSubscriptionDto, @Req() req: any) {
    return this.subscriptionsService.cancel(req.user.userId, dto.reason);
  }

  @Post('upgrade')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ARTISAN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'ترقية الباقة (ARTISAN)' })
  upgrade(@Body() dto: UpgradeDto, @Req() req: any) {
    return this.subscriptionsService.upgrade(req.user.userId, dto);
  }

  @Get('my')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ARTISAN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'اشتراكي الحالي (ARTISAN)' })
  getMySubscription(@Req() req: any) {
    return this.subscriptionsService.getMySubscription(req.user.userId);
  }

  @Get('admin')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'كل الاشتراكات (ADMIN)' })
  findAll(@Query() query: AdminSubscriptionFilterDto) {
    return this.subscriptionsService.findAll(query);
  }
}
