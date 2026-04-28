import '../domain/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Future<void> signIn(String username, String password);
  Future<void> signOut();
}
