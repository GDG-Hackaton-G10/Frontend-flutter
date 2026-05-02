import '../../features/auth/domain/entities/auth_response_entity.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../auth/user_role.dart';

class AuthService {
  AuthService(this._repository);

  final AuthRepository _repository;

  Future<AuthResponseEntity> login({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }

  Future<AuthResponseEntity> register({
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

  Future<void> logout() => _repository.logout();

  Future<void> requestPasswordReset({required String email}) {
    return _repository.requestPasswordReset(email: email);
  }

  Future<bool> isLoggedIn() => _repository.isLoggedIn();

  Future<String?> getAccessToken() => _repository.getAccessToken();
}
