enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? message;

  const AuthState({
    this.status = AuthStatus.initial,
    this.message,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
