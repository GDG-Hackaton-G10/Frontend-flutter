import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient extends http.BaseClient {
  ApiClient({
    http.Client? innerClient,
    FlutterSecureStorage? secureStorage,
    Future<void> Function()? onUnauthorized,
  }) : _innerClient = innerClient ?? http.Client(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _onUnauthorized = onUnauthorized;

  final http.Client _innerClient;
  final FlutterSecureStorage _secureStorage;
  final Future<void> Function()? _onUnauthorized;

  static const String _accessTokenKey = 'accessToken';

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final hasToken = accessToken != null && accessToken.isNotEmpty;

    if (hasToken) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    final streamedResponse = await _innerClient.send(request);

    if (streamedResponse.statusCode == 401 && hasToken) {
      await _onUnauthorized?.call();
    }

    return streamedResponse;
  }

  @override
  void close() {
    _innerClient.close();
  }
}
