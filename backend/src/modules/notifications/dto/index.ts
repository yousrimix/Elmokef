import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsBoolean, IsObject, IsIn } from 'class-validator';

export class RegisterDeviceDto {
  @ApiProperty({ description: 'FCM token من الجهاز' })
  @IsString()
  fcmToken: string;

  @ApiPropertyOptional({ enum: ['android', 'ios', 'huawei'] })
  @IsOptional()
  @IsIn(['android', 'ios', 'huawei'])
  platform?: string;
}

export class UnregisterDeviceDto {
  @ApiProperty()
  @IsString()
  token: string;
}

export class SendNotificationDto {
  @ApiProperty()
  @IsString()
  title: string;

  @ApiProperty()
  @IsString()
  body: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsObject()
  data?: Record<string, any>;
}
