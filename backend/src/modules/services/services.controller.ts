import { Controller, Get, Post, Body, Param, Put, Delete, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { ServicesService } from './services.service';
import { CreateServiceDto, UpdateServiceDto } from './dto';

@ApiTags('Services')
@Controller('services')
export class ServicesController {
  constructor(private readonly servicesService: ServicesService) {}

  @Get()
  @ApiOperation({ summary: 'قائمة الخدمات (هرمية مع Redis Cache — TTL 1 ساعة)' })
  @ApiQuery({ name: 'q', required: false, description: 'بحث نصي (بالعربية أو الفرنسية)' })
  @ApiQuery({ name: 'category_id', required: false, description: 'فلترة حسب الفئة' })
  @ApiQuery({ name: 'cursor', required: false, description: 'Cursor pagination' })
  @ApiQuery({ name: 'limit', required: false, description: 'عدد النتائج' })
  findAll(@Query('q') q?: string, @Query('category_id') category_id?: string, @Query('cursor') cursor?: string, @Query('limit') limit?: number) {
    if (q || category_id) {
      return this.servicesService.search({ q, category_id, cursor, limit: limit ? +limit : undefined });
    }
    return this.servicesService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'تفاصيل خدمة معينة (مع Redis Cache — TTL 30 دقيقة)' })
  findOne(@Param('id') id: string) {
    return this.servicesService.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'إضافة خدمة جديدة (Invalidates cache)' })
  create(@Body() dto: CreateServiceDto) {
    return this.servicesService.create(dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'تحديث خدمة (Invalidates cache)' })
  update(@Param('id') id: string, @Body() dto: UpdateServiceDto) {
    return this.servicesService.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'حذف خدمة (Soft delete + Invalidate cache)' })
  remove(@Param('id') id: string) {
    return this.servicesService.remove(id);
  }
}
