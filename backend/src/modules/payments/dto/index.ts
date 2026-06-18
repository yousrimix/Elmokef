import { IsString, IsOptional, IsNumber, IsEnum, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class InitPaymentDto {
  @ApiProperty({ enum: ['PRO', 'PREMIUM'] })
  @IsEnum(['PRO', 'PREMIUM'])
  plan: string;

  @ApiProperty()
  @IsString()
  successUrl: string;

  @ApiProperty()
  @IsString()
  failureUrl: string;
}

export class PaymentWebhookDto {
  @ApiProperty()
  @IsString()
  transactionId: string;

  @ApiProperty()
  @IsString()
  status: string;

  @ApiProperty()
  @IsString()
  artisanId: string;

  @ApiProperty()
  @IsNumber()
  @Min(0)
  amount: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  rawResponse?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  hash?: string;
}
