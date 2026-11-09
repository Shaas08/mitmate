import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/locale.dart';
import '../../core/supabase.dart';
import '../../l10n/app_localizations.dart';

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
    setState(() { _busy = true; _error = null; });
    try {
      if (signUp) {
        await db.auth.signUp(email: _email.text.trim(), password: _password.text);
      } else {
        await db.auth.signInWithPassword(email: _email.text.trim(), password: _password.text);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = AppLocalizations.of(context)!.errorGeneric);
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
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Text(t.appName, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                Text(t.tagline),
                const SizedBox(height: 24),
                TextField(controller: _email, decoration: InputDecoration(labelText: t.email),
                    keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email]),
                const SizedBox(height: 12),
                TextField(controller: _password, decoration: InputDecoration(labelText: t.password),
                    obscureText: true, autofillHints: const [AutofillHints.password]),
                if (_error != null) Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _busy ? null : () => _submit(signUp: false), child: Text(t.logIn)),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: _busy ? null : () => _submit(signUp: true), child: Text(t.signUp)),
                const SizedBox(height: 24),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'de', label: Text('Deutsch')),
                    ButtonSegment(value: 'en', label: Text('English')),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (s) =>
                      ref.read(localeProvider.notifier).state = Locale(s.first),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
