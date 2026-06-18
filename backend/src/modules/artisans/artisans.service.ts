import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RankingService } from '../ranking/ranking.service';
import { toArtisanPublicDto } from './dto/artisan-public.dto';

@Injectable()
export class ArtisansService {
  constructor(
    private prisma: PrismaService,
    private ranking: RankingService,
  ) {}

  async search(query: { service_id?: string; lat?: number; lng?: number; cursor?: string; limit?: number }) {
    return this.ranking.search(query);
  }

  async findOne(id: string) {
    const artisan = await this.prisma.artisanProfile.findUnique({
      where: { userId: id },
      include: {
        user: { select: { id: true, name: true, image: true } },
        services: { include: { service: true }, where: { isActive: true } },
        portfolio: true,
        reviews: {
          take: 10,
          orderBy: { createdAt: 'desc' },
          include: { client: { select: { name: true, image: true } } },
        },
      },
    });

    if (!artisan) throw new NotFoundException('الحرفي غير موجود');
    return toArtisanPublicDto(artisan);
  }

  async updateProfile(id: string, dto: { bio?: string; coverImage?: string }) {
    const artisan = await this.prisma.artisanProfile.findUnique({ where: { userId: id } });
    if (!artisan) throw new NotFoundException('الحرفي غير موجود');
    return this.prisma.artisanProfile.update({ where: { userId: id }, data: dto });
  }

  async addService(id: string, dto: { serviceId: string; price: number }) {
    const artisan = await this.prisma.artisanProfile.findUnique({ where: { userId: id } });
    if (!artisan) throw new NotFoundException('الحرفي غير موجود');
    const result = await this.prisma.artisanService.create({ data: { artisanId: id, ...dto } });
    this.ranking.recalculateScore(id);
    return result;
  }

  async updateService(id: string, serviceId: string, dto: { price?: number; serviceId?: string }) {
    const artisanService = await this.prisma.artisanService.findFirst({
      where: { id: serviceId, artisanId: id },
    });
    if (!artisanService) throw new NotFoundException('الخدمة غير موجودة');
    const result = await this.prisma.artisanService.update({ where: { id: serviceId }, data: dto });
    this.ranking.recalculateScore(id);
    return result;
  }

  async removeService(id: string, serviceId: string) {
    const artisanService = await this.prisma.artisanService.findFirst({
      where: { id: serviceId, artisanId: id },
    });
    if (!artisanService) throw new NotFoundException('الخدمة غير موجودة');
    const result = await this.prisma.artisanService.update({
      where: { id: serviceId },
      data: { isActive: false },
    });
    this.ranking.recalculateScore(id);
    return result;
  }

  async getPortfolio(id: string) {
    const artisan = await this.prisma.artisanProfile.findUnique({ where: { userId: id } });
    if (!artisan) throw new NotFoundException('الحرفي غير موجود');
    return this.prisma.artisanPortfolio.findMany({
      where: { artisanId: id },
      orderBy: { createdAt: 'desc' },
    });
  }

  async addPortfolio(id: string, dto: { imageUrl: string; thumbnailUrl?: string; description?: string }) {
    const artisan = await this.prisma.artisanProfile.findUnique({ where: { userId: id } });
    if (!artisan) throw new NotFoundException('الحرفي غير موجود');
    return this.prisma.artisanPortfolio.create({ data: { artisanId: id, ...dto } });
  }

  async getPortfolioMedia(id: string, mediaId: string) {
    const media = await this.prisma.artisanPortfolio.findFirst({
      where: { id: mediaId, artisanId: id },
    });
    if (!media) throw new NotFoundException('الصورة غير موجودة');
    return media;
  }

  async removePortfolio(id: string, mediaId: string) {
    const media = await this.getPortfolioMedia(id, mediaId);
    return this.prisma.artisanPortfolio.delete({ where: { id: mediaId } });
  }
}
