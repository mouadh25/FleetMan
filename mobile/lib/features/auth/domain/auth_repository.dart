/// AuthRepository — Cloud-agnostic authentication contract.
///
/// The UI layer communicates ONLY with this interface.
/// Concrete implementations (Supabase, Firebase, custom) are injected.
///
/// MVP1: Email/Password (SupabaseAuthRepository)
/// MVP2: Add 6-Digit OTP via signInWithOtp/verifyOtp when SMTP is ready.
library;

abstract class AuthRepository {
  /// Signs in with email and password.
  /// Returns the authenticated user's ID on success.
  /// Throws [AuthException] on failure.
  Future<String> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registers a new user with email/password and optional metadata.
  /// The Supabase trigger `handle_new_user` auto-creates the profile row.
  Future<String> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  /// Signs the current user out and clears the session.
  Future<void> signOut();

  /// Returns the current authenticated user's ID, or null if not signed in.
  String? get currentUserId;

  /// Stream of auth state changes. Emits user ID or null.
  Stream<String?> get authStateChanges;

  /// Fetches the current user's roles from the profiles table.
  /// Returns an empty list if no roles are assigned.
  Future<List<String>> getUserRoles(String userId);

  // ── MVP2: OTP Methods (contract defined now, implemented later) ──

  /// Sends a 6-digit OTP to the given email/phone.
  /// Will throw [UnimplementedError] in MVP1.
  Future<void> signInWithOtp({required String emailOrPhone}) {
    throw UnimplementedError('OTP auth deferred to MVP2 — requires SMTP/SMS relay');
  }

  /// Verifies the OTP code.
  /// Will throw [UnimplementedError] in MVP1.
  Future<String> verifyOtp({
    required String emailOrPhone,
    required String otpCode,
  }) {
    throw UnimplementedError('OTP verification deferred to MVP2');
  }
}

/// Generic auth exception for clean error handling.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}
