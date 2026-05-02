import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/entities/auth_response_entity.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../auth/user_role.dart';
import '../network/api_providers.dart';

class AuthState {
  final UserRole role;
  final bool isAuthenticated;
  final bool isProfileComplete;
  final String? email;
  final String? uid;
  final bool isLoading;

  const AuthState({
    this.role = UserRole.guest,
    this.isAuthenticated = false,
    this.isProfileComplete = false,
    this.email,
    this.uid,
    this.isLoading = false,
  });

  AuthState copyWith({
    UserRole? role,
    bool? isAuthenticated,
    bool? isProfileComplete,
    String? email,
    String? uid,
    bool? isLoading,
  }) {
    return AuthState(
      role: role ?? this.role,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState()) {
    _ref.listen<int>(authSessionVersionProvider, (previous, next) {
      if (previous != null && previous != next) {
        unawaited(logout(clearRemoteSession: false));
      }
    });
    _loadFromPrefs();
  }

  final Ref _ref;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      final roleStr = prefs.getString('role');
      final email = prefs.getString('email');
      final uid = prefs.getString('uid');
      final isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
      final role = UserRole.values.firstWhere(
        (e) => e.toString() == roleStr,
        orElse: () => UserRole.guest,
      );

      state = state.copyWith(
        isAuthenticated: isLoggedIn,
        role: role,
        email: email,
        uid: uid,
        isProfileComplete: isProfileComplete,
      );
      return;
    }

    // If SharedPreferences does not indicate a logged-in state, try secure storage.
    try {
      final tokenStorage = _ref.read(tokenSecureStorageProvider);
      final accessToken = await tokenStorage.readAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        // We have a token but no prefs; treat user as authenticated.
        final roleStr = prefs.getString('role');
        final role = UserRole.values.firstWhere(
          (e) => e.toString() == roleStr,
          orElse: () => UserRole.patient,
        );

        state = state.copyWith(
          isAuthenticated: true,
          role: role,
          email: prefs.getString('email'),
          uid: prefs.getString('uid'),
          isProfileComplete: prefs.getBool('isProfileComplete') ?? false,
        );
        await _saveToPrefs();
      }
    } catch (_) {
      // Ignore secure storage read errors and continue as logged out.
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', state.isAuthenticated);
    await prefs.setString('role', state.role.toString());
    await prefs.setString('email', state.email ?? '');
    await prefs.setString('uid', state.uid ?? '');
    await prefs.setBool('isProfileComplete', state.isProfileComplete);
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('role');
    await prefs.remove('email');
    await prefs.remove('uid');
    await prefs.setBool('isProfileComplete', false);
  }

  Future<void> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _ref
          .read(authServiceProvider)
          .login(email: email, password: password);
      await _applySession(response, role: role, fallbackEmail: email);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required UserRole role,
    String? name,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _ref
          .read(authServiceProvider)
          .register(email: email, password: password, role: role, name: name);
      await _applySession(response, role: role, fallbackEmail: email);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> requestPasswordReset({required String email}) {
    return _ref.read(authServiceProvider).requestPasswordReset(email: email);
  }

  Future<void> logout({bool clearRemoteSession = true}) async {
    if (clearRemoteSession) {
      try {
        await _ref.read(authServiceProvider).logout();
      } catch (_) {
        // Always clear local session state, even if the remote logout fails.
      }
    }

    state = const AuthState();
    await _clearPrefs();
  }

  void loginAsPatient(String email, String uid) {
    _applyLocalSession(
      role: UserRole.patient,
      email: email,
      uid: uid,
      profileComplete: false,
    );
  }

  void loginAsPharmacy(String email, String uid) {
    _applyLocalSession(
      role: UserRole.pharmacy,
      email: email,
      uid: uid,
      profileComplete: true,
    );
  }

  void updateProfileStatus(bool complete) {
    state = state.copyWith(isProfileComplete: complete);
    unawaited(_saveToPrefs());
  }

  Future<void> _applySession(
    AuthResponseEntity response, {
    required UserRole role,
    required String fallbackEmail,
  }) async {
    final user = response.user;
    final resolvedEmail = user?.email.isNotEmpty == true
        ? user!.email
        : fallbackEmail;
    final resolvedUid = user?.id.isNotEmpty == true
        ? user!.id
        : 'uid_${DateTime.now().millisecondsSinceEpoch}';

    state = state.copyWith(
      role: role,
      isAuthenticated: true,
      email: resolvedEmail,
      uid: resolvedUid,
      isProfileComplete: role == UserRole.pharmacy,
    );
    await _saveToPrefs();
  }

  void _applyLocalSession({
    required UserRole role,
    required String email,
    required String uid,
    required bool profileComplete,
  }) {
    state = state.copyWith(
      role: role,
      isAuthenticated: true,
      email: email,
      uid: uid,
      isProfileComplete: profileComplete,
      isLoading: false,
    );
    unawaited(_saveToPrefs());
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
