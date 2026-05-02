import '../entities/auth_response_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/auth/user_role.dart';

class RegisterUser {
  final AuthRepository _repository;

  RegisterUser(this._repository);

  Future<AuthResponseEntity> call({
    required String email,
    required String password,
    required UserRole role,
    String? name,
  }) {
    return _repository.register(
      email: email,
      password: password,
      role: role,
      name: name,
    );
  }
}
