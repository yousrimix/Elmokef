import { Controller, Get, Post, Patch, Delete, Param, Body, Query, UseGuards, Req, ForbiddenException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard, Roles } from '../../common/guards/roles.guard';
import { Role } from '@prisma/client';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto, UpdateReviewDto, ModerateReviewDto, ReviewFilterDto } from './dto';

@ApiTags('Reviews')
@Controller()
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Post('reviews')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'إضافة تقييم (تقييم واحد لكل خدمة+عميل)' })
  create(@Body() dto: CreateReviewDto, @Req() req: any) {
    if (req.user.userId !== dto.clientId) throw new ForbiddenException('لا يمكنك التقييم نيابة عن غيرك');
    return this.reviewsService.create(dto);
  }

  @Get('reviews/:id')
  @ApiOperation({ summary: 'تفاصيل تقييم' })
  findOne(@Param('id') id: string) {
    return this.reviewsService.findOne(id);
  }

  @Get('artisans/:artisanId/reviews')
  @ApiOperation({ summary: 'تقييمات حرفي (public)' })
  findByArtisan(@Param('artisanId') artisanId: string, @Query() query: ReviewFilterDto) {
    return this.reviewsService.findByArtisan(artisanId, query);
  }

  @Patch('reviews/:id')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'تعديل تقييم (صاحبه فقط)' })
  update(@Param('id') id: string, @Body() dto: UpdateReviewDto, @Req() req: any) {
    return this.reviewsService.update(id, req.user.userId, dto);
  }

  @Delete('reviews/:id')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'حذف تقييم (soft — صاحبه فقط)' })
  remove(@Param('id') id: string, @Req() req: any) {
    return this.reviewsService.remove(id, req.user.userId);
  }

  @Get('admin/reviews')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'قائمة مراجعة التقييمات (ADMIN) — pending/approved/rejected' })
  findModerationQueue(@Query() query: ReviewFilterDto) {
    return this.reviewsService.findModerationQueue(query);
  }

  @Patch('admin/reviews/:id')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'قبول/رفض تقييم (ADMIN)' })
  moderate(@Param('id') id: string, @Body() dto: ModerateReviewDto) {
    return this.reviewsService.moderate(id, dto.action, dto.reason);
  }
}
