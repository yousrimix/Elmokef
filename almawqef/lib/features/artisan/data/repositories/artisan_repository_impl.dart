import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/artisan_repository.dart';
import '../datasources/artisan_remote_datasource.dart';

class ArtisanRepositoryImpl implements ArtisanRepository {
  final ArtisanRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ArtisanRepositoryImpl({
    required ArtisanRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, ArtisanStats>> getStats(String artisanId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final data = await _remoteDataSource.getStats(artisanId);
      return Right(ArtisanStats.fromJson(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل تحميل الإحصائيات'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getRequests(String artisanId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final raw = await _remoteDataSource.getRequests(artisanId);
      return Right(raw.cast<Map<String, dynamic>>());
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل تحميل الطلبات'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateProfile(
    String artisanId, {
    String? bio,
    String? coverImage,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.updateProfile(artisanId, bio: bio, coverImage: coverImage);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل تحديث الملف'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addService(
    String artisanId, {
    required String serviceId,
    required double price,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.addService(artisanId, serviceId: serviceId, price: price);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل إضافة الخدمة'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateService(
    String artisanId,
    String serviceId, {
    double? price,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.updateService(artisanId, serviceId, price: price);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل تحديث الخدمة'));
    }
  }

  @override
  Future<Either<Failure, void>> removeService(String artisanId, String serviceId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      await _remoteDataSource.removeService(artisanId, serviceId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل حذف الخدمة'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPlans() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final raw = await _remoteDataSource.getPlans();
      return Right(raw.cast<Map<String, dynamic>>());
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل تحميل الباقات'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> subscribe(String plan, {String? paymentId}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.subscribe(plan, paymentId: paymentId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل الاشتراك'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> cancelSubscription({String? reason}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.cancelSubscription(reason: reason);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل إلغاء الاشتراك'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> upgradeSubscription(String plan) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.upgradeSubscription(plan);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل ترقية الباقة'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMySubscription() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.getMySubscription();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل تحميل الاشتراك'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadImage(List<int> bytes, String fileName) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.uploadImage(bytes, fileName);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل رفع الصورة'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addPortfolio(
    String artisanId, {
    required String imageUrl,
    String? description,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.addPortfolio(artisanId, imageUrl: imageUrl, description: description);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل إضافة صورة للمعرض'));
    }
  }

  @override
  Future<Either<Failure, void>> removePortfolio(String artisanId, String mediaId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      await _remoteDataSource.removePortfolio(artisanId, mediaId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل حذف الصورة'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMyPortfolio(String artisanId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final raw = await _remoteDataSource.getMyPortfolio(artisanId);
      return Right(raw.cast<Map<String, dynamic>>());
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل تحميل المعرض'));
    }
  }
}
