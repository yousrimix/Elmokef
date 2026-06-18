import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> execute({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) {
    return _repository.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
  }
}

class RegisterArtisanUseCase {
  final AuthRepository _repository;

  RegisterArtisanUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> execute({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) {
    return _repository.registerArtisan(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
  }
}
