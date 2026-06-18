import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

class ClientRemoteDataSource {
  final ApiClient _apiClient;

  ClientRemoteDataSource(this._apiClient);

  /// POST /reviews
  Future<Map<String, dynamic>> submitReview({
    required String clientId,
    required String artisanId,
    required String serviceId,
    required int rating,
    String? comment,
  }) async {
    final response = await _apiClient.post(ApiConstants.reviews, data: {
      'client_id': clientId,
      'artisan_id': artisanId,
      'service_id': serviceId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
    return response.data as Map<String, dynamic>;
  }

  /// POST /complaints
  Future<Map<String, dynamic>> submitComplaint({
    required String clientId,
    required String artisanId,
    required String reason,
    String? description,
    String? imageUrl,
  }) async {
    final response = await _apiClient.post(ApiConstants.complaints, data: {
      'client_id': clientId,
      'artisan_id': artisanId,
      'reason': reason,
      if (description != null && description.isNotEmpty) 'description': description,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
    });
    return response.data as Map<String, dynamic>;
  }

  /// GET /favorites
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final response = await _apiClient.get(ApiConstants.favorites);
    final data = response.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    final list = (data as Map<String, dynamic>?)?['data'] as List<dynamic>? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
