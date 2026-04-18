import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository _repository;

  RegisterUser(this._repository);

  Future<AuthResponseEntity> call({
    required String email,
    required String password,
    String? name,
  }) {
    return _repository.register(email: email, password: password, name: name);
  }
}
