import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard, Roles } from '../../common/guards/roles.guard';
import { Role } from '@prisma/client';
import { DocumentsService } from './documents.service';

@ApiTags('Artisans / Documents')
@Controller('artisans/documents')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles(Role.ARTISAN)
@ApiBearerAuth()
export class DocumentsController {
  constructor(private readonly documents: DocumentsService) {}

  @Get()
  @ApiOperation({ summary: 'قائمة وثائق الحرفي (خاص به)' })
  listMine(@Req() req: any) {
    return this.documents.listMine(req.user.userId);
  }
}
