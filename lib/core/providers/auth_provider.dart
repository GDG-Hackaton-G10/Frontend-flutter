import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/user_role.dart';

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
  AuthNotifier() : super(const AuthState()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!isLoggedIn) return;
    final roleStr = prefs.getString('role');
    final email = prefs.getString('email');
    final uid = prefs.getString('uid');
    final role = UserRole.values.firstWhere(
      (e) => e.toString() == roleStr,
      orElse: () => UserRole.guest,
    );
    state = state.copyWith(
      isAuthenticated: isLoggedIn,
      role: role,
      email: email,
      uid: uid,
    );
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', state.isAuthenticated);
    await prefs.setString('role', state.role.toString());
    await prefs.setString('email', state.email ?? '');
    await prefs.setString('uid', state.uid ?? '');
  }

  void loginAsPatient(String email, String uid) {
    state = state.copyWith(
      role: UserRole.patient,
      isAuthenticated: true,
      email: email,
      uid: uid,
      isLoading: false,
    );
    _saveToPrefs();
  }

  void loginAsPharmacy(String email, String uid) {
    state = state.copyWith(
      role: UserRole.pharmacy,
      isAuthenticated: true,
      email: email,
      uid: uid,
      isLoading: false,
    );
    _saveToPrefs();
  }

  void updateProfileStatus(bool complete) {
    state = state.copyWith(isProfileComplete: complete);
    _saveToPrefs();
  }

  void logout() {
    state = const AuthState();
    _saveToPrefs();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
