import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { DocumentStatus } from '@prisma/client';

@Injectable()
export class DocumentsService {
  constructor(private prisma: PrismaService) {}

  async listPending(cursor?: string, limit = 20) {
    const where: any = { status: DocumentStatus.PENDING };
    if (cursor) {
      const decoded = Buffer.from(cursor, 'base64').toString('utf-8');
      where.createdAt = { lt: new Date(decoded) };
    }
    const docs = await this.prisma.artisanDocument.findMany({
      where,
      include: { user: { select: { id: true, name: true, phone: true, email: true } } },
      orderBy: { createdAt: 'desc' },
      take: limit + 1,
    });
    const hasMore = docs.length > limit;
    if (hasMore) docs.pop();
    const nextCursor = hasMore && docs.length
      ? Buffer.from(docs[docs.length - 1].createdAt.toISOString()).toString('base64')
      : null;
    return { data: docs, nextCursor, hasMore };
  }

  async getDetail(documentId: string) {
    const doc = await this.prisma.artisanDocument.findUnique({
      where: { id: documentId },
      include: { user: { select: { id: true, name: true, phone: true, email: true } } },
    });
    if (!doc) throw new NotFoundException('الوثيقة غير موجودة');
    return doc;
  }

  async review(documentId: string, dto: { status: DocumentStatus; comment?: string }, adminId: string) {
    const doc = await this.prisma.artisanDocument.findUnique({ where: { id: documentId } });
    if (!doc) throw new NotFoundException('الوثيقة غير موجودة');
    if (doc.status !== DocumentStatus.PENDING) throw new BadRequestException('تمت مراجعة هذه الوثيقة مسبقًا');

    const updated = await this.prisma.artisanDocument.update({
      where: { id: documentId },
      data: { status: dto.status, verifiedBy: adminId },
    });

    if (dto.status === DocumentStatus.APPROVED) {
      const allDocs = await this.prisma.artisanDocument.findMany({
        where: { userId: doc.userId },
      });
      const allApproved = allDocs.every((d) => d.status === DocumentStatus.APPROVED);
      if (allApproved) {
        await this.prisma.artisanProfile.updateMany({
          where: { userId: doc.userId },
          data: { isVerified: true, verifiedAt: new Date(), verifiedBy: adminId },
        });
      }
    }

    await this.prisma.notification.create({
      data: {
        userId: doc.userId,
        title: dto.status === DocumentStatus.APPROVED ? 'تم توثيق حسابك' : 'لم يتم توثيق الوثيقة',
        body: dto.status === DocumentStatus.APPROVED
          ? 'تمت الموافقة على وثيقتك وحسابك الآن موثق'
          : `لم يتم الموافقة على وثيقتك: ${dto.comment || 'يرجى إعادة رفع وثيقة صالحة'}`,
        data: { documentId, status: dto.status, comment: dto.comment },
      },
    });

    return updated;
  }

  async listMine(userId: string) {
    return this.prisma.artisanDocument.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }
}
