import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_providers.dart';

class ParkManagerHomeStub extends ConsumerWidget {
  const ParkManagerHomeStub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RoleHomeScaffold(
      roleName: 'PARK_MANAGER',
      roleIcon: Icons.business_center_rounded,
      roleColor: AppTheme.primaryBlue,
      gradientColors: const [Color(0xFF1A3A5C), Color(0xFF2E5E8E)],
    );
  }
}

/// Shared scaffold for all role home stubs to avoid duplication.
class _RoleHomeScaffold extends ConsumerWidget {
  final String roleName;
  final IconData roleIcon;
  final Color roleColor;
  final List<Color> gradientColors;

  const _RoleHomeScaffold({
    required this.roleName,
    required this.roleIcon,
    required this.roleColor,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '—';
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.appTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppTheme.defaultBorderRadius,
                        ),
                      ),
                      child: Text(
                        '${locale.languageCode}_${locale.countryCode}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Role Badge
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(roleIcon, size: 48, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),

                // Role Name
                Text(
                  roleName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Sign Out
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authRepositoryProvider).signOut();
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    l10n.signOutButton,
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    minimumSize: const Size(
                      double.infinity,
                      AppTheme.minimumTouchTarget,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.defaultBorderRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
