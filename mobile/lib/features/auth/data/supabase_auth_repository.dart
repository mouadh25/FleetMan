import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../domain/auth_repository.dart';

/// Concrete Supabase implementation of [AuthRepository].
///
/// MVP1: Email/Password authentication.
/// All Supabase-specific errors are caught and wrapped in [AuthException].
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final userId = response.user?.id;
      if (userId == null) {
        throw const AuthException('Sign-in succeeded but no user ID returned');
      }
      return userId;
    } on AuthApiException catch (e) {
      throw AuthException(e.message, code: e.code);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Unexpected sign-in error: $e');
    }
  }

  @override
  Future<String> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      final userId = response.user?.id;
      if (userId == null) {
        throw const AuthException('Sign-up succeeded but no user ID returned');
      }
      return userId;
    } on AuthApiException catch (e) {
      throw AuthException(e.message, code: e.code);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Unexpected sign-up error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthApiException catch (e) {
      throw AuthException(e.message, code: e.code);
    } catch (e) {
      throw AuthException('Unexpected sign-out error: $e');
    }
  }

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Stream<String?> get authStateChanges {
    return _client.auth.onAuthStateChange.map(
      (event) => event.session?.user.id,
    );
  }

  @override
  Future<List<String>> getUserRoles(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('roles')
          .eq('id', userId)
          .single();
      final roles = response['roles'] as List<dynamic>?;
      if (roles == null) return [];
      return roles.cast<String>();
    } on PostgrestException catch (e) {
      throw AuthException(
        'Failed to fetch user roles: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw AuthException('Unexpected error fetching roles: $e');
    }
  }

  @override
  Future<void> signInWithOtp({required String phone}) {
    throw UnimplementedError('OTP features are deferred to MVP2');
  }

  @override
  Future<String> verifyOtp({required String phone, required String otp}) {
    throw UnimplementedError('OTP features are deferred to MVP2');
  }
}
