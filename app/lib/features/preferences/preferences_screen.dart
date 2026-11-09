import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase.dart';
import '../../l10n/app_localizations.dart';

/// Matching preferences plus the consent-gated optional personal details.
/// Orientation and ethnicity are stored in `sensitive_details`, only after explicit consent.
/// Ethnicity is shared only if the user chooses and is never used as a match filter.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  static const _genders = ['women', 'men', 'bi', 'lgbtq'];
  final Set<String> _wants = {};
  final _orientation = TextEditingController();
  final _ethnicity = TextEditingController();
  bool _consent = false;
  RangeValues _age = const RangeValues(18, 40);

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final uid = db.auth.currentUser!.id;
    try {
      await db.from('preferences').upsert({
        'user_id': uid,
        'wants_genders': _wants.toList(),
        'age_min': _age.start.round(),
        'age_max': _age.end.round(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      final hasSensitive = _orientation.text.isNotEmpty || _ethnicity.text.isNotEmpty;
      if (hasSensitive && _consent) {
        await db.from('sensitive_details').upsert({
          'user_id': uid,
          'orientation': _orientation.text.trim(),
          'ethnicity': _ethnicity.text.trim(),
          'consent_given_at': DateTime.now().toUtc().toIso8601String(),
          'consent_text_version': 'v1',
        });
        await db.from('consent_log').insert({
          'user_id': uid, 'kind': 'sensitive_details', 'granted': true, 'text_version': 'v1',
        });
      } else if (!_consent) {
        await db.from('sensitive_details').delete().eq('user_id', uid);
        await db.from('consent_log').insert({
          'user_id': uid, 'kind': 'sensitive_details', 'granted': false, 'text_version': 'v1',
        });
      }
      messenger.showSnackBar(SnackBar(content: Text(t.saved)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.preferences), leading: IconButton(
        icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/profile'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(t.preferencesHint),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final g in _genders)
            FilterChip(
              label: Text(g),
              selected: _wants.contains(g),
              onSelected: (on) => setState(() => on ? _wants.add(g) : _wants.remove(g)),
            ),
        ]),
        const SizedBox(height: 16),
        RangeSlider(values: _age, min: 18, max: 80, divisions: 62,
            labels: RangeLabels('${_age.start.round()}', '${_age.end.round()}'),
            onChanged: (v) => setState(() => _age = v)),
        const Divider(height: 32),
        Text(t.sensitiveTitle, style: Theme.of(context).textTheme.titleMedium),
        TextField(controller: _orientation, decoration: const InputDecoration(labelText: 'Orientation')),
        TextField(controller: _ethnicity, decoration: const InputDecoration(labelText: 'Ethnicity')),
        CheckboxListTile(
          value: _consent,
          onChanged: (v) => setState(() => _consent = v ?? false),
          title: Text(t.sensitiveConsent),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 8),
        FilledButton(onPressed: _save, child: Text(t.save)),
      ]),
    );
  }
}
