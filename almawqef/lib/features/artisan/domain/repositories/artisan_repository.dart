import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class ArtisanStats {
  final int profileViews;
  final int totalContacts;
  final double ratingAvg;
  final int totalRatings;
  final int totalOrders;

  const ArtisanStats({
    this.profileViews = 0,
    this.totalContacts = 0,
    this.ratingAvg = 0,
    this.totalRatings = 0,
    this.totalOrders = 0,
  });

  factory ArtisanStats.fromJson(Map<String, dynamic> json) {
    return ArtisanStats(
      profileViews: (json['profile_views'] as int?) ?? (json['profileViews'] as int?) ?? 0,
      totalContacts: (json['total_contacts'] as int?) ?? (json['totalContacts'] as int?) ?? 0,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      totalRatings: (json['total_ratings'] as int?) ?? (json['totalRatings'] as int?) ?? 0,
      totalOrders: (json['total_orders'] as int?) ?? (json['totalOrders'] as int?) ?? 0,
    );
  }
}

abstract class ArtisanRepository {
  /// GET /artisans/:id/stats
  Future<Either<Failure, ArtisanStats>> getStats(String artisanId);

  /// GET /artisans/:id/requests
  Future<Either<Failure, List<Map<String, dynamic>>>> getRequests(String artisanId);

  /// PUT /artisans/:id/profile
  Future<Either<Failure, Map<String, dynamic>>> updateProfile(
    String artisanId, {
    String? bio,
    String? coverImage,
  });

  /// POST /artisans/:id/services
  Future<Either<Failure, Map<String, dynamic>>> addService(
    String artisanId, {
    required String serviceId,
    required double price,
  });

  /// PUT /artisans/:id/services/:serviceId
  Future<Either<Failure, Map<String, dynamic>>> updateService(
    String artisanId,
    String serviceId, {
    double? price,
  });

  /// DELETE /artisans/:id/services/:serviceId
  Future<Either<Failure, void>> removeService(String artisanId, String serviceId);

  /// GET /subscriptions/plans
  Future<Either<Failure, List<Map<String, dynamic>>>> getPlans();

  /// POST /subscriptions/subscribe
  Future<Either<Failure, Map<String, dynamic>>> subscribe(String plan, {String? paymentId});

  /// POST /subscriptions/cancel
  Future<Either<Failure, Map<String, dynamic>>> cancelSubscription({String? reason});

  /// POST /subscriptions/upgrade
  Future<Either<Failure, Map<String, dynamic>>> upgradeSubscription(String plan);

  /// GET /subscriptions/my
  Future<Either<Failure, Map<String, dynamic>>> getMySubscription();

  /// POST /upload
  Future<Either<Failure, Map<String, dynamic>>> uploadImage(List<int> bytes, String fileName);

  /// POST /artisans/:id/portfolio
  Future<Either<Failure, Map<String, dynamic>>> addPortfolio(
    String artisanId, {
    required String imageUrl,
    String? description,
  });

  /// DELETE /artisans/:id/portfolio/:mediaId
  Future<Either<Failure, void>> removePortfolio(String artisanId, String mediaId);

  /// GET /artisans/:id/portfolio
  Future<Either<Failure, List<Map<String, dynamic>>>> getMyPortfolio(String artisanId);
}
