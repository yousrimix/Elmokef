import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> execute({
    String? email,
    String? phone,
    required String password,
  }) {
    return _repository.login(email: email, phone: phone, password: password);
  }
}
