import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id; // UUID string from backend, was int
  final String nameAr;
  final String nameFr;
  final int orderIndex;
  final String? parentId;
  final List<CategoryModel> children;
  final int artisanCount;
  final String? icon;

  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.orderIndex,
    this.parentId,
    this.children = const [],
    this.artisanCount = 0,
    this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String? ?? json['nameAr'] as String? ?? '',
      nameFr: json['name_fr'] as String? ?? json['nameFr'] as String? ?? '',
      orderIndex: json['order_index'] as int? ?? json['orderIndex'] as int? ?? 0,
      parentId: json['parent_id'] as String? ?? json['parentId'] as String?,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      artisanCount: json['artisan_count'] as int? ?? json['_count']?['artisanServices'] as int? ?? 0,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_ar': nameAr,
        'name_fr': nameFr,
        'order_index': orderIndex,
        'parent_id': parentId,
        'children': children.map((e) => e.toJson()).toList(),
        'artisan_count': artisanCount,
        'icon': icon,
      };

  @override
  List<Object?> get props => [id, nameAr, nameFr, orderIndex, parentId, children, artisanCount, icon];
}

class ArtisanModel extends Equatable {
  final String id; // UUID string from backend (userId)
  final String name;
  final String profession;
  final double rating;
  final int reviewCount;
  final String priceRange;
  final double distanceKm;
  final String responseTime;
  final bool verified;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final double rankScore;
  final String? bio;
  final String? coverImage;
  final List<ArtisanServiceModel> services;
  final List<PortfolioModel> portfolio;

  const ArtisanModel({
    required this.id,
    required this.name,
    this.profession = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.priceRange = '',
    this.distanceKm = 0,
    this.responseTime = '',
    this.verified = false,
    this.imageUrl,
    this.latitude = 0,
    this.longitude = 0,
    this.rankScore = 0,
    this.bio,
    this.coverImage,
    this.services = const [],
    this.portfolio = const [],
  });

  factory ArtisanModel.fromJson(Map<String, dynamic> json) {
    // Backend returns ArtisanPublicDto shape
    // { id, bio, coverImage, ratingAvg, totalRatings, totalOrders, responseTimeAvg,
    //   user: { id, name, image }, services: [ { id, price, service: { id, nameAr, nameFr } } ],
    //   portfolio: [ { id, imageUrl, thumbnailUrl, description } ], reviews: [...] }
    final user = json['user'] as Map<String, dynamic>?;
    final servicesRaw = json['services'] as List<dynamic>?;
    final portfolioRaw = json['portfolio'] as List<dynamic>?;

    // Fallback: if no nested user/services, try flat keys (e.g. mock data)
    final flatName = json['name'] as String?;
    final flatService = json['service'] as String?;
    final flatRating = json['rating'] as num?;
    final flatVerified = json['verified'] as bool?;
    final flatImage = json['image'] as String? ?? json['image_url'] as String? ?? json['imageUrl'] as String?;

    String professionStr = '';
    if (servicesRaw != null && servicesRaw.isNotEmpty) {
      final firstService = servicesRaw[0] as Map<String, dynamic>?;
      final svc = firstService?['service'] as Map<String, dynamic>?;
      professionStr = svc?['name_ar'] as String? ?? svc?['nameAr'] as String? ?? '';
    }
    // Flat fallback for profession
    if (professionStr.isEmpty && flatService != null) {
      professionStr = flatService;
    }

    final reviews = json['reviews'] as List<dynamic>?;
    final ratingAvg = (json['rating_avg'] as num?) ?? (json['ratingAvg'] as num?) ?? flatRating ?? 0;
    final totalRatingsCount = (json['total_ratings'] as int?) ?? (json['totalRatings'] as int?) ?? reviews?.length ?? 0;

    // Compute price range from services
    String priceRangeStr = '';
    if (servicesRaw != null && servicesRaw.isNotEmpty) {
      final prices = servicesRaw.map((s) => (s as Map<String, dynamic>)['price'] as num?).where((p) => p != null).map((p) => p!.toDouble()).toList();
      if (prices.isNotEmpty) {
        final min = prices.reduce((a, b) => a < b ? a : b);
        final max = prices.reduce((a, b) => a > b ? a : b);
        priceRangeStr = min == max ? '${min.toInt()} درهم' : '${min.toInt()}-${max.toInt()} درهم';
      }
    }

    return ArtisanModel(
      id: json['id'] as String? ?? user?['id'] as String? ?? '',
      name: user?['name'] as String? ?? flatName ?? '',
      profession: professionStr,
      rating: ratingAvg.toDouble(),
      reviewCount: totalRatingsCount,
      priceRange: priceRangeStr,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? (json['distanceKm'] as num?)?.toDouble() ?? 0,
      responseTime: _formatResponseTime(json['response_time_avg'] as num? ?? json['responseTimeAvg'] as num?),
      verified: json['is_verified'] as bool? ?? json['isVerified'] as bool? ?? flatVerified ?? false,
      imageUrl: user?['image'] as String? ?? flatImage,
      latitude: (json['lat'] as num?)?.toDouble() ?? 0,
      longitude: (json['lng'] as num?)?.toDouble() ?? 0,
      rankScore: (json['rank_score'] as num?)?.toDouble() ?? (json['rankScore'] as num?)?.toDouble() ?? 0,
      bio: json['bio'] as String?,
      coverImage: json['cover_image'] as String? ?? json['coverImage'] as String?,
      services: (servicesRaw ?? []).map((e) => ArtisanServiceModel.fromJson(e as Map<String, dynamic>)).toList(),
      portfolio: (portfolioRaw ?? []).map((e) => PortfolioModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  static String _formatResponseTime(num? minutes) {
    if (minutes == null) return '';
    if (minutes < 60) return '${minutes.toInt()} د';
    return '${(minutes / 60).toStringAsFixed(0)} س';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'profession': profession,
        'rating': rating,
        'review_count': reviewCount,
        'price_range': priceRange,
        'distance_km': distanceKm,
        'response_time': responseTime,
        'verified': verified,
        'image_url': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'rank_score': rankScore,
      };

  @override
  List<Object?> get props => [id, name, rating, verified, rankScore];
}

class ArtisanServiceModel extends Equatable {
  final String id;
  final double price;
  final String serviceId;
  final String serviceNameAr;
  final String serviceNameFr;

  const ArtisanServiceModel({
    required this.id,
    required this.price,
    required this.serviceId,
    required this.serviceNameAr,
    required this.serviceNameFr,
  });

  factory ArtisanServiceModel.fromJson(Map<String, dynamic> json) {
    final service = json['service'] as Map<String, dynamic>?;
    return ArtisanServiceModel(
      id: json['id'] as String,
      price: (json['price'] as num).toDouble(),
      serviceId: service?['id'] as String? ?? '',
      serviceNameAr: service?['name_ar'] as String? ?? service?['nameAr'] as String? ?? '',
      serviceNameFr: service?['name_fr'] as String? ?? service?['nameFr'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, price, serviceId, serviceNameAr];
}

class PortfolioModel extends Equatable {
  final String id;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? description;

  const PortfolioModel({
    required this.id,
    required this.imageUrl,
    this.thumbnailUrl,
    this.description,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? json['thumbnailUrl'] as String?,
      description: json['description'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, imageUrl];
}
