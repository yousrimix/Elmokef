import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class ComplaintsService {
  constructor(private prisma: PrismaService) {}

  async create(dto: { clientId: string; artisanId: string; reason: string; description?: string; imageUrl?: string }) {
    return this.prisma.complaint.create({ data: dto });
  }

  async findByUser(userId: string, query: { cursor?: string; limit?: number }) {
    const limit = query.limit || 20;
    const complaints = await this.prisma.complaint.findMany({
      where: { clientId: userId },
      orderBy: { createdAt: 'desc' },
      take: limit + 1,
    });

    const hasMore = complaints.length > limit;
    const items = hasMore ? complaints.slice(0, limit) : complaints;
    const nextCursor = hasMore ? Buffer.from(items[items.length - 1].id).toString('base64') : null;

    return { data: items, nextCursor, hasMore };
  }

  async findAll(query: { status?: string; cursor?: string; limit?: number }) {
    const limit = query.limit || 20;
    const where: any = {};
    if (query.status) where.status = query.status;

    const complaints = await this.prisma.complaint.findMany({
      where,
      include: {
        client: { select: { id: true, name: true, phone: true } },
        artisan: { select: { id: true, name: true, phone: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: limit + 1,
    });

    const hasMore = complaints.length > limit;
    const items = hasMore ? complaints.slice(0, limit) : complaints;
    const nextCursor = hasMore ? Buffer.from(items[items.length - 1].id).toString('base64') : null;

    return { data: items, nextCursor, hasMore };
  }

  async updateStatus(id: string, dto: { status: string; resolution?: string }) {
    const complaint = await this.prisma.complaint.findUnique({ where: { id } });
    if (!complaint) throw new NotFoundException('الشكوى غير موجودة');

    const data: any = { status: dto.status };
    if (dto.resolution) data.resolution = dto.resolution;
    if (['RESOLVED', 'DISMISSED'].includes(dto.status)) data.resolvedAt = new Date();

    return this.prisma.complaint.update({ where: { id }, data });
  }
}
