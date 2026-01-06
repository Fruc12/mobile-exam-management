enum AuthStatus {
  unauthenticated,
  registering,
  emailVerificationRequired,
  otpRequired,
  authenticated,
}

class AuthState {
  final AuthStatus status;
  final String? tempUserId;
  final String? message;

  const AuthState({
    required this.status,
    this.tempUserId,
    this.message,
  });

  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  AuthState copyWith({
    AuthStatus? status,
    String? tempUserId,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      tempUserId: tempUserId ?? this.tempUserId,
      message: message ?? this.message,
    );
  }
}
