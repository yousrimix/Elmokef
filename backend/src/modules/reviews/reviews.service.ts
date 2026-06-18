import { Injectable, NotFoundException, ForbiddenException, ConflictException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RankingService } from '../ranking/ranking.service';

@Injectable()
export class ReviewsService {
  constructor(
    private prisma: PrismaService,
    private ranking: RankingService,
  ) {}

  async create(dto: { clientId: string; artisanId: string; serviceId: string; rating: number; comment?: string }) {
    const existing = await this.prisma.review.findUnique({
      where: { clientId_serviceId: { clientId: dto.clientId, serviceId: dto.serviceId } },
    });
    if (existing) throw new ConflictException('قيمت هذه الخدمة مسبقاً');

    const artisan = await this.prisma.artisanProfile.findUnique({ where: { userId: dto.artisanId } });
    if (!artisan) throw new NotFoundException('الحرفي غير موجود');

    const review = await this.prisma.review.create({ data: dto });

    await this.updateArtisanRating(dto.artisanId);
    this.ranking.recalculateScore(dto.artisanId);

    return this.prisma.review.findUnique({ where: { id: review.id }, include: { client: { select: { id: true, name: true, image: true } }, service: { select: { id: true, nameAr: true } } } });
  }

  async findOne(id: string) {
    const review = await this.prisma.review.findFirst({
      where: { id, deletedAt: null },
      include: { client: { select: { id: true, name: true, image: true } }, service: { select: { id: true, nameAr: true, nameFr: true } } },
    });
    if (!review) throw new NotFoundException('التقييم غير موجود');
    return review;
  }

  async findByArtisan(artisanId: string, query: { cursor?: string; limit?: number }) {
    const limit = query.limit || 20;
    const reviews = await this.prisma.review.findMany({
      where: { artisanId, deletedAt: null, isApproved: true },
      include: { client: { select: { id: true, name: true, image: true } }, service: { select: { id: true, nameAr: true } } },
      orderBy: { createdAt: 'desc' },
      take: limit + 1,
    });

    const hasMore = reviews.length > limit;
    const items = hasMore ? reviews.slice(0, limit) : reviews;
    const nextCursor = hasMore ? Buffer.from(items[items.length - 1].id).toString('base64') : null;

    return { data: items, nextCursor, hasMore };
  }

  async update(id: string, userId: string, dto: { rating?: number; comment?: string }) {
    const review = await this.prisma.review.findFirst({ where: { id, deletedAt: null } });
    if (!review) throw new NotFoundException('التقييم غير موجود');
    if (review.clientId !== userId) throw new ForbiddenException('ليس لديك صلاحية تعديل هذا التقييم');

    const updated = await this.prisma.review.update({
      where: { id },
      data: { ...dto, isApproved: false },
    });

    await this.updateArtisanRating(review.artisanId);
    this.ranking.recalculateScore(review.artisanId);

    return updated;
  }

  async remove(id: string, userId: string) {
    const review = await this.prisma.review.findFirst({ where: { id, deletedAt: null } });
    if (!review) throw new NotFoundException('التقييم غير موجود');
    if (review.clientId !== userId) throw new ForbiddenException('ليس لديك صلاحية حذف هذا التقييم');

    await this.prisma.review.update({ where: { id }, data: { deletedAt: new Date() } });

    await this.updateArtisanRating(review.artisanId);
    this.ranking.recalculateScore(review.artisanId);

    return { message: 'تم حذف التقييم' };
  }

  async findModerationQueue(query: { status?: string; cursor?: string; limit?: number }) {
    const limit = query.limit || 20;
    const where: any = { deletedAt: null };
    if (query.status === 'PENDING') where.isApproved = false;
    else if (query.status === 'APPROVED') where.isApproved = true;
    else if (query.status === 'REJECTED') where.isApproved = false;

    const reviews = await this.prisma.review.findMany({
      where,
      include: {
        client: { select: { id: true, name: true, phone: true, image: true } },
        artisanProfile: { select: { userId: true, user: { select: { name: true } } } },
        service: { select: { id: true, nameAr: true } },
      },
      orderBy: { createdAt: 'asc' },
      take: limit + 1,
    });

    const hasMore = reviews.length > limit;
    const items = hasMore ? reviews.slice(0, limit) : reviews;
    const nextCursor = hasMore ? Buffer.from(items[items.length - 1].id).toString('base64') : null;

    return { data: items, nextCursor, hasMore };
  }

  async moderate(id: string, action: 'APPROVED' | 'REJECTED', reason?: string) {
    const review = await this.prisma.review.findFirst({ where: { id, deletedAt: null } });
    if (!review) throw new NotFoundException('التقييم غير موجود');

    if (action === 'REJECTED') {
      await this.prisma.review.update({ where: { id }, data: { deletedAt: new Date() } });
    } else {
      await this.prisma.review.update({ where: { id }, data: { isApproved: true } });
    }

    await this.updateArtisanRating(review.artisanId);
    this.ranking.recalculateScore(review.artisanId);

    return { message: action === 'APPROVED' ? 'تم قبول التقييم' : 'تم رفض التقييم' };
  }

  private async updateArtisanRating(artisanId: string) {
    const result = await this.prisma.review.aggregate({
      where: { artisanId, deletedAt: null, isApproved: true },
      _avg: { rating: true },
      _count: { rating: true },
    });

    await this.prisma.artisanProfile.update({
      where: { userId: artisanId },
      data: {
        ratingAvg: result._avg.rating || 0,
        totalRatings: result._count.rating,
      },
    });
  }
}
