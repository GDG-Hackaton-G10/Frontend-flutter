import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import '../../features/auth/data/datasources/token_secure_storage.dart';
import '../../features/auth/data/interceptors/auth_interceptor.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenSecureStorageProvider = Provider<TokenSecureStorage>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return TokenSecureStorage(secureStorage);
});

final authSessionVersionProvider = StateProvider<int>((ref) => 0);

// This replaces the GetIt injection container for the Network layer
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://your-api.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  final tokenStorage = ref.watch(tokenSecureStorageProvider);

  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      tokenStorage: tokenStorage,
      onSessionExpired: () {
        ref.read(authSessionVersionProvider.notifier).state++;
      },
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
