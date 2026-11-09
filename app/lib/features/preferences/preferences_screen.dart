import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Step 4: who the person wants to match with. Empty groups mean open to everyone.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final Set<String> _wants = {};
  RangeValues _age = const RangeValues(24, 38);
  final _rent = TextEditingController();
  bool _smokingOk = false;
  String _drinkMax = 'sometimes';

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await db.from('preferences').upsert({
        'user_id': db.auth.currentUser!.id,
        'wants_genders': _wants.toList(),
        'age_min': _age.start.round(),
        'age_max': _age.end.round(),
        'max_rent_cents': (int.tryParse(_rent.text) ?? 0) * 100 == 0 ? null : (int.parse(_rent.text) * 100),
        'smoking_ok': _smokingOk,
        'drinking_max': _drinkMax,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      if (mounted) context.go('/consent');
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final groups = {'women': t.women, 'men': t.men, 'bi': t.bi, 'lgbtq': t.lgbtq};
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          StepHeader(step: 4, total: 5, label: t.stepLabel(4, 5), title: t.prefsTitle, subtitle: t.prefsSub),
          const SizedBox(height: 20),
          CardBox(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FieldLabel(t.matchWith),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final e in groups.entries)
                  Pill(label: e.value, selected: _wants.contains(e.key), onTap: () => setState(() => _wants.contains(e.key) ? _wants.remove(e.key) : _wants.add(e.key))),
              ]),
            ]),
          ]),
          const SizedBox(height: 16),
          CardBox(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FieldLabel(t.ageRange),
              RangeSlider(values: _age, min: 18, max: 80, divisions: 62, labels: RangeLabels('${_age.start.round()}', '${_age.end.round()}'), onChanged: (v) => setState(() => _age = v)),
              Text('${_age.start.round()} – ${_age.end.round()}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            TextField(controller: _rent, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t.maxRent, prefixText: '€ ')),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(t.smokingOk), value: _smokingOk, activeColor: MC.pri, onChanged: (v) => setState(() => _smokingOk = v)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FieldLabel(t.drinkMax),
              SinglePills(options: {'never': t.never, 'sometimes': t.sometimes, 'often': t.often}, value: _drinkMax, onChanged: (v) => setState(() => _drinkMax = v)),
            ]),
          ]),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(t.continueLabel)),
        ]),
      ),
    );
  }
}
