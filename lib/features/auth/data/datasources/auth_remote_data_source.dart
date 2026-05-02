import 'auth_data_source.dart';
import '../models/auth_response_model.dart';
import '../../../../core/network/auth_api_client.dart';
import '../../../../core/auth/user_role.dart';

class AuthRemoteDataSource implements AuthDataSource {
  final AuthApiClient _client;

  AuthRemoteDataSource(this._client);

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required UserRole role,
    String? name,
  }) async {
    final resolvedName = (name != null && name.trim().isNotEmpty)
        ? name
        : email.split('@').first;

    final response = await _client.postJson(
      '/auth/register',
      body: {
        'email': email,
        'password': password,
        'role': role.toString().split('.').last,
        'name': resolvedName,
      },
      includeAuth: false,
    );

    return _parseAuthResponse(response);
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.postJson(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    return _parseAuthResponse(response);
  }

  @override
  Future<AuthResponseModel> refreshToken({required String refreshToken}) async {
    final response = await _client.postJson(
      '/auth/refresh-token',
      body: {'refreshToken': refreshToken},
      includeAuth: false,
    );

    return _parseAuthResponse(response);
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await _client.postJson(
      '/auth/logout',
      body: {'refreshToken': refreshToken},
      includeAuth: false,
    );
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await _client.postJson(
      '/auth/forgot-password',
      body: {'email': email},
      includeAuth: false,
    );
  }

  AuthResponseModel _parseAuthResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return AuthResponseModel.fromJson(data);
    }
    throw Exception('Invalid authentication response format.');
  }
}
