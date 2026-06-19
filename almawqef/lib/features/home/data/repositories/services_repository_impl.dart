import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_datasource.dart';
import '../models/category_model.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ServicesRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategories() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final categories = await _remoteDataSource.getCategories();
      return Right(categories);
    } on DioException catch (e) {
      final msg = e.error is ServerException ? (e.error as ServerException).message : 'فشل تحميل الفئات';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, List<ArtisanModel>>> getArtisans({
    required String serviceId,
    double? lat,
    double? lng,
    String? cursor,
    int limit = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.searchArtisans(
        serviceId: serviceId,
        lat: lat,
        lng: lng,
        cursor: cursor,
        limit: limit,
      );
      final data = result['data'] as List<dynamic>? ?? [];
      final artisans = data.map((e) => ArtisanModel.fromJson(e as Map<String, dynamic>)).toList();
      return Right(artisans);
    } on DioException catch (e) {
      final msg = e.error is ServerException ? (e.error as ServerException).message : 'فشل تحميل الحرفيين';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, List<ArtisanModel>>> getSuggestedArtisans({int limit = 5}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final artisans = await _remoteDataSource.getSuggestedArtisans(limit: limit);
      return Right(artisans);
    } on DioException catch (e) {
      final msg = e.error is ServerException ? (e.error as ServerException).message : 'فشل تحميل الاقتراحات';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, ArtisanModel>> getArtisanProfile(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final artisan = await _remoteDataSource.getArtisanProfile(id);
      return Right(artisan);
    } on DioException catch (e) {
      final msg = e.error is ServerException ? (e.error as ServerException).message : 'فشل تحميل الملف الشخصي';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getArtisanReviews(
    String artisanId, {
    String? cursor,
    int limit = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.getArtisanReviews(artisanId, cursor: cursor, limit: limit);
      return Right(result);
    } on DioException catch (e) {
      final msg = e.error is ServerException ? (e.error as ServerException).message : 'فشل تحميل التقييمات';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, List<PortfolioModel>>> getArtisanPortfolio(String artisanId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final portfolio = await _remoteDataSource.getArtisanPortfolio(artisanId);
      return Right(portfolio);
    } on DioException catch (e) {
      final msg = e.error is ServerException ? (e.error as ServerException).message : 'فشل تحميل معرض الأعمال';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, List<ArtisanModel>>> searchArtisansByText(String query, {int limit = 20}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final artisans = await _remoteDataSource.searchArtisansByText(query, limit: limit);
      return Right(artisans);
    } on DioException catch (e) {
      final msg = e.error is ServerException ? (e.error as ServerException).message : 'فشل البحث';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> searchServices({
    String? query,
    String? categoryId,
    String? cursor,
    int limit = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.searchServices(
        query: query,
        categoryId: categoryId,
        cursor: cursor,
        limit: limit,
      );
      return Right(result);
    } on DioException catch (e) {
      final msg = e.error is ServerException ? (e.error as ServerException).message : 'فشل البحث';
      return Left(ServerFailure(msg));
    }
  }
}
