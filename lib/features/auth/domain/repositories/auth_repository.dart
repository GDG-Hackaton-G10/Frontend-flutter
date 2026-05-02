import '../entities/auth_response_entity.dart';
import '../../../../core/auth/user_role.dart';

abstract class AuthRepository {
  Future<AuthResponseEntity> register({
    required String email,
    required String password,
    required UserRole role,
    String? name,
  });

  Future<AuthResponseEntity> login({
    required String email,
    required String password,
  });

  Future<String> refreshToken();

  Future<void> logout();

  Future<void> requestPasswordReset({required String email});

  Future<bool> isLoggedIn();

  Future<String?> getAccessToken();
}
