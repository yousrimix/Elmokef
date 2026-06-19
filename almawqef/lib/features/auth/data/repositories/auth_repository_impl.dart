import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

const _accessTokenKey = 'access_token';
const _refreshTokenKey = 'refresh_token';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final FlutterSecureStorage? _secureStorage;

  // Token storage using flutter_secure_storage with try-catch for web
  Future<String?> _readToken(String key) async {
    try { return await _secureStorage?.read(key: key); } catch (_) { return null; }
  }

  Future<void> _writeToken(String key, String value) async {
    try { await _secureStorage?.write(key: key, value: value); } catch (_) {}
  }

  Future<void> _deleteToken(String key) async {
    try { await _secureStorage?.delete(key: key); } catch (_) {}
  }

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required FlutterSecureStorage? secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo,
        _secureStorage = secureStorage;

  @override
  Future<Either<Failure, Map<String, dynamic>>> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.login(
        email: email,
        phone: phone,
        password: password,
      );
      // result shape from backend: { user: { ... }, accessToken, refreshToken }
      final accessToken = result['accessToken'] as String?;
      final refreshToken = result['refreshToken'] as String?;
      if (accessToken != null) await _writeToken(_accessTokenKey, accessToken);
      if (refreshToken != null) await _writeToken(_refreshTokenKey, refreshToken);
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String? ?? 'فشل تسجيل الدخول';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );
      final accessToken = result['accessToken'] as String?;
      final refreshToken = result['refreshToken'] as String?;
      if (accessToken != null) await _writeToken(_accessTokenKey, accessToken);
      if (refreshToken != null) await _writeToken(_refreshTokenKey, refreshToken);
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String? ?? 'فشل إنشاء الحساب';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> registerArtisan({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.registerArtisan(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );
      final accessToken = result['accessToken'] as String?;
      final refreshToken = result['refreshToken'] as String?;
      if (accessToken != null) await _writeToken(_accessTokenKey, accessToken);
      if (refreshToken != null) await _writeToken(_refreshTokenKey, refreshToken);
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String? ?? 'فشل إنشاء حساب الحرفي';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Even if server logout fails, clear local tokens
    }
    await _deleteToken(_accessTokenKey);
    await _deleteToken(_refreshTokenKey);
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final user = await _remoteDataSource.getProfile();
      return Right(user);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String? ?? 'فشل تحميل الملف الشخصي';
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, String?>> getAccessToken() async {
    final token = await _readToken(_accessTokenKey);
    return Right(token);
  }

  @override
  Future<Either<Failure, void>> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _writeToken(_accessTokenKey, accessToken);
    await _writeToken(_refreshTokenKey, refreshToken);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearTokens() async {
    await _deleteToken(_accessTokenKey);
    await _deleteToken(_refreshTokenKey);
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    final token = await _readToken(_accessTokenKey);
    return Right(token != null && token.isNotEmpty);
  }
}
