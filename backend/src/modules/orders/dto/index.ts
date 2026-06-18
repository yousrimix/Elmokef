import { IsString, IsOptional, IsUUID, IsNumber, IsEnum, IsDateString, IsObject, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { OrderStatus } from '@prisma/client';

export class CreateOrderDto {
  @ApiProperty({ description: 'معرف الحرفي' })
  @IsUUID()
  @IsString()
  artisanId: string;

  @ApiProperty({ description: 'معرف الخدمة' })
  @IsUUID()
  @IsString()
  serviceId: string;

  @ApiPropertyOptional({ example: 'محبس ماء في الحمام يتسرب، أحتاج سباك عاجل', description: 'وصف الطلب (اختياري — يحل محل description من الخدمة)' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: { lat: 33.5731, lng: -7.5898 }, description: 'موقع العميل {lat, lng}' })
  @IsOptional()
  @IsObject()
  location?: { lat: number; lng: number };

  @ApiPropertyOptional({ example: 500, description: 'الميزانية المقترحة (درهم)' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  budget?: number;

  @ApiPropertyOptional({ example: '2026-06-20T10:00:00.000Z', description: 'التاريخ المطلوب للخدمة' })
  @IsOptional()
  @IsDateString()
  scheduledDate?: string;
}

export class UpdateOrderStatusDto {
  @ApiProperty({ enum: [OrderStatus.ACCEPTED, OrderStatus.DECLINED, OrderStatus.IN_PROGRESS, OrderStatus.COMPLETED, OrderStatus.CANCELLED], description: 'الحالة الجديدة' })
  @IsEnum(OrderStatus)
  status: 'ACCEPTED' | 'DECLINED' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';

  @ApiPropertyOptional({ example: 'الوقت لا يناسبني', description: 'سبب الرفض (مطلوب عند DECLINED)' })
  @IsOptional()
  @IsString()
  declinedReason?: string;

  @ApiPropertyOptional({ example: 'سأبدأ العمل غداً صباحاً', description: 'ملاحظة الحرفي' })
  @IsOptional()
  @IsString()
  artisanNote?: string;
}

export class OrderFilterDto {
  @ApiPropertyOptional({ enum: OrderStatus, description: 'فلترة حسب الحالة' })
  @IsOptional()
  @IsEnum(OrderStatus)
  status?: OrderStatus;

  @ApiPropertyOptional({ description: 'Cursor pagination' })
  @IsOptional()
  @IsString()
  cursor?: string;

  @ApiPropertyOptional({ description: 'عدد النتائج', default: 20 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  limit?: number;
}
