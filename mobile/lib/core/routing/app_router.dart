import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/home/presentation/ceo_home_stub.dart';
import '../../features/home/presentation/driver_home_stub.dart';
import '../../features/home/presentation/gatekeeper_home_stub.dart';
import '../../features/home/presentation/mechanic_home_stub.dart';
import '../../features/home/presentation/park_manager_home_stub.dart';
import '../../features/scanner/presentation/qr_scanner_screen.dart';
import '../../features/audit/presentation/audit_form_screen.dart';
import '../../features/vehicles/domain/vehicle.dart';

/// The role priority order for routing.
/// CEO > PARK_MANAGER > MECHANIC > GATEKEEPER > DRIVER
const _rolePriority = [
  'CEO',
  'PARK_MANAGER',
  'MECHANIC',
  'GATEKEEPER',
  'DRIVER',
];

/// Maps a role to its home route path.
String _roleToPath(String role) {
  switch (role) {
    case 'CEO':
      return '/home/ceo';
    case 'PARK_MANAGER':
      return '/home/park-manager';
    case 'MECHANIC':
      return '/home/mechanic';
    case 'GATEKEEPER':
      return '/home/gatekeeper';
    case 'DRIVER':
      return '/home/driver';
    default:
      return '/home/driver';
  }
}

/// Selects the highest-priority role from a list of roles.
String _selectPrimaryRole(List<String> roles) {
  for (final priority in _rolePriority) {
    if (roles.contains(priority)) return priority;
  }
  return 'DRIVER'; // fallback
}

/// Provider for the GoRouter instance, wired to auth state.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthenticated = session != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Not authenticated → force login
      if (!isAuthenticated) {
        return isAuthRoute ? null : '/login';
      }

      // Authenticated but on login/register → route to role home
      if (isAuthRoute) {
        final userId = Supabase.instance.client.auth.currentUser!.id;
        try {
          final roles =
              await ref.read(authRepositoryProvider).getUserRoles(userId);
          final primaryRole = _selectPrimaryRole(roles);
          return _roleToPath(primaryRole);
        } catch (_) {
          return '/home/driver'; // fallback on error
        }
      }

      return null; // no redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home/park-manager',
        builder: (context, state) => const ParkManagerHomeStub(),
      ),
      GoRoute(
        path: '/home/mechanic',
        builder: (context, state) => const MechanicHomeStub(),
      ),
      GoRoute(
        path: '/home/driver',
        builder: (context, state) => const DriverHomeStub(),
      ),
      GoRoute(
        path: '/home/ceo',
        builder: (context, state) => const CeoHomeStub(),
      ),
      GoRoute(
        path: '/home/gatekeeper',
        builder: (context, state) => const GatekeeperHomeScreen(),
      ),
      GoRoute(
        path: '/qr-scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),
      GoRoute(
        path: '/audit-form',
        builder: (context, state) {
          final vehicle = state.extra as Vehicle;
          return AuditFormScreen(vehicle: vehicle);
        },
      ),
    ],
  );
});

/// Listenable that notifies GoRouter when auth state changes.
class _AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  _AuthNotifier(Ref ref) {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
