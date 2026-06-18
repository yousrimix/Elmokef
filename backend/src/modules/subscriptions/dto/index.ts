import { IsString, IsOptional, IsNumber, IsEnum, IsUUID, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SubscribeDto {
  @ApiProperty({ enum: ['PRO', 'PREMIUM'] })
  @IsEnum(['PRO', 'PREMIUM'])
  plan: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  paymentId?: string;
}

export class CancelSubscriptionDto {
  @ApiPropertyOptional({ example: 'الخدمة مكلفة جداً' })
  @IsOptional()
  @IsString()
  reason?: string;
}

export class UpgradeDto {
  @ApiProperty({ enum: ['PREMIUM'] })
  @IsEnum(['PREMIUM'])
  plan: string;
}

export class AdminSubscriptionFilterDto {
  @ApiPropertyOptional({ enum: ['ACTIVE', 'CANCELLED', 'EXPIRED'] })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ enum: ['FREE', 'PRO', 'PREMIUM'] })
  @IsOptional()
  @IsString()
  plan?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  cursor?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number;
}
