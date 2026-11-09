import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale.dart';
import '../../core/onboarding.dart';
import '../../core/supabase.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Step 3: profile and lifestyle answers.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _birthYear = TextEditingController();
  String _drinks = 'sometimes';
  String _guests = 'sometimes';
  String _food = 'everything';
  String _smokes = 'no';
  String _clean = '3';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = db.auth.currentUser?.id;
    if (uid != null) {
      final row = await db.from('profiles').select().eq('user_id', uid).maybeSingle();
      if (row != null) {
        _name.text = row['display_name'] ?? '';
        _bio.text = row['bio'] ?? '';
        _birthYear.text = '${row['birth_year'] ?? ''}';
        _drinks = row['drinks'] ?? _drinks;
        _guests = row['guests_ok'] ?? _guests;
        _food = row['food_habit'] ?? _food;
        _smokes = (row['smokes'] ?? false) ? 'yes' : 'no';
        _clean = '${row['cleanliness'] ?? 3}';
        ref.read(onboardingProvider.notifier).state =
            ref.read(onboardingProvider).copyWith(city: row['city'] ?? 'berlin');
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await db.from('profiles').upsert({
        'user_id': db.auth.currentUser!.id,
        'display_name': _name.text.trim(),
        'bio': _bio.text.trim(),
        'birth_year': int.tryParse(_birthYear.text) ?? 2000,
        'city': ref.read(onboardingProvider).city,
        'language': ref.read(localeProvider).languageCode,
        'drinks': _drinks,
        'guests_ok': _guests,
        'food_habit': _food,
        'smokes': _smokes == 'yes',
        'cleanliness': int.parse(_clean),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      if (mounted) context.go('/preferences');
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final freq = {'never': t.never, 'sometimes': t.sometimes, 'often': t.often};
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          StepHeader(step: 3, total: 5, label: t.stepLabel(3, 5), title: t.profileTitle),
          const SizedBox(height: 20),
          Row(children: [
            Container(
              width: 88, height: 88, alignment: Alignment.center,
              decoration: BoxDecoration(color: MC.priSoft, shape: BoxShape.circle, border: Border.all(color: MC.pri, width: 1.5)),
              child: Text(t.addPhoto, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MC.pri)),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(t.photoHint, style: const TextStyle(fontSize: 14, color: MC.mute))),
          ]),
          const SizedBox(height: 20),
          TextField(controller: _name, decoration: InputDecoration(labelText: t.displayName)),
          const SizedBox(height: 14),
          TextField(controller: _birthYear, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t.birthYear)),
          const SizedBox(height: 14),
          TextField(controller: _bio, maxLines: 4, maxLength: 600, decoration: InputDecoration(labelText: t.bio, hintText: t.bioHint)),
          const SizedBox(height: 8),
          CardBox(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FieldLabel(t.smokes),
              SinglePills(options: {'no': t.no, 'yes': t.yes}, value: _smokes, onChanged: (v) => setState(() => _smokes = v)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FieldLabel(t.drinks),
              SinglePills(options: freq, value: _drinks, onChanged: (v) => setState(() => _drinks = v)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FieldLabel(t.foodHabit),
              SinglePills(
                options: {'everything': t.everything, 'vegetarian': t.vegetarian, 'vegan': t.vegan, 'halal': t.halal},
                value: _food, onChanged: (v) => setState(() => _food = v)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FieldLabel(t.cleanliness),
              SinglePills(options: {for (final n in ['1', '2', '3', '4', '5']) n: n}, value: _clean, onChanged: (v) => setState(() => _clean = v)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FieldLabel(t.guestsOk),
              SinglePills(options: freq, value: _guests, onChanged: (v) => setState(() => _guests = v)),
            ]),
          ]),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(t.continueLabel)),
        ]),
      ),
    );
  }
}
