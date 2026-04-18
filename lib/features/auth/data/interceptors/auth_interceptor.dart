import 'dart:async';

import 'package:dio/dio.dart';

import '../datasources/token_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenSecureStorage tokenStorage,
    required FutureOr<void> Function() onSessionExpired,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final TokenSecureStorage _tokenStorage;
  final FutureOr<void> Function() _onSessionExpired;

  Completer<void>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skipAuth = options.extra['skipAuthRefresh'] == true;

    if (!skipAuth) {
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final is401 = err.response?.statusCode == 401;
    final wasRetried = request.extra['retried'] == true;
    final skipAuth = request.extra['skipAuthRefresh'] == true;
    final path = request.path;
    final isRefreshEndpoint = path.contains('/api/v1/auth/refresh-token');

    if (!is401 || wasRetried || skipAuth || isRefreshEndpoint) {
      handler.next(err);
      return;
    }

    try {
      await _refreshIfNeeded();

      final newToken = await _tokenStorage.readAccessToken();
      if (newToken == null || newToken.isEmpty) {
        throw Exception('No access token after refresh.');
      }

      final clonedRequest = await _retryRequest(request, newToken);
      handler.resolve(clonedRequest);
    } catch (_) {
      await _tokenStorage.clearTokens();
      await _onSessionExpired();
      handler.next(err);
    }
  }

  Future<void> _refreshIfNeeded() async {
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      return;
    }

    _refreshCompleter = Completer<void>();

    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token available.');
      }

      final response = await _dio.post(
        '/api/v1/auth/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'skipAuthRefresh': true}),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid refresh token response.');
      }

      final body = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;

      final accessToken = (body['accessToken'] ?? '').toString();
      final newRefreshToken = (body['refreshToken'] ?? refreshToken).toString();

      if (accessToken.isEmpty) {
        throw Exception('Missing access token in refresh response.');
      }

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );

      _refreshCompleter?.complete();
    } catch (error) {
      _refreshCompleter?.completeError(error);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions request,
    String accessToken,
  ) {
    final options = Options(
      method: request.method,
      headers: {
        ...request.headers,
        'Authorization': 'Bearer $accessToken',
      },
      responseType: request.responseType,
      contentType: request.contentType,
      validateStatus: request.validateStatus,
      receiveDataWhenStatusError: request.receiveDataWhenStatusError,
      followRedirects: request.followRedirects,
      maxRedirects: request.maxRedirects,
      requestEncoder: request.requestEncoder,
      responseDecoder: request.responseDecoder,
      listFormat: request.listFormat,
      extra: {
        ...request.extra,
        'retried': true,
      },
    );

    return _dio.request<dynamic>(
      request.path,
      data: request.data,
      queryParameters: request.queryParameters,
      options: options,
      cancelToken: request.cancelToken,
      onReceiveProgress: request.onReceiveProgress,
      onSendProgress: request.onSendProgress,
    );
  }
}
