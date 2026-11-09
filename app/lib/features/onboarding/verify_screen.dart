import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Step 1: confirm the email code. Phone number is collected here; SMS verification
/// needs a provider and is a follow-up (see README).
class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key, this.email});
  final String? email;
  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _code = TextEditingController();
  final _phone = TextEditingController();
  bool _busy = false;
  String? _error;

  String? get _email => widget.email ?? db.auth.currentUser?.email;

  Future<void> _verify() async {
    final t = AppLocalizations.of(context)!;
    final email = _email;
    if (email == null) return;
    setState(() { _busy = true; _error = null; });
    try {
      await db.auth.verifyOTP(type: OtpType.signup, email: email, token: _code.text.trim());
      if (mounted) context.go('/city');
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = t.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final email = _email;
    if (email == null) return;
    await db.auth.resend(type: OtpType.signup, email: email);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          StepHeader(step: 1, total: 5, label: t.stepLabel(1, 5), title: t.verifyTitle, subtitle: t.verifySub),
          const SizedBox(height: 24),
          TextField(controller: _code, decoration: InputDecoration(labelText: t.codeLabel), keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          TextField(controller: _phone, decoration: InputDecoration(labelText: t.phoneLabel), keyboardType: TextInputType.phone),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: MC.warn))),
          const SizedBox(height: 24),
          FilledButton(onPressed: _busy ? null : _verify, child: Text(t.continueLabel)),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: _resend, child: Text(t.resendCode)),
          const SizedBox(height: 16),
          Text(t.verifyWhy, style: const TextStyle(fontSize: 13, color: MC.mute)),
        ]),
      ),
    );
  }
}
