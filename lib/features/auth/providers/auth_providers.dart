import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_providers.dart';
import '../../../core/services/auth_service.dart';
import '../data/datasources/auth_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login_user.dart';
import '../domain/usecases/logout_user.dart';
import '../domain/usecases/refresh_token.dart';
import '../domain/usecases/register_user.dart';
import '../domain/usecases/request_password_reset.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(authApiClientProvider);
  return AuthRemoteDataSource(client);
});

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return ref.watch(authRemoteDataSourceProvider);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  final tokenStorage = ref.watch(tokenSecureStorageProvider);
  return AuthRepositoryImpl(dataSource, tokenStorage);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthService(repository);
});

final registerUserProvider = Provider<RegisterUser>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUser(repository);
});

final loginUserProvider = Provider<LoginUser>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUser(repository);
});

final refreshTokenUseCaseProvider = Provider<RefreshToken>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RefreshToken(repository);
});

final logoutUserProvider = Provider<LogoutUser>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUser(repository);
});

final requestPasswordResetProvider = Provider<RequestPasswordReset>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RequestPasswordReset(repository);
});
