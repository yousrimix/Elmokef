import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_datasource.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ClientRepositoryImpl({
    required ClientRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitReview({
    required String clientId,
    required String artisanId,
    required String serviceId,
    required int rating,
    String? comment,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.submitReview(
        clientId: clientId,
        artisanId: artisanId,
        serviceId: serviceId,
        rating: rating,
        comment: comment,
      );
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String? ?? 'فشل إرسال التقييم';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitComplaint({
    required String clientId,
    required String artisanId,
    required String reason,
    String? description,
    String? imageUrl,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.submitComplaint(
        clientId: clientId,
        artisanId: artisanId,
        reason: reason,
        description: description,
        imageUrl: imageUrl,
      );
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String? ?? 'فشل إرسال الشكوى';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getFavorites() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final favorites = await _remoteDataSource.getFavorites();
      return Right(favorites);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String? ?? 'فشل تحميل المفضلة';
      return Left(ServerFailure(msg));
    }
  }
}
