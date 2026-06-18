import { IsString, IsOptional, IsEmail, MinLength, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum RegisterRole {
  CLIENT = 'CLIENT',
  ARTISAN = 'ARTISAN',
}

export class RegisterDto {
  @ApiProperty({ example: 'عميد', description: 'الاسم الكامل' })
  @IsString()
  @MinLength(2)
  name: string;

  @ApiProperty({ example: '0612345678', description: 'رقم الهاتف' })
  @IsString()
  phone: string;

  @ApiPropertyOptional({ example: 'amid@example.com', description: 'البريد الإلكتروني' })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiProperty({ example: 'mypassword123', description: 'كلمة المرور (8 أحرف كحد أدنى)' })
  @IsString()
  @MinLength(8)
  password: string;

  @ApiPropertyOptional({ enum: RegisterRole, default: RegisterRole.CLIENT })
  @IsOptional()
  @IsEnum(RegisterRole)
  role?: RegisterRole;
}

export class LoginDto {
  @ApiPropertyOptional({ example: 'amid@example.com' })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ example: '0612345678' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiProperty({ example: 'mypassword123' })
  @IsString()
  password: string;
}
