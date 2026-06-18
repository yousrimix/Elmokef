import { Controller, Get, Put, Body, UseGuards, Post } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard, Roles } from '../../common/guards/roles.guard';
import { Role } from '@prisma/client';
import { RankingService } from './ranking.service';

@ApiTags('Ranking')
@Controller('ranking')
export class RankingController {
  constructor(private readonly ranking: RankingService) {}

  @Get('config')
  @ApiOperation({ summary: 'عرض إعدادات الترتيب الحالية' })
  getConfig() {
    return this.ranking.getConfig();
  }

  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ADMIN)
  @Put('config')
  @ApiOperation({ summary: 'تحديث إعدادات الترتيب (ADMIN فقط)' })
  updateConfig(@Body() dto: { weights?: any; boosts?: any }) {
    return this.ranking.updateConfig(dto);
  }

  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ADMIN)
  @Post('recalculate')
  @ApiOperation({ summary: 'إعادة حساب Scores لكل الحرفيين (ADMIN فقط)' })
  recalculate() {
    return this.ranking.recalculateScores();
  }
}
