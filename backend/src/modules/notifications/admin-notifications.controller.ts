import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard, Roles } from '../../common/guards/roles.guard';
import { Role } from '@prisma/client';
import { NotificationsService } from './notifications.service';
import { SendNotificationDto } from './dto';

@ApiTags('Admin / Notifications')
@Controller('admin/notifications')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles(Role.ADMIN)
@ApiBearerAuth()
export class AdminNotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  @Post('send')
  @ApiOperation({ summary: 'إرسال إشعار لجميع الحرفيين' })
  sendToAllArtisans(@Body() dto: SendNotificationDto) {
    return this.notifications.sendToAllArtisans(dto.title, dto.body, dto.data);
  }
}
