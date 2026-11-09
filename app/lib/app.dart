import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/locale.dart';
import 'core/supabase.dart';
import 'features/auth/login_screen.dart';
import 'features/preferences/preferences_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/swipe/swipe_screen.dart';
import 'l10n/app_localizations.dart';

final _router = GoRouter(
  initialLocation: '/',
  refreshListenable: _AuthRefresh(),
  redirect: (context, state) {
    final signedIn = db.auth.currentSession != null;
    final atLogin = state.matchedLocation == '/login';
    if (!signedIn) return atLogin ? null : '/login';
    if (atLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/', builder: (_, __) => const SwipeScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/preferences', builder: (_, __) => const PreferencesScreen()),
  ],
);

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh() {
    db.auth.onAuthStateChange.listen((AuthState _) => notifyListeners());
  }
}

class MitmateApp extends ConsumerWidget {
  const MitmateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'Mitmate',
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2F6F5E),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF2F6F5E),
      ),
      routerConfig: _router,
    );
  }
}
