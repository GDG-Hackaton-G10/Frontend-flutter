import 'auth_data_source.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthMockDataSource implements AuthDataSource {
  String? _mockRefreshToken;

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? name,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now().millisecondsSinceEpoch;
    final refresh = 'mock-refresh-$now';
    _mockRefreshToken = refresh;

    return AuthResponseModel(
      accessToken: 'mock-access-$now',
      refreshToken: refresh,
      user: UserModel(
        id: 'mock-user-$now',
        email: email,
        name: name?.trim().isEmpty ?? true ? 'Hackathon User' : name?.trim(),
      ),
    );
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));

    final now = DateTime.now().millisecondsSinceEpoch;
    final refresh = 'mock-refresh-$now';
    _mockRefreshToken = refresh;

    return AuthResponseModel(
      accessToken: 'mock-access-$now',
      refreshToken: refresh,
      user: UserModel(
        id: 'mock-user-1',
        email: email,
        name: 'Hackathon User',
      ),
    );
  }

  @override
  Future<AuthResponseModel> refreshToken({required String refreshToken}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (_mockRefreshToken == null || refreshToken != _mockRefreshToken) {
      throw Exception('Session expired. Please log in again.');
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final newRefresh = 'mock-refresh-$now';
    _mockRefreshToken = newRefresh;

    return AuthResponseModel(
      accessToken: 'mock-access-$now',
      refreshToken: newRefresh,
    );
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _mockRefreshToken = null;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
