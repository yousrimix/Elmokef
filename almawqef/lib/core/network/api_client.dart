import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';

const _accessTokenKey = 'access_token';

class ApiClient {
  late final Dio _dio;

  ApiClient({FlutterSecureStorage? secureStorage}) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.timeout,
      receiveTimeout: ApiConstants.timeout,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    _dio.interceptors.addAll([
      _AuthInterceptor(secureStorage),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);
  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
  Future<Response> put(String path, {dynamic data}) => _dio.put(path, data: data);
  Future<Response> delete(String path, {dynamic data}) => _dio.delete(path, data: data);
  Future<Response> patch(String path, {dynamic data}) => _dio.patch(path, data: data);

  void setToken(String? token) {
    // Token handled by interceptor; this method kept for manual override if needed
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage? _secureStorage;

  _AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    String? token;
    if (kIsWeb) {
      // Web: use flutter_secure_storage wrapped in try-catch
      try {
        token = await _secureStorage?.read(key: _accessTokenKey);
      } catch (_) {}
    } else if (_secureStorage != null) {
      token = await _secureStorage.read(key: _accessTokenKey);
    }
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('[API] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('[API] Error: ${err.message}');
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = _mapError(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: ServerException(message: message, statusCode: err.response?.statusCode),
      type: err.type,
      response: err.response,
    ));
  }

  String _mapError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'اتصال مهلة. تحقق من اتصالك بالإنترنت.';
      case DioExceptionType.connectionError:
        return 'لا يمكن الاتصال بالخادم.';
      case DioExceptionType.badResponse:
        return err.response?.data?['message'] ?? 'حدث خطأ في الخادم.';
      default:
        return 'حدث خطأ غير متوقع.';
    }
  }
}
