import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export interface SuspicionResult {
  isSuspicious: boolean;
  reasons: string[];
  score: number;
}

@Injectable()
export class ReviewTrustService {
  constructor(private prisma: PrismaService) {}

  async getReviewWeight(clientId: string, artisanId: string): Promise<number> {
    const completedCount = await this.prisma.review.count({
      where: { clientId, artisanId, isApproved: true, deletedAt: null },
    });
    return completedCount > 0 ? 1.0 : 0.3;
  }

  async checkRateLimit(clientId: string): Promise<boolean> {
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const count = await this.prisma.review.count({
      where: { clientId, createdAt: { gte: oneDayAgo } },
    });
    return count < 10;
  }

  async detectSuspicious(params: { clientId: string; artisanId: string; rating: number; comment?: string }): Promise<SuspicionResult> {
    const reasons: string[] = [];
    let score = 0;

    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const recentCount = await this.prisma.review.count({
      where: { clientId: params.clientId, createdAt: { gte: oneDayAgo } },
    });
    if (recentCount >= 5) {
      reasons.push('تقييمات كثيرة في وقت قصير');
      score += 0.4;
    }

    if (!params.comment || params.comment.length < 10) {
      reasons.push('تقييم بدون تعليق كافي');
      score += 0.2;
    }

    if (params.rating === 1 || params.rating === 5) {
      const sameRating = await this.prisma.review.count({
        where: { clientId: params.clientId, rating: params.rating, createdAt: { gte: oneDayAgo } },
      });
      if (sameRating >= 3) {
        reasons.push('نمط تقييم متطرف متكرر');
        score += 0.3;
      }
    }

    return { isSuspicious: score >= 0.5, reasons, score };
  }
}
