import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _storage = const FlutterSecureStorage();

  Future<void> writeToken(String token) async =>
      await _storage.write(key: 'jwt_token', value: token);

  Future<String?> readToken() async => await _storage.read(key: 'jwt_token');

  Future<void> deleteToken() async => await _storage.delete(key: 'jwt_token');
}
