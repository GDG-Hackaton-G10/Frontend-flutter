import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository _repository;

  LoginUser(this._repository);

  Future<AuthResponseEntity> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
