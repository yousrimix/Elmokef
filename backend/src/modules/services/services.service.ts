import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { RedisService } from '../../redis/redis.service';

@Injectable()
export class ServicesService {
  private readonly cachePrefix = 'services:';

  constructor(
    private prisma: PrismaService,
    private redis: RedisService,
  ) {}

  async findAll() {
    const cacheKey = `${this.cachePrefix}tree`;
    const cached = await this.redis.get<any[]>(cacheKey);
    if (cached) return cached;

    const services = await this.prisma.service.findMany({
      where: { isActive: true, parentId: null },
      include: {
        children: {
          where: { isActive: true },
          orderBy: { orderIndex: 'asc' },
        },
      },
      orderBy: { orderIndex: 'asc' },
    });

    await this.redis.set(cacheKey, services, 3600);
    return services;
  }

  async search(query: { q?: string; category_id?: string; cursor?: string; limit?: number }) {
    const limit = query.limit || 20;
    const where: any = { isActive: true };

    if (query.category_id) {
      where.OR = [{ id: query.category_id }, { parentId: query.category_id }];
    }

    if (query.q) {
      where.OR = [
        { nameAr: { contains: query.q, mode: 'insensitive' } },
        { nameFr: { contains: query.q, mode: 'insensitive' } },
      ];
      if (query.category_id) {
        where.AND = where.OR;
        delete where.OR;
      }
    }

    const services = await this.prisma.service.findMany({
      where,
      include: {
        parent: { select: { id: true, nameAr: true, nameFr: true } },
        children: { where: { isActive: true }, orderBy: { orderIndex: 'asc' } },
      },
      orderBy: { orderIndex: 'asc' },
      take: limit + 1,
    });

    const hasMore = services.length > limit;
    const items = hasMore ? services.slice(0, limit) : services;
    const nextCursor = hasMore ? Buffer.from(items[items.length - 1].id).toString('base64') : null;

    return { data: items, nextCursor, hasMore };
  }

  async findOne(id: string) {
    const cacheKey = `${this.cachePrefix}detail:${id}`;
    const cached = await this.redis.get<any>(cacheKey);
    if (cached) return cached;

    const service = await this.prisma.service.findUnique({
      where: { id },
      include: {
        parent: true,
        children: { where: { isActive: true }, orderBy: { orderIndex: 'asc' } },
        _count: { select: { artisanServices: true } },
      },
    });

    if (!service) throw new NotFoundException('الخدمة غير موجودة');
    await this.redis.set(cacheKey, service, 1800);
    return service;
  }

  async create(dto: { nameAr: string; nameFr: string; icon?: string; parentId?: string; orderIndex?: number }) {
    const service = await this.prisma.service.create({ data: dto });
    await this.invalidateCache();
    return service;
  }

  async update(id: string, dto: { nameAr?: string; nameFr?: string; icon?: string; parentId?: string; isActive?: boolean; orderIndex?: number }) {
    const service = await this.prisma.service.update({ where: { id }, data: dto });
    await this.invalidateCache();
    return service;
  }

  async remove(id: string) {
    await this.prisma.service.update({ where: { id }, data: { isActive: false } });
    await this.invalidateCache();
    return { message: 'تم حذف الخدمة' };
  }

  private async invalidateCache() {
    await this.redis.delByPattern(`${this.cachePrefix}*`);
  }
}
