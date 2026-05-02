import '../models/auth_response_model.dart';
import '../../../../core/auth/user_role.dart';

abstract class AuthDataSource {
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required UserRole role,
    String? name,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> refreshToken({required String refreshToken});

  Future<void> logout({required String refreshToken});

  Future<void> requestPasswordReset({required String email});
}
