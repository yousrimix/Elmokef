import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../prisma/prisma.service';
import { RedisService } from '../../redis/redis.service';

const DEFAULT_WEIGHTS = { rating: 0.30, price: 0.20, speed: 0.10, distance: 0.40 };
const DEFAULT_BOOSTS = { FREE: 1.0, PRO: 1.2, PREMIUM: 1.5 };
const MAX_PRICE = 1000;
const MAX_SPEED = 120;
const MAX_DISTANCE = 50_000;
const CACHE_TTL = 300;

interface Config {
  weights: typeof DEFAULT_WEIGHTS;
  boosts: typeof DEFAULT_BOOSTS;
}

@Injectable()
export class RankingService {
  private readonly logger = new Logger(RankingService.name);
  private configCache: Config | null = null;
  private configTimestamp = 0;
  private readonly configTtl = 60_000;

  constructor(
    private prisma: PrismaService,
    private redis: RedisService,
    private config: ConfigService,
  ) {}

  async getConfig(): Promise<Config> {
    if (this.configCache && Date.now() - this.configTimestamp < this.configTtl) return this.configCache;
    try {
      const row = await this.prisma.rankingConfig.findUnique({ where: { id: 'singleton' } });
      if (row) {
        this.configCache = {
          weights: typeof row.weights === 'string' ? JSON.parse(row.weights as string) : row.weights,
          boosts: typeof row.boosts === 'string' ? JSON.parse(row.boosts as string) : row.boosts,
        };
      }
    } catch {
      this.configCache = { weights: DEFAULT_WEIGHTS, boosts: DEFAULT_BOOSTS };
    }
    this.configTimestamp = Date.now();
    return this.configCache!;
  }

  async updateConfig(dto: { weights?: any; boosts?: any }): Promise<Config> {
    const data: any = {};
    if (dto.weights) data.weights = dto.weights;
    if (dto.boosts) data.boosts = dto.boosts;
    await this.prisma.rankingConfig.upsert({
      where: { id: 'singleton' },
      create: { id: 'singleton', ...data },
      update: data,
    });
    this.configCache = null;
    await this.redis.delByPattern('rankings:*');
    return this.getConfig();
  }

  async recalculateScore(artisanUserId: string) {
    await this.recalculateScores(artisanUserId);
  }

  async recalculateScores(artisanId?: string) {
    const w = (await this.getConfig()).weights;
    const b = (await this.getConfig()).boosts;

    const sql = artisanId
      ? `UPDATE artisan_profiles ap SET ranking_score = ROUND((COALESCE(ap.rating_avg,0)/5.0*${w.rating} + (1.0-LEAST(COALESCE(subq.avg_price,0)/${MAX_PRICE},1.0))*${w.price} + (1.0-LEAST(COALESCE(ap.response_time_avg,30)/${MAX_SPEED},1.0))*${w.speed}) * CASE WHEN sub.plan='PREMIUM' THEN ${b.PREMIUM} WHEN sub.plan='PRO' THEN ${b.PRO} ELSE ${b.FREE} END, 4), avg_price = COALESCE(subq.avg_price,0) FROM (SELECT artisan_id, AVG(price) avg_price FROM artisan_services WHERE is_active=true GROUP BY artisan_id) subq LEFT JOIN subscriptions sub ON sub.artisan_id=ap.user_id WHERE ap.id=subq.artisan_id AND ap.user_id='${artisanId}'`
      : `UPDATE artisan_profiles ap SET ranking_score = ROUND((COALESCE(ap.rating_avg,0)/5.0*${w.rating} + (1.0-LEAST(COALESCE(subq.avg_price,0)/${MAX_PRICE},1.0))*${w.price} + (1.0-LEAST(COALESCE(ap.response_time_avg,30)/${MAX_SPEED},1.0))*${w.speed}) * CASE WHEN sub.plan='PREMIUM' THEN ${b.PREMIUM} WHEN sub.plan='PRO' THEN ${b.PRO} ELSE ${b.FREE} END, 4), avg_price = COALESCE(subq.avg_price,0) FROM (SELECT artisan_id, AVG(price) avg_price FROM artisan_services WHERE is_active=true GROUP BY artisan_id) subq LEFT JOIN subscriptions sub ON sub.artisan_id=ap.user_id WHERE ap.id=subq.artisan_id AND ap.user_id IN (SELECT id FROM users WHERE role='ARTISAN' AND is_active=true)`;

    await this.prisma.$queryRawUnsafe(sql);
    await this.redis.delByPattern('rankings:*');
  }

  async search(query: {
    service_id?: string;
    lat?: number;
    lng?: number;
    cursor?: string;
    limit?: number;
  }) {
    const limit = Math.min(query.limit || 20, 100);
    const config = await this.getConfig();
    const cacheKey = this._cacheKey(query, query.cursor);

    const cached = await this.redis.get<any>(cacheKey);
    if (cached) return cached;

    let result: any;
    if (query.lat != null && query.lng != null) {
      result = await this._geoSearch(query.lat, query.lng, query.service_id, query.cursor, limit, config);
    } else {
      result = await this._rankedSearch(query.service_id, query.cursor, limit);
    }

    await this.redis.set(cacheKey, result, CACHE_TTL);
    return result;
  }

  private async _rankedSearch(serviceId: string | undefined, cursor: string | undefined, limit: number) {
    const parsed = this._parseCursor(cursor);
    const where: any = { user: { role: 'ARTISAN', isActive: true } };
    if (serviceId) where.services = { some: { serviceId, isActive: true } };
    if (parsed) where.OR = [
      { rankingScore: { lt: parsed.score } },
      { rankingScore: parsed.score, id: { lt: parsed.id } },
    ];

    const artisans = await this.prisma.artisanProfile.findMany({
      where,
      include: {
        user: { select: { id: true, name: true, image: true } },
        services: { include: { service: true }, where: { isActive: true } },
        _count: { select: { reviews: true } },
      },
      orderBy: [{ rankingScore: 'desc' }, { id: 'desc' }],
      take: limit + 1,
    });

    return this._formatPage(artisans, limit);
  }

  private async _geoSearch(lat: number, lng: number, serviceId: string | undefined, cursor: string | undefined, limit: number, config: Config) {
    const parsed = this._parseCursor(cursor);
    const cursorClause = parsed
      ? `AND (ap.ranking_score < ${parsed.score} OR (ap.ranking_score = ${parsed.score} AND ap.id < '${parsed.id}'))`
      : '';
    const serviceClause = serviceId
      ? `AND EXISTS (SELECT 1 FROM artisan_services WHERE artisan_id=ap.id AND service_id='${serviceId}' AND is_active=true)`
      : '';
    const b = config.boosts;

    const rows: any[] = await this.prisma.$queryRawUnsafe(`
      SELECT ap.id, ap.user_id, ap.bio, ap.cover_image, ap.rating_avg, ap.avg_price,
        ap.response_time_avg, ap.total_ratings, ap.total_orders, ap.ranking_score,
        u.id uid, u.name, u.image,
        ROUND(ST_DistanceSphere(u.location::geometry, ST_MakePoint(${lng},${lat})::geometry)) distance_m,
        ROUND(COALESCE(ap.ranking_score,0) + (1.0-LEAST(ST_DistanceSphere(u.location::geometry, ST_MakePoint(${lng},${lat})::geometry)/${MAX_DISTANCE},1.0))*${config.weights.distance}, 4) final_score,
        (SELECT COUNT(*) FROM artisan_services WHERE artisan_id=ap.id AND is_active=true) service_count,
        (SELECT COUNT(*) FROM reviews WHERE artisan_id=ap.user_id) review_count
      FROM artisan_profiles ap
      JOIN users u ON u.id=ap.user_id
      WHERE u.role='ARTISAN' AND u.is_active=true AND u.location IS NOT NULL
        AND ST_DWithin(u.location::geometry, ST_MakePoint(${lng},${lat})::geometry, ${MAX_DISTANCE})
        ${serviceClause}
        ${cursorClause}
      ORDER BY ap.ranking_score DESC, ap.id DESC
      LIMIT ${limit + 1}
    `);

    return this._formatGeoPage(rows, limit, b);
  }

  private _parseCursor(cursor: string | undefined): { score: number; id: string } | null {
    if (!cursor) return null;
    try {
      const decoded = Buffer.from(cursor, 'base64').toString('utf-8');
      const [score, id] = decoded.split('|');
      return { score: parseFloat(score), id };
    } catch {
      return null;
    }
  }

  private _formatPage(artisans: any[], limit: number) {
    const hasMore = artisans.length > limit;
    if (hasMore) artisans.pop();
    const data = artisans.map((a) => ({
      id: a.userId, user: a.user, bio: a.bio, coverImage: a.coverImage,
      ratingAvg: a.ratingAvg, totalRatings: a.totalRatings, totalOrders: a.totalOrders,
      responseTimeAvg: a.responseTimeAvg, rankingScore: a.rankingScore,
      services: a.services, _count: { reviews: a._count?.reviews ?? 0 },
    }));
    const nextCursor = hasMore && data.length > 0
      ? Buffer.from(`${artisans[artisans.length - 1].rankingScore}|${artisans[artisans.length - 1].id}`).toString('base64')
      : null;
    return { data, nextCursor, hasMore };
  }

  private _formatGeoPage(rows: any[], limit: number, boosts: any) {
    const hasMore = rows.length > limit;
    if (hasMore) rows.pop();
    const data = rows.map((r: any) => ({
      id: r.user_id, user: { id: r.uid, name: r.name, image: r.image },
      bio: r.bio, coverImage: r.cover_image, ratingAvg: Number(r.rating_avg),
      totalRatings: Number(r.total_ratings), totalOrders: Number(r.total_orders),
      responseTimeAvg: r.response_time_avg, rankingScore: Number(r.ranking_score),
      _distance: Number(r.distance_m), _finalScore: Number(r.final_score),
      serviceCount: Number(r.service_count), reviewCount: Number(r.review_count),
    }));
    const nextCursor = hasMore && data.length > 0
      ? Buffer.from(`${rows[rows.length - 1].ranking_score}|${rows[rows.length - 1].id}`).toString('base64')
      : null;
    return { data, nextCursor, hasMore };
  }

  private _cacheKey(query: any, cursor?: string): string {
    const parts = ['rankings'];
    if (query.service_id) parts.push(`s:${query.service_id}`);
    if (query.lat != null && query.lng != null) parts.push(`g:${query.lat.toFixed(2)}:${query.lng.toFixed(2)}`);
    const limit = Math.min(query.limit || 20, 100);
    if (cursor) parts.push(`c:${cursor}`);
    parts.push(`l:${limit}`);
    return parts.join(':');
  }
}
