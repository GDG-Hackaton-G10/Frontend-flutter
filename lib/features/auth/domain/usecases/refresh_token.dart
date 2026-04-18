import '../repositories/auth_repository.dart';

class RefreshToken {
  final AuthRepository _repository;

  RefreshToken(this._repository);

  Future<String> call() {
    return _repository.refreshToken();
  }
}
