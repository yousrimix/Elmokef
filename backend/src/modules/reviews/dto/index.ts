import { IsString, IsNumber, Min, Max, IsOptional, IsUUID } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateReviewDto {
  @ApiProperty()
  @IsUUID()
  @IsString()
  clientId: string;

  @ApiProperty()
  @IsUUID()
  @IsString()
  artisanId: string;

  @ApiProperty()
  @IsUUID()
  @IsString()
  serviceId: string;

  @ApiProperty({ example: 5 })
  @IsNumber()
  @Min(1)
  @Max(5)
  rating: number;

  @ApiPropertyOptional({ example: 'خدمة ممتازة وسريع في الشغل' })
  @IsOptional()
  @IsString()
  comment?: string;
}

export class UpdateReviewDto {
  @ApiPropertyOptional({ example: 4 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  rating?: number;

  @ApiPropertyOptional({ example: 'تحديث: الخدمة كانت جيدة' })
  @IsOptional()
  @IsString()
  comment?: string;
}

export class ModerateReviewDto {
  @ApiProperty({ enum: ['APPROVED', 'REJECTED'] })
  @IsString()
  action: 'APPROVED' | 'REJECTED';

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  reason?: string;
}

export class ReviewFilterDto {
  @ApiPropertyOptional({ enum: ['PENDING', 'APPROVED', 'REJECTED'] })
  @IsOptional()
  @IsString()
  status?: string;

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
