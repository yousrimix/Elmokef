import { IsString, IsOptional, IsNumber, IsUUID, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SearchArtisansDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  service_id?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  lat?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  lng?: number;

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

export class UpdateArtisanProfileDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  bio?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  coverImage?: string;
}

export class AddServiceDto {
  @ApiProperty()
  @IsString()
  serviceId: string;

  @ApiProperty({ example: 250 })
  @IsNumber()
  @Min(0)
  price: number;
}

export class UpdateServiceDto {
  @ApiPropertyOptional({ example: 300 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  price?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  serviceId?: string;
}

export class AddPortfolioDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;
}
