import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationModel>>> getNotifications({String? cursor, int limit = 50});
  Future<Either<Failure, NotificationModel>> markAsRead(String id);
  Future<Either<Failure, void>> registerDevice(String fcmToken, String platform);
  Future<Either<Failure, void>> unregisterDevice(String fcmToken);
}
