import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> login({String? email, String? phone, required String password}) async {
    final response = await _apiClient.post(ApiConstants.login, data: {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    final response = await _apiClient.post(ApiConstants.register, data: {
      'name': name,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerArtisan({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    final response = await _apiClient.post(ApiConstants.registerArtisan, data: {
      'name': name,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiConstants.profile);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _apiClient.post(ApiConstants.logout);
  }
}
