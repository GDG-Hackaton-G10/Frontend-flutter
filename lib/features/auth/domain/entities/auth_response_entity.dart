import 'user_entity.dart';

class AuthResponseEntity {
  final String accessToken;
  final String refreshToken;
  final UserEntity? user;

  const AuthResponseEntity({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });
}
