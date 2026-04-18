import '../repositories/auth_repository.dart';

class RequestPasswordReset {
  final AuthRepository _repository;

  RequestPasswordReset(this._repository);

  Future<void> call({required String email}) {
    return _repository.requestPasswordReset(email: email);
  }
}
