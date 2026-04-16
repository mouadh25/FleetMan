import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mzuippdkhsqifxacssex.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16dWlwcGRraHNxaWZ4YWNzc2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3MjIzODcsImV4cCI6MjA5MDI5ODM4N30.aZ0TuirWB0CSdjCwCYbaXOauue0zzvHOdKR0Smg_r2Q',
  );

  runApp(const ProviderScope(child: FleetManApp()));
}

class FleetManApp extends ConsumerWidget {
  const FleetManApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FleetMan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'DZ'),
        Locale('ar', 'DZ'),
      ],
      locale: const Locale('fr', 'DZ'),
      routerConfig: router,
    );
  }
}
