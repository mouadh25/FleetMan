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
    required String companyName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'company_name': companyName},
      );

      // If Supabase natively enforces Confirm Email, session is null.
      // Our database trigger automatically sets email_confirmed_at = NOW() upon insert.
      // So we immediately attempt sign-in to create the session seamlessly.
      if (response.session == null) {
        await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }

      final userId = response.user?.id ?? _client.auth.currentUser?.id;
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
}
