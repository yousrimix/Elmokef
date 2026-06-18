import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

/// These endpoints require the artisan's userId from auth state.
/// The Bearer token interceptor handles auth for protected endpoints.
class ArtisanRemoteDataSource {
  final ApiClient _apiClient;

  ArtisanRemoteDataSource(this._apiClient);

  /// GET /artisans/:id/stats
  Future<Map<String, dynamic>> getStats(String artisanId) async {
    final response = await _apiClient.get(ApiConstants.artisanStats(artisanId));
    return response.data as Map<String, dynamic>;
  }

  /// GET /artisans/:id/requests
  Future<List<dynamic>> getRequests(String artisanId) async {
    final response = await _apiClient.get(ApiConstants.artisanRequests(artisanId));
    final data = response.data;
    if (data is List) return data;
    return (data as Map<String, dynamic>?)?['data'] as List<dynamic>? ?? [];
  }

  /// PUT /artisans/:id/profile
  Future<Map<String, dynamic>> updateProfile(
    String artisanId, {
    String? bio,
    String? coverImage,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.artisanProfileUpdate(artisanId),
      data: {
        if (bio != null) 'bio': bio,
        if (coverImage != null) 'cover_image': coverImage,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /artisans/:id/services
  Future<Map<String, dynamic>> addService(
    String artisanId, {
    required String serviceId,
    required double price,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.artisanServices(artisanId),
      data: {'service_id': serviceId, 'price': price},
    );
    return response.data as Map<String, dynamic>;
  }

  /// PUT /artisans/:id/services/:serviceId
  Future<Map<String, dynamic>> updateService(
    String artisanId,
    String serviceId, {
    double? price,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.artisanService(artisanId, serviceId),
      data: {if (price != null) 'price': price},
    );
    return response.data as Map<String, dynamic>;
  }

  /// DELETE /artisans/:id/services/:serviceId
  Future<void> removeService(String artisanId, String serviceId) async {
    await _apiClient.delete(ApiConstants.artisanService(artisanId, serviceId));
  }

  /// GET /subscriptions/plans
  Future<List<dynamic>> getPlans() async {
    final response = await _apiClient.get(ApiConstants.subscriptionPlans);
    if (response.data is List) return response.data;
    return [];
  }

  /// POST /subscriptions/subscribe
  Future<Map<String, dynamic>> subscribe(String plan, {String? paymentId}) async {
    final response = await _apiClient.post(
      ApiConstants.subscribe,
      data: {'plan': plan, if (paymentId != null) 'payment_id': paymentId},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /subscriptions/cancel
  Future<Map<String, dynamic>> cancelSubscription({String? reason}) async {
    final response = await _apiClient.post(
      ApiConstants.cancelSub,
      data: {if (reason != null) 'reason': reason},
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST /subscriptions/upgrade
  Future<Map<String, dynamic>> upgradeSubscription(String plan) async {
    final response = await _apiClient.post(
      ApiConstants.upgradeSub,
      data: {'plan': plan},
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /subscriptions/my
  Future<Map<String, dynamic>> getMySubscription() async {
    final response = await _apiClient.get(ApiConstants.mySubscription);
    return response.data as Map<String, dynamic>;
  }

  /// POST /upload — multipart image upload
  Future<Map<String, dynamic>> uploadImage(List<int> bytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final response = await _apiClient.post(ApiConstants.upload, data: formData);
    return response.data as Map<String, dynamic>;
  }

  /// POST /artisans/:id/portfolio
  Future<Map<String, dynamic>> addPortfolio(
    String artisanId, {
    required String imageUrl,
    String? description,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.artisanPortfolio(artisanId),
      data: {
        'image_url': imageUrl,
        if (description != null) 'description': description,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// DELETE /artisans/:id/portfolio/:mediaId
  Future<void> removePortfolio(String artisanId, String mediaId) async {
    await _apiClient.delete(ApiConstants.artisanPortfolioItem(artisanId, mediaId));
  }

  /// GET /artisans/:id/portfolio
  Future<List<dynamic>> getMyPortfolio(String artisanId) async {
    final response = await _apiClient.get(ApiConstants.artisanPortfolio(artisanId));
    if (response.data is List) return response.data;
    return (response.data as Map<String, dynamic>?)?['data'] as List<dynamic>? ?? [];
  }
}
