import { Controller, Get, Patch, Param, Body, Query, Req, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard, Roles } from '../../common/guards/roles.guard';
import { Role, DocumentStatus } from '@prisma/client';
import { DocumentsService } from './documents.service';

class ReviewDocumentDto {
  status: DocumentStatus;
  comment?: string;
}

@ApiTags('Admin / Documents')
@Controller('admin/documents')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles(Role.ADMIN)
@ApiBearerAuth()
export class AdminDocumentsController {
  constructor(private readonly documents: DocumentsService) {}

  @Get()
  @ApiOperation({ summary: 'قائمة الوثائق المعلقة (PENDING)' })
  @ApiQuery({ name: 'cursor', required: false })
  @ApiQuery({ name: 'limit', required: false })
  listPending(@Query('cursor') cursor?: string, @Query('limit') limit?: string) {
    return this.documents.listPending(cursor, limit ? parseInt(limit, 10) : 20);
  }

  @Get(':id')
  @ApiOperation({ summary: 'تفاصيل وثيقة معينة' })
  getDetail(@Param('id') id: string) {
    return this.documents.getDetail(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'قبول أو رفض وثيقة' })
  review(@Param('id') id: string, @Body() dto: ReviewDocumentDto, @Req() req: any) {
    return this.documents.review(id, dto, req.user.userId);
  }
}
