import { IsString, IsOptional, IsEnum, IsUUID, IsNumber, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export const COMPLAINT_REASONS = [
  'SPAM',
  'FAKE_PROFILE',
  'POOR_SERVICE',
  'NO_SHOW',
  'OVERCHARGING',
  'HARASSMENT',
  'OTHER',
] as const;

export class CreateComplaintDto {
  @ApiProperty()
  @IsUUID()
  @IsString()
  clientId: string;

  @ApiProperty()
  @IsUUID()
  @IsString()
  artisanId: string;

  @ApiProperty({ enum: COMPLAINT_REASONS })
  @IsEnum(COMPLAINT_REASONS)
  reason: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  imageUrl?: string;
}

export class UpdateComplaintStatusDto {
  @ApiProperty({ enum: ['OPEN', 'IN_REVIEW', 'RESOLVED', 'DISMISSED'] })
  @IsEnum(['OPEN', 'IN_REVIEW', 'RESOLVED', 'DISMISSED'])
  status: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  resolution?: string;
}

export class ComplaintFilterDto {
  @ApiPropertyOptional({ enum: ['OPEN', 'IN_REVIEW', 'RESOLVED', 'DISMISSED'] })
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
