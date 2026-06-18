import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/models/notification_model.dart';

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSource(ref.watch(apiClientProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remoteDataSource: ref.watch(notificationRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final result = await ref.watch(notificationRepositoryProvider).getNotifications();
  return result.fold((failure) => throw failure, (notifications) => notifications);
});

final markAsReadProvider = FutureProvider.family<NotificationModel, String>((ref, id) async {
  final result = await ref.watch(notificationRepositoryProvider).markAsRead(id);
  return result.fold((failure) => throw failure, (notification) => notification);
});
