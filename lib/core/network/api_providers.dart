import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';

// This replaces the GetIt injection container for the Network layer
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://your-api.com/api',
      connectTimeout: const Duration(seconds: 5),
    ),
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
