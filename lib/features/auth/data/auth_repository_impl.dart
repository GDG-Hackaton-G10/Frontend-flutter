import 'auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';
import '../../../core/services/secure_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<AppUser?> getCurrentUser() async {
    final token = await SecureStorageService().readToken();
    if (token == null) return null;
    // TODO: Decode JWT and fetch user info
    // For now, return a mock user
    return AppUser(id: '1', role: UserRole.patient);
  }

  @override
  Future<void> signIn(String username, String password) async {
    // TODO: Implement real sign in
    await SecureStorageService().writeToken('mock_jwt_token');
  }

  @override
  Future<void> signOut() async {
    await SecureStorageService().deleteToken();
  }
}
