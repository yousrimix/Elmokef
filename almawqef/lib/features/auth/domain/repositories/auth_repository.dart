import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> login({
    String? email,
    String? phone,
    required String password,
  });

  Future<Either<Failure, Map<String, dynamic>>> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  });

  Future<Either<Failure, Map<String, dynamic>>> registerArtisan({
    required String name,
    required String phone,
    String? email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getProfile();

  Future<Either<Failure, String?>> getAccessToken();
  Future<Either<Failure, void>> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<Either<Failure, void>> clearTokens();
  Future<Either<Failure, bool>> isLoggedIn();
}
