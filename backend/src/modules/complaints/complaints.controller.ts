import { Controller, Get, Post, Patch, Param, Body, Query, UseGuards, Req, ForbiddenException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard, Roles } from '../../common/guards/roles.guard';
import { Role } from '@prisma/client';
import { ComplaintsService } from './complaints.service';
import { CreateComplaintDto, UpdateComplaintStatusDto, ComplaintFilterDto } from './dto';

@ApiTags('Complaints')
@Controller()
export class ComplaintsController {
  constructor(private readonly complaintsService: ComplaintsService) {}

  @Post('complaints')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'تقديم شكوى ضد حرفي' })
  create(@Body() dto: CreateComplaintDto, @Req() req: any) {
    if (req.user.userId !== dto.clientId) throw new ForbiddenException('لا يمكنك تقديم شكوى نيابة عن غيرك');
    return this.complaintsService.create(dto);
  }

  @Get('complaints')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'شكايات المستخدم' })
  findByUser(@Query() query: ComplaintFilterDto, @Req() req: any) {
    return this.complaintsService.findByUser(req.user.userId, query);
  }

  @Get('admin/complaints')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'كل الشكايات (ADMIN) مع فلترة حسب الحالة' })
  findAll(@Query() query: ComplaintFilterDto) {
    return this.complaintsService.findAll(query);
  }

  @Patch('admin/complaints/:id')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'تحديث حالة شكوى (ADMIN)' })
  updateStatus(@Param('id') id: string, @Body() dto: UpdateComplaintStatusDto) {
    return this.complaintsService.updateStatus(id, dto);
  }
}
