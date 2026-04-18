import 'package:dio/dio.dart';

import 'auth_data_source.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDataSource implements AuthDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _dio.post(
      '/api/v1/auth/register',
      data: {
        'email': email,
        'password': password,
        if (name != null && name.trim().isNotEmpty) 'name': name,
      },
    );

    return _parseAuthResponse(response.data);
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/v1/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return _parseAuthResponse(response.data);
  }

  @override
  Future<AuthResponseModel> refreshToken({required String refreshToken}) async {
    final response = await _dio.post(
      '/api/v1/auth/refresh-token',
      data: {'refreshToken': refreshToken},
      options: Options(extra: {'skipAuthRefresh': true}),
    );

    return _parseAuthResponse(response.data);
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await _dio.post(
      '/api/v1/auth/logout',
      data: {'refreshToken': refreshToken},
      options: Options(extra: {'skipAuthRefresh': true}),
    );
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await _dio.post(
      '/api/v1/auth/forgot-password',
      data: {'email': email},
      options: Options(extra: {'skipAuthRefresh': true}),
    );
  }

  AuthResponseModel _parseAuthResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return AuthResponseModel.fromJson(data);
    }
    throw Exception('Invalid authentication response format.');
  }
}
