import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

class ArtisanPublicUserDto {
  @ApiProperty() id: string;
  @ApiProperty() name: string;
  @ApiPropertyOptional() image?: string;
}

class ArtisanServiceDto {
  @ApiProperty() id: string;
  @ApiProperty() price: number;
  @ApiProperty() service: { id: string; nameAr: string; nameFr: string };
}

class ArtisanPortfolioDto {
  @ApiProperty() id: string;
  @ApiProperty() imageUrl: string;
  @ApiPropertyOptional() thumbnailUrl?: string;
  @ApiPropertyOptional() description?: string;
}

class ArtisanReviewDto {
  @ApiProperty() id: string;
  @ApiProperty() rating: number;
  @ApiPropertyOptional() comment?: string;
  @ApiProperty() client: { name: string; image?: string };
}

export class ArtisanPublicDto {
  @ApiProperty() id: string;
  @ApiProperty() bio?: string;
  @ApiPropertyOptional() coverImage?: string;
  @ApiProperty() ratingAvg: number;
  @ApiProperty() totalRatings: number;
  @ApiProperty() totalOrders: number;
  @ApiProperty() responseTimeAvg?: number;
  @ApiProperty() user: ArtisanPublicUserDto;
  @ApiProperty({ type: [ArtisanServiceDto] }) services: ArtisanServiceDto[];
  @ApiProperty({ type: [ArtisanPortfolioDto] }) portfolio: ArtisanPortfolioDto[];
  @ApiProperty({ type: [ArtisanReviewDto] }) reviews: ArtisanReviewDto[];
}

export function toArtisanPublicDto(raw: any): ArtisanPublicDto {
  return {
    id: raw.userId,
    bio: raw.bio,
    coverImage: raw.coverImage,
    ratingAvg: raw.ratingAvg,
    totalRatings: raw.totalRatings,
    totalOrders: raw.totalOrders,
    responseTimeAvg: raw.responseTimeAvg,
    user: {
      id: raw.user.id,
      name: raw.user.name,
      image: raw.user.image,
    },
    services: (raw.services || []).map((s: any) => ({
      id: s.id,
      price: s.price,
      service: { id: s.service.id, nameAr: s.service.nameAr, nameFr: s.service.nameFr },
    })),
    portfolio: (raw.portfolio || []).map((p: any) => ({
      id: p.id,
      imageUrl: p.imageUrl,
      thumbnailUrl: p.thumbnailUrl,
      description: p.description,
    })),
    reviews: (raw.reviews || []).map((r: any) => ({
      id: r.id,
      rating: r.rating,
      comment: r.comment,
      client: { name: r.client.name, image: r.client.image },
    })),
  };
}
