import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Step 5: optional personal details (GDPR Art. 9). Stored in `sensitive_details`
/// only with explicit consent, never used as a match filter.
class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});
  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  final _orientation = TextEditingController();
  final _ethnicity = TextEditingController();
  bool _showO = false, _showE = false, _consent = false;

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final uid = db.auth.currentUser!.id;
    try {
      final hasData = _orientation.text.trim().isNotEmpty || _ethnicity.text.trim().isNotEmpty;
      if (hasData && _consent) {
        await db.from('sensitive_details').upsert({
          'user_id': uid,
          'orientation': _orientation.text.trim(),
          'ethnicity': _ethnicity.text.trim(),
          'show_orientation': _showO,
          'show_ethnicity': _showE,
          'consent_given_at': DateTime.now().toUtc().toIso8601String(),
          'consent_text_version': 'v1',
        });
        await db.from('consent_log').insert({'user_id': uid, 'kind': 'sensitive_details', 'granted': true, 'text_version': 'v1'});
      }
      if (mounted) context.go('/');
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          StepHeader(step: 5, total: 5, label: t.stepLabel(5, 5), title: t.consentTitle, subtitle: t.consentSub),
          const SizedBox(height: 20),
          CardBox(children: [
            TextField(controller: _orientation, decoration: InputDecoration(labelText: t.orientation, hintText: t.optional)),
            TextField(controller: _ethnicity, decoration: InputDecoration(labelText: t.ethnicity, hintText: t.optional)),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t.showOrientation), value: _showO, activeColor: MC.pri, onChanged: (v) => setState(() => _showO = v)),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t.showEthnicity), value: _showE, activeColor: MC.pri, onChanged: (v) => setState(() => _showE = v)),
          ]),
          const SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: MC.pri,
            value: _consent,
            onChanged: (v) => setState(() => _consent = v ?? false),
            title: Text(t.consentText, style: const TextStyle(fontSize: 15, height: 1.45)),
          ),
          Text(t.consentNote, style: const TextStyle(fontSize: 13, color: MC.mute)),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(t.saveFinish)),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: () => context.go('/'), child: Text(t.skipNow)),
        ]),
      ),
    );
  }
}
