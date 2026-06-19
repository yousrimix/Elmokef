import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';

class ServicesRemoteDataSource {
  final ApiClient _apiClient;

  ServicesRemoteDataSource(this._apiClient);

  /// GET /services — returns hierarchical service tree
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get(ApiConstants.services);
    final data = response.data;
    // Backend returns the tree directly (list of parent services with children)
    if (data is List) {
      return data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    // If wrapped in { data: [...] }
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List).map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// GET /services?q=...&category_id=...&cursor=...&limit=...
  Future<Map<String, dynamic>> searchServices({
    String? query,
    String? categoryId,
    String? cursor,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'limit': limit};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (categoryId != null) params['category_id'] = categoryId;
    if (cursor != null) params['cursor'] = cursor;

    final response = await _apiClient.get(
      ApiConstants.services,
      queryParameters: params,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /artisans?service_id=...&search=...&cursor=...&limit=...
  Future<Map<String, dynamic>> searchArtisans({
    required String serviceId,
    String? search,
    double? lat,
    double? lng,
    String? cursor,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{
      'service_id': serviceId,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    if (cursor != null) params['cursor'] = cursor;

    final response = await _apiClient.get(
      ApiConstants.artisans,
      queryParameters: params,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /artisans — suggested artisans
  Future<List<ArtisanModel>> getSuggestedArtisans({int limit = 5}) async {
    final response = await _apiClient.get(
      ApiConstants.artisans,
      queryParameters: {'limit': limit},
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => ArtisanModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List).map((e) => ArtisanModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// GET /artisans/:id — full artisan profile
  Future<ArtisanModel> getArtisanProfile(String id) async {
    final response = await _apiClient.get(ApiConstants.artisanProfile(id));
    return ArtisanModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /artisans?search=... — search artisans by text query
  Future<List<ArtisanModel>> searchArtisansByText(String query, {int limit = 20}) async {
    final response = await _apiClient.get(
      ApiConstants.artisans,
      queryParameters: {'search': query, 'limit': limit},
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => ArtisanModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List).map((e) => ArtisanModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// GET /artisans/:id/reviews
  Future<Map<String, dynamic>> getArtisanReviews(String artisanId, {String? cursor, int limit = 20}) async {
    final params = <String, dynamic>{'limit': limit};
    if (cursor != null) params['cursor'] = cursor;
    final response = await _apiClient.get(
      ApiConstants.artisanReviews(artisanId),
      queryParameters: params,
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /artisans/:id/portfolio
  Future<List<PortfolioModel>> getArtisanPortfolio(String artisanId) async {
    final response = await _apiClient.get(ApiConstants.artisanPortfolio(artisanId));
    final data = response.data;
    if (data is List) {
      return data.map((e) => PortfolioModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
