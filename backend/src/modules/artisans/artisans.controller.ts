import {
  Controller, Get, Post, Put, Delete, Param, Body, Query,
  UseGuards, UseInterceptors, UploadedFile, ParseFilePipeBuilder,
  HttpStatus, Req, ForbiddenException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiQuery, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard, Roles } from '../../common/guards/roles.guard';
import { Role } from '@prisma/client';
import { ArtisansService } from './artisans.service';
import { UploadService } from '../upload/upload.service';
import {
  SearchArtisansDto, UpdateArtisanProfileDto,
  AddServiceDto, UpdateServiceDto, AddPortfolioDto,
} from './dto';

@ApiTags('Artisans')
@Controller('artisans')
export class ArtisansController {
  constructor(
    private readonly artisansService: ArtisansService,
    private readonly uploadService: UploadService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'بحث وترتيب الحرفيين' })
  @ApiQuery({ name: 'service_id', required: false })
  @ApiQuery({ name: 'lat', required: false })
  @ApiQuery({ name: 'lng', required: false })
  @ApiQuery({ name: 'cursor', required: false })
  @ApiQuery({ name: 'limit', required: false })
  search(@Query() query: SearchArtisansDto) {
    return this.artisansService.search(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'ملف حرفي كامل' })
  findOne(@Param('id') id: string) {
    return this.artisansService.findOne(id);
  }

  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ARTISAN)
  @Put(':id/profile')
  @ApiOperation({ summary: 'تحديث الملف الشخصي للحرفي' })
  updateProfile(@Param('id') id: string, @Body() dto: UpdateArtisanProfileDto, @Req() req: any) {
    if (req.user.userId !== id) throw new ForbiddenException();
    return this.artisansService.updateProfile(id, dto);
  }

  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ARTISAN)
  @Post(':id/cover')
  @UseInterceptors(FileInterceptor('file'))
  @ApiOperation({ summary: 'رفع صورة الغلاف' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({ schema: { type: 'object', properties: { file: { type: 'string', format: 'binary' } } } })
  async uploadCover(
    @Param('id') id: string,
    @UploadedFile(
      new ParseFilePipeBuilder()
        .addFileTypeValidator({ fileType: /(jpg|jpeg|png|webp|gif)$/ })
        .addMaxSizeValidator({ maxSize: 5 * 1024 * 1024 })
        .build({ errorHttpStatusCode: HttpStatus.UNPROCESSABLE_ENTITY }),
    )
    file: Express.Multer.File,
    @Req() req: any,
  ) {
    if (req.user.userId !== id) throw new ForbiddenException();
    const result = await this.uploadService.save(file, 'artisans/cover');
    return this.artisansService.updateProfile(id, { coverImage: result.url });
  }

  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ARTISAN)
  @Post(':id/services')
  @ApiOperation({ summary: 'إضافة خدمة للحرفي' })
  addService(@Param('id') id: string, @Body() dto: AddServiceDto, @Req() req: any) {
    if (req.user.userId !== id) throw new ForbiddenException();
    return this.artisansService.addService(id, dto);
  }

  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ARTISAN)
  @Put(':id/services/:serviceId')
  @ApiOperation({ summary: 'تحديث خدمة الحرفي' })
  updateService(
    @Param('id') id: string,
    @Param('serviceId') serviceId: string,
    @Body() dto: UpdateServiceDto,
    @Req() req: any,
  ) {
    if (req.user.userId !== id) throw new ForbiddenException();
    return this.artisansService.updateService(id, serviceId, dto);
  }

  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ARTISAN)
  @Delete(':id/services/:serviceId')
  @ApiOperation({ summary: 'حذف خدمة الحرفي (soft)' })
  removeService(
    @Param('id') id: string,
    @Param('serviceId') serviceId: string,
    @Req() req: any,
  ) {
    if (req.user.userId !== id) throw new ForbiddenException();
    return this.artisansService.removeService(id, serviceId);
  }

  @Get(':id/portfolio')
  @ApiOperation({ summary: 'عرض معرض أعمال الحرفي' })
  getPortfolio(@Param('id') id: string) {
    return this.artisansService.getPortfolio(id);
  }

  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ARTISAN)
  @Post(':id/portfolio')
  @UseInterceptors(FileInterceptor('file'))
  @ApiOperation({ summary: 'إضافة صورة لمعرض الحرفي' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: { type: 'string', format: 'binary' },
        description: { type: 'string' },
      },
    },
  })
  async addPortfolio(
    @Param('id') id: string,
    @Body() dto: AddPortfolioDto,
    @UploadedFile(
      new ParseFilePipeBuilder()
        .addFileTypeValidator({ fileType: /(jpg|jpeg|png|webp|gif)$/ })
        .addMaxSizeValidator({ maxSize: 5 * 1024 * 1024 })
        .build({ errorHttpStatusCode: HttpStatus.UNPROCESSABLE_ENTITY }),
    )
    file: Express.Multer.File,
    @Req() req: any,
  ) {
    if (req.user.userId !== id) throw new ForbiddenException();
    const result = await this.uploadService.save(file, 'artisans/portfolio');
    return this.artisansService.addPortfolio(id, {
      imageUrl: result.url,
      thumbnailUrl: result.thumbnailUrl || undefined,
      description: dto.description,
    });
  }

  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(Role.ARTISAN)
  @Delete(':id/portfolio/:mediaId')
  @ApiOperation({ summary: 'حذف صورة من المعرض' })
  async removePortfolio(
    @Param('id') id: string,
    @Param('mediaId') mediaId: string,
    @Req() req: any,
  ) {
    if (req.user.userId !== id) throw new ForbiddenException();
    const media = await this.artisansService.removePortfolio(id, mediaId);
    await this.uploadService.deleteByUrl(media.imageUrl);
    return media;
  }
}
