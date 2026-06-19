import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/category_model.dart';

abstract class ServicesRepository {
  Future<Either<Failure, List<CategoryModel>>> getCategories();

  Future<Either<Failure, List<ArtisanModel>>> getArtisans({
    required String serviceId,
    double? lat,
    double? lng,
    String? cursor,
    int limit = 20,
  });

  Future<Either<Failure, List<ArtisanModel>>> getSuggestedArtisans({int limit = 5});

  Future<Either<Failure, ArtisanModel>> getArtisanProfile(String id);

  Future<Either<Failure, Map<String, dynamic>>> getArtisanReviews(
    String artisanId, {
    String? cursor,
    int limit = 20,
  });

  Future<Either<Failure, List<PortfolioModel>>> getArtisanPortfolio(String artisanId);

  Future<Either<Failure, List<ArtisanModel>>> searchArtisansByText(String query, {int limit = 20});

  Future<Either<Failure, Map<String, dynamic>>> searchServices({
    String? query,
    String? categoryId,
    String? cursor,
    int limit = 20,
  });
}
