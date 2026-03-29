import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';

/// Provides the concrete [AuthRepository] implementation.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository();
});

/// Watches the Supabase auth state and emits user IDs (or null).
final authStateProvider = StreamProvider<String?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

/// Fetches the authenticated user's roles from the profiles table.
/// Takes a userId as a family parameter.
final userRolesProvider =
    FutureProvider.family<List<String>, String>((ref, userId) async {
  final repo = ref.read(authRepositoryProvider);
  return repo.getUserRoles(userId);
});
