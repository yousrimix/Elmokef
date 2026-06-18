import { Controller, Get, Post, Patch, Delete, Param, Body, Query, Req, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { NotificationsService } from './notifications.service';
import { RegisterDeviceDto, UnregisterDeviceDto } from './dto';

@ApiTags('Notifications')
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  @Post('register-device')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'تسجيل جهاز لإرسال الإشعارات' })
  registerDevice(@Body() dto: RegisterDeviceDto, @Req() req: any) {
    return this.notifications.registerDevice(req.user.userId, dto);
  }

  @Delete('unregister-device')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'إلغاء تسجيل جهاز' })
  unregisterDevice(@Body() dto: UnregisterDeviceDto, @Req() req: any) {
    return this.notifications.unregisterDevice(req.user.userId, dto.token);
  }

  @Get()
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'قائمة إشعارات المستخدم (مسحوبة زمنيًا)' })
  @ApiQuery({ name: 'cursor', required: false })
  @ApiQuery({ name: 'limit', required: false })
  listNotifications(@Req() req: any, @Query('cursor') cursor?: string, @Query('limit') limit?: string) {
    return this.notifications.listNotifications(req.user.userId, cursor, limit ? parseInt(limit, 10) : 50);
  }

  @Patch(':id/read')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'تعيين إشعار كمقروء' })
  markAsRead(@Param('id') id: string, @Req() req: any) {
    return this.notifications.markAsRead(id, req.user.userId);
  }
}
