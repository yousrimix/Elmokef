import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard, Roles } from '../../common/guards/roles.guard';
import { Role, OrderStatus } from '@prisma/client';
import { OrdersService } from './orders.service';
import { CreateOrderDto, UpdateOrderStatusDto, OrderFilterDto } from './dto';
import { VerifiedArtisanGuard } from './guards/verified-artisan.guard';

@ApiTags('Orders')
@Controller()
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  // ──────────────────────────────────────────────
  //  العميل ينشئ طلب خدمة
  // ──────────────────────────────────────────────
  @Post('orders')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'إنشاء طلب خدمة (Client)' })
  async create(@Body() dto: CreateOrderDto, @Req() req: any) {
    return this.ordersService.create(req.user.id, dto);
  }

  // ──────────────────────────────────────────────
  //  قائمة طلبات العميل
  // ──────────────────────────────────────────────
  @Get('orders/client')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'طلباتي كعميل (Client)' })
  @ApiQuery({ name: 'status', required: false, enum: OrderStatus, description: 'فلترة حسب الحالة' })
  @ApiQuery({ name: 'cursor', required: false, description: 'Cursor pagination' })
  @ApiQuery({ name: 'limit', required: false, description: 'عدد النتائج' })
  async findClientOrders(
    @Req() req: any,
    @Query('status') status?: OrderStatus,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: number,
  ) {
    return this.ordersService.findByClient(req.user.id, { status, cursor, limit: limit ? +limit : undefined });
  }

  // ──────────────────────────────────────────────
  //  قائمة طلبات الحرفي (الواردة)
  // ──────────────────────────────────────────────
  @Get('orders/artisan')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'طلباتي كحرفي (Artisan) — الطلبات الواردة' })
  @ApiQuery({ name: 'status', required: false, enum: OrderStatus, description: 'فلترة حسب الحالة' })
  @ApiQuery({ name: 'cursor', required: false, description: 'Cursor pagination' })
  @ApiQuery({ name: 'limit', required: false, description: 'عدد النتائج' })
  async findArtisanOrders(
    @Req() req: any,
    @Query('status') status?: OrderStatus,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: number,
  ) {
    return this.ordersService.findByArtisan(req.user.id, { status, cursor, limit: limit ? +limit : undefined });
  }

  // ──────────────────────────────────────────────
  //  تفاصيل الطلب
  // ──────────────────────────────────────────────
  @Get('orders/:id')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'تفاصيل الطلب (Client / Artisan / Admin)' })
  async findOne(@Param('id') id: string, @Req() req: any) {
    return this.ordersService.findOne(id, req.user.id, req.user.role);
  }

  // ──────────────────────────────────────────────
  //  تحديث حالة الطلب
  // ──────────────────────────────────────────────
  @Patch('orders/:id/status')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'تحديث حالة الطلب (Artisan: ACCEPT/DECLINE/IN_PROGRESS/COMPLETE | Client: CANCEL)',
  })
  async updateStatus(
    @Param('id') id: string,
    @Body() dto: UpdateOrderStatusDto,
    @Req() req: any,
  ) {
    return this.ordersService.updateStatus(id, req.user.id, dto);
  }

  // ──────────────────────────────────────────────
  //  إلغاء الطلب (مختصر)
  // ──────────────────────────────────────────────
  @Patch('orders/:id/cancel')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'إلغاء الطلب (Client أو Artisan)' })
  async cancel(@Param('id') id: string, @Req() req: any) {
    return this.ordersService.cancel(id, req.user.id);
  }

  // ──────────────────────────────────────────────
  //  حذف الطلب (ADMIN فقط — soft delete)
  // ──────────────────────────────────────────────
  @Delete('orders/:id')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'حذف الطلب (ADMIN فقط — Soft delete)' })
  async remove(@Param('id') id: string, @Req() req: any) {
    return this.ordersService.remove(id, req.user.id, req.user.role);
  }
}
