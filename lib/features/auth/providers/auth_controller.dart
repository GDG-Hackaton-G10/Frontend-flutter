import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_providers.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login_user.dart';
import '../domain/usecases/logout_user.dart';
import '../domain/usecases/register_user.dart';
import '../domain/usecases/request_password_reset.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
      ref.watch(authSessionVersionProvider);

      final controller = AuthController(
        authRepository: ref.watch(authRepositoryProvider),
        registerUser: ref.watch(registerUserProvider),
        loginUser: ref.watch(loginUserProvider),
        logoutUser: ref.watch(logoutUserProvider),
        requestPasswordReset: ref.watch(requestPasswordResetProvider),
      );

      controller.initialize();
      return controller;
    });

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required AuthRepository authRepository,
    required RegisterUser registerUser,
    required LoginUser loginUser,
    required LogoutUser logoutUser,
    required RequestPasswordReset requestPasswordReset,
  })  : _authRepository = authRepository,
        _registerUser = registerUser,
        _loginUser = loginUser,
        _logoutUser = logoutUser,
        _requestPasswordReset = requestPasswordReset,
        super(const AuthState());

  final AuthRepository _authRepository;
  final RegisterUser _registerUser;
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final RequestPasswordReset _requestPasswordReset;

  bool _busy = false;

  Future<void> initialize() async {
    if (state.status == AuthStatus.loading) {
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);

    try {
      final loggedIn = await _authRepository.isLoggedIn();
      state = state.copyWith(
        status: loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated,
        clearMessage: true,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        message: 'Unable to verify your session. Please log in.',
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? name,
  }) async {
    if (_busy) {
      return;
    }

    _busy = true;
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);

    try {
      await _registerUser(email: email, password: password, name: name);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        message: 'Account created successfully.',
      );
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (_busy) {
      return;
    }

    _busy = true;
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);

    try {
      await _loginUser(email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        message: 'Welcome back!',
      );
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> logout() async {
    if (_busy) {
      return;
    }

    _busy = true;
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);

    try {
      await _logoutUser();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        message: 'Logged out securely.',
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        message: 'Logged out locally.',
      );
    } finally {
      _busy = false;
    }
  }

  Future<bool> requestPasswordReset({required String email}) async {
    if (_busy) {
      return false;
    }

    _busy = true;
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);

    try {
      await _requestPasswordReset(email: email);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        message: 'Password reset link sent to your email.',
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        message: error.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    } finally {
      _busy = false;
    }
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(status: AuthStatus.unauthenticated, clearMessage: true);
    }
  }
}
