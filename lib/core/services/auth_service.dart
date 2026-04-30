import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../auth/user_model.dart';
import '../constants/api_constants.dart';
import '../network/auth_api_client.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final UserModel user;
  final String accessToken;
  final String refreshToken;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>? ?? const {});
    final userJson = (data['user'] as Map<String, dynamic>? ?? const {});

    return AuthSession(
      user: UserModel.fromJson(userJson),
      accessToken: (data['accessToken'] ?? '').toString(),
      refreshToken: (data['refreshToken'] ?? '').toString(),
    );
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
    Future<void> Function()? onUnauthorized,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _client =
           client ??
           ApiClient(
             secureStorage: secureStorage ?? const FlutterSecureStorage(),
             onUnauthorized: onUnauthorized,
           );

  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userKey = 'authUser';

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final success = decoded['success'] == true;

      if (response.statusCode < 200 || response.statusCode >= 300 || !success) {
        final message =
            (decoded['message'] ?? decoded['error'] ?? 'Login failed')
                .toString();
        throw AuthException(message);
      }

      final session = AuthSession.fromJson(decoded);

      await _secureStorage.write(
        key: _accessTokenKey,
        value: session.accessToken,
      );
      await _secureStorage.write(
        key: _refreshTokenKey,
        value: session.refreshToken,
      );
      await _secureStorage.write(
        key: _userKey,
        value: jsonEncode(session.user.toJson()),
      );

      return session;
    } on http.ClientException catch (_) {
      throw AuthException('Network error. Please check your connection.');
    } catch (error) {
      if (error is AuthException) rethrow;
      throw AuthException('Unable to sign in. Please try again.');
    }
  }

  Future<AuthSession?> restoreSession() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    final userJson = await _secureStorage.read(key: _userKey);

    if (accessToken == null || refreshToken == null || userJson == null) {
      return null;
    }

    final decodedUser = jsonDecode(userJson) as Map<String, dynamic>;
    return AuthSession(
      user: UserModel.fromJson(decodedUser),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userKey);
  }
}
