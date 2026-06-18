import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final ApiClient _apiClient;
  NotificationRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> getNotifications({String? cursor, int limit = 50}) async {
    final params = <String, dynamic>{'limit': limit};
    if (cursor != null) params['cursor'] = cursor;
    final response = await _apiClient.get(ApiConstants.notifications, queryParameters: params);
    return response.data as Map<String, dynamic>;
  }

  Future<NotificationModel> markAsRead(String id) async {
    final response = await _apiClient.patch('${ApiConstants.notifications}/$id/read');
    return NotificationModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> registerDevice(String fcmToken, String platform) async {
    await _apiClient.post(ApiConstants.registerDevice, data: {'fcmToken': fcmToken, 'platform': platform});
  }

  Future<void> unregisterDevice(String fcmToken) async {
    await _apiClient.delete(ApiConstants.unregisterDevice, data: {'token': fcmToken});
  }
}
