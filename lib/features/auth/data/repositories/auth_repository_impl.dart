import '../../../../core/network/auth_api_client.dart';
import '../../../../core/auth/user_role.dart';

import '../../domain/entities/auth_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';
import '../datasources/token_secure_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _remoteDataSource;
  final TokenSecureStorage _tokenStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  @override
  @override
  Future<AuthResponseEntity> register({
    required String email,
    required String password,
    required UserRole role,
    String? name,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        email: email,
        password: password,
        role: role,
        name: name,
      );

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      return response;
    } on AuthApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<AuthResponseEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      return response;
    } on AuthApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<String> refreshToken() async {
    try {
      final currentRefreshToken = await _tokenStorage.readRefreshToken();
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        throw Exception('Refresh token is missing.');
      }

      final response = await _remoteDataSource.refreshToken(
        refreshToken: currentRefreshToken,
      );

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      return response.accessToken;
    } on AuthApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _remoteDataSource.logout(refreshToken: refreshToken);
      }
    } catch (_) {
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _remoteDataSource.requestPasswordReset(email: email);
    } on AuthApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final accessToken = await _tokenStorage.readAccessToken();
    final refreshToken = await _tokenStorage.readRefreshToken();
    return (accessToken?.isNotEmpty ?? false) &&
        (refreshToken?.isNotEmpty ?? false);
  }

  @override
  Future<String?> getAccessToken() {
    return _tokenStorage.readAccessToken();
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return message;
  }
}
