import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/locale.dart';
import '../../core/supabase.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Welcome screen: wordmark, animated swipe hero, log in and sign up.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _submit({required bool signUp}) async {
    final t = AppLocalizations.of(context)!;
    setState(() { _busy = true; _error = null; });
    try {
      final email = _email.text.trim();
      if (signUp) {
        await db.auth.signUp(email: email, password: _password.text);
        if (mounted) context.go('/verify', extra: email);
      } else {
        await db.auth.signInWithPassword(email: email, password: _password.text);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = t.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const MitmateWordmark(),
                  Row(children: [
                    Pill(label: 'DE', selected: locale.languageCode == 'de', onTap: () => ref.read(localeProvider.notifier).state = const Locale('de')),
                    const SizedBox(width: 4),
                    Pill(label: 'EN', selected: locale.languageCode == 'en', onTap: () => ref.read(localeProvider.notifier).state = const Locale('en')),
                  ]),
                ]),
                const SizedBox(height: 16),
                const SwipeHero(),
                const SizedBox(height: 16),
                Text(t.headline, style: serif(size: 24, color: MC.mute, height: 1.33)),
                const SizedBox(height: 8),
                Text(t.tagline, style: const TextStyle(fontSize: 16, height: 1.5, color: MC.mute)),
                const SizedBox(height: 16),
                TextField(controller: _email, decoration: InputDecoration(labelText: t.email), keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email]),
                const SizedBox(height: 14),
                TextField(controller: _password, decoration: InputDecoration(labelText: t.password), obscureText: true, autofillHints: const [AutofillHints.password]),
                if (_error != null)
                  Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: MC.warn))),
                const SizedBox(height: 20),
                FilledButton(onPressed: _busy ? null : () => _submit(signUp: false), child: Text(t.logIn)),
                const SizedBox(height: 10),
                OutlinedButton(onPressed: _busy ? null : () => _submit(signUp: true), child: Text(t.signUp)),
                const SizedBox(height: 12),
                Center(child: Text(t.ageNote, style: const TextStyle(fontSize: 13, color: MC.mute))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
