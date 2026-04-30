import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/user_model.dart';
import '../auth/user_role.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.role = UserRole.guest,
    this.isAuthenticated = false,
    this.isProfileComplete = false,
    this.email,
    this.uid,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserRole role;
  final bool isAuthenticated;
  final bool isProfileComplete;
  final String? email;
  final String? uid;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserRole? role,
    bool? isAuthenticated,
    bool? isProfileComplete,
    String? email,
    String? uid,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      role: role ?? this.role,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _authService = AuthService(onUnauthorized: logout);
    state = state.copyWith(status: AuthStatus.loading, clearErrorMessage: true);
    _loadFromPrefs();
  }

  late final AuthService _authService;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!isLoggedIn) {
      state = const AuthState(status: AuthStatus.initial);
      return;
    }

    final roleStr = prefs.getString('role');
    final email = prefs.getString('email');
    final uid = prefs.getString('uid');
    final role = UserRole.values.firstWhere(
      (e) => e.toString() == roleStr,
      orElse: () => UserRole.guest,
    );

    state = state.copyWith(
      status: AuthStatus.authenticated,
      isAuthenticated: isLoggedIn,
      role: role,
      email: email,
      uid: uid,
      isLoading: false,
      clearErrorMessage: true,
    );
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', state.isAuthenticated);
    await prefs.setString('role', state.role.toString());
    await prefs.setString('email', state.email ?? '');
    await prefs.setString('uid', state.uid ?? '');
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      isLoading: true,
      clearErrorMessage: true,
    );

    try {
      final session = await _authService.login(
        email: email,
        password: password,
      );
      final UserModel user = session.user;

      state = state.copyWith(
        status: AuthStatus.authenticated,
        role: user.role,
        isAuthenticated: true,
        email: user.email,
        uid: user.id,
        isLoading: false,
        clearErrorMessage: true,
      );
      await _saveToPrefs();
      return true;
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        isLoading: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  void loginAsPatient(String email, String uid) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      role: UserRole.patient,
      isAuthenticated: true,
      email: email,
      uid: uid,
      isLoading: false,
      clearErrorMessage: true,
    );
    _saveToPrefs();
  }

  void loginAsPharmacy(String email, String uid) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      role: UserRole.pharmacy,
      isAuthenticated: true,
      email: email,
      uid: uid,
      isLoading: false,
      clearErrorMessage: true,
    );
    _saveToPrefs();
  }

  void updateProfileStatus(bool complete) {
    state = state.copyWith(isProfileComplete: complete);
    _saveToPrefs();
  }

  Future<void> logout() async {
    await _authService.clearSession();
    state = const AuthState(status: AuthStatus.initial);
    await _saveToPrefs();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
