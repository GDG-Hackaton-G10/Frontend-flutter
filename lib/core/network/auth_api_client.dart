import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/auth/data/datasources/token_secure_storage.dart';
import 'api_constants.dart';

class AuthApiException implements Exception {
  AuthApiException(this.message, {this.statusCode, this.payload});

  final String message;
  final int? statusCode;
  final Object? payload;

  @override
  String toString() => message;
}

class AuthApiClient {
  AuthApiClient({
    required TokenSecureStorage tokenStorage,
    http.Client? client,
    this.onUnauthorized,
    String? baseUrl,
  }) : _tokenStorage = tokenStorage,
       _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  final TokenSecureStorage _tokenStorage;
  final http.Client _client;
  final String _baseUrl;
  final Future<void> Function()? onUnauthorized;

  Future<Map<String, dynamic>> getJson(
    String path, {
    bool includeAuth = true,
    Map<String, String>? queryParameters,
  }) async {
    final request = http.Request('GET', _buildUri(path, queryParameters));
    await _applyHeaders(request, includeAuth: includeAuth);
    return _sendAndDecode(request);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    bool includeAuth = true,
  }) async {
    final request = http.Request('POST', _buildUri(path));
    await _applyHeaders(request, includeAuth: includeAuth);
    if (body != null) {
      request.body = jsonEncode(body);
    }
    return _sendAndDecode(request);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Object? body,
    bool includeAuth = true,
  }) async {
    final request = http.Request('PUT', _buildUri(path));
    await _applyHeaders(request, includeAuth: includeAuth);
    if (body != null) {
      request.body = jsonEncode(body);
    }
    return _sendAndDecode(request);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    bool includeAuth = true,
    Object? body,
  }) async {
    final request = http.Request('DELETE', _buildUri(path));
    await _applyHeaders(request, includeAuth: includeAuth);
    if (body != null) {
      request.body = jsonEncode(body);
    }
    return _sendAndDecode(request);
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final sanitizedPath = path.startsWith('/') ? path.substring(1) : path;
    final baseUri = Uri.parse('$_baseUrl/');
    return baseUri.resolveUri(
      Uri(path: sanitizedPath, queryParameters: queryParameters),
    );
  }

  Future<void> _applyHeaders(
    http.BaseRequest request, {
    required bool includeAuth,
  }) async {
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';

    if (!includeAuth) {
      return;
    }

    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
  }

  Future<Map<String, dynamic>> _sendAndDecode(http.Request request) async {
    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    final decodedBody = _decodeBody(response.body);
    if (response.statusCode == 401) {
      await _tokenStorage.clearTokens();
      if (onUnauthorized != null) {
        await onUnauthorized!();
      }
      throw AuthApiException(
        _extractMessage(decodedBody, response.statusCode),
        statusCode: response.statusCode,
        payload: decodedBody,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Log body for debugging server validation errors (e.g., HTTP 400)
      try {
        // Avoid leaking auth tokens — this is just for request/response diagnostics.
        // Print raw response body to console to help debug backend validation messages.
        // You may remove or guard this in production.
        // ignore: avoid_print
        print(
          'AuthApiClient response (${response.statusCode}): ${response.body}',
        );
      } catch (_) {}

      throw AuthApiException(
        _extractMessage(decodedBody, response.statusCode),
        statusCode: response.statusCode,
        payload: decodedBody,
      );
    }

    if (decodedBody is Map<String, dynamic>) {
      return decodedBody;
    }

    return {'data': decodedBody};
  }

  Object? _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return const <String, dynamic>{};
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _extractMessage(Object? decodedBody, int statusCode) {
    if (decodedBody is Map<String, dynamic>) {
      for (final key in ['message', 'error', 'detail', 'title']) {
        final value = decodedBody[key];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }

      final data = decodedBody['data'];
      if (data is Map<String, dynamic>) {
        for (final key in ['message', 'error', 'detail', 'title']) {
          final value = data[key];
          if (value is String && value.trim().isNotEmpty) {
            return value;
          }
        }
      }
    }

    if (decodedBody is String && decodedBody.trim().isNotEmpty) {
      return decodedBody;
    }

    return 'Request failed (HTTP $statusCode).';
  }
}
