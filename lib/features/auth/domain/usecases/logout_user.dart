import '../repositories/auth_repository.dart';

class LogoutUser {
  final AuthRepository _repository;

  LogoutUser(this._repository);

  Future<void> call() {
    return _repository.logout();
  }
}
