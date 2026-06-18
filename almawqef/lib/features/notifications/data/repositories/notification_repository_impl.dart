import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications({String? cursor, int limit = 50}) async {
    if (!await networkInfo.isConnected) return Left(const NetworkFailure('لا يوجد اتصال بالإنترنت'));
    try {
      final result = await remoteDataSource.getNotifications(cursor: cursor, limit: limit);
      final list = (result['data'] as List<dynamic>).map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل تحميل الإشعارات'));
    }
  }

  @override
  Future<Either<Failure, NotificationModel>> markAsRead(String id) async {
    if (!await networkInfo.isConnected) return Left(const NetworkFailure('لا يوجد اتصال بالإنترنت'));
    try {
      final model = await remoteDataSource.markAsRead(id);
      return Right(model);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل تعيين الإشعار كمقروء'));
    }
  }

  @override
  Future<Either<Failure, void>> registerDevice(String fcmToken, String platform) async {
    if (!await networkInfo.isConnected) return Left(const NetworkFailure('لا يوجد اتصال بالإنترنت'));
    try {
      await remoteDataSource.registerDevice(fcmToken, platform);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل تسجيل الجهاز'));
    }
  }

  @override
  Future<Either<Failure, void>> unregisterDevice(String fcmToken) async {
    if (!await networkInfo.isConnected) return Left(const NetworkFailure('لا يوجد اتصال بالإنترنت'));
    try {
      await remoteDataSource.unregisterDevice(fcmToken);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] as String? ?? 'فشل إلغاء تسجيل الجهاز'));
    }
  }
}
