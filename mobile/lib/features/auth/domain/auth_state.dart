/// AuthState — Represents the current authentication state.
///
/// Using a simple sealed class pattern instead of Freezed to avoid
/// build_runner dependency for this foundational type.
library;

sealed class AuthState {
  const AuthState();
}

/// Initial state — haven't checked auth yet.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// User is authenticated.
class AuthAuthenticated extends AuthState {
  final String userId;
  final List<String> roles;

  const AuthAuthenticated({
    required this.userId,
    required this.roles,
  });
}

/// User is not authenticated.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication error occurred.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}
