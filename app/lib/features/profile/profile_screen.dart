import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale.dart';
import '../../core/supabase.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _birthYear = TextEditingController();
  String _city = 'berlin';
  String _drinks = 'sometimes';
  String _guests = 'sometimes';
  String _food = 'everything';
  bool _smokes = false;
  double _clean = 3;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = db.auth.currentUser!.id;
    final row = await db.from('profiles').select().eq('user_id', uid).maybeSingle();
    if (row != null) {
      _name.text = row['display_name'] ?? '';
      _bio.text = row['bio'] ?? '';
      _birthYear.text = '${row['birth_year'] ?? ''}';
      _city = row['city'] ?? 'berlin';
      _drinks = row['drinks'] ?? 'sometimes';
      _guests = row['guests_ok'] ?? 'sometimes';
      _food = row['food_habit'] ?? 'everything';
      _smokes = row['smokes'] ?? false;
      _clean = (row['cleanliness'] ?? 3).toDouble();
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
        'city': _city,
        'language': ref.read(localeProvider).languageCode,
        'drinks': _drinks,
        'guests_ok': _guests,
        'food_habit': _food,
        'smokes': _smokes,
        'cleanliness': _clean.round(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      messenger.showSnackBar(SnackBar(content: Text(t.saved)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.errorGeneric)));
    }
  }

  Future<void> _deleteAccount() async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(t.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(t.delete)),
        ],
      ),
    );
    if (ok == true) {
      await db.rpc('delete_my_account');
      await db.auth.signOut();
    }
  }

  DropdownButtonFormField<String> _dd(String label, String value, List<String> opts,
      void Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: [for (final o in opts) DropdownMenuItem(value: o, child: Text(o))],
      onChanged: (v) => setState(() => onChanged(v!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(t.profile), actions: [
        IconButton(onPressed: () => context.go('/'), icon: const Icon(Icons.close)),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _name, decoration: InputDecoration(labelText: t.displayName)),
        const SizedBox(height: 12),
        TextField(controller: _bio, maxLines: 4, maxLength: 600,
            decoration: InputDecoration(labelText: t.bio)),
        TextField(controller: _birthYear, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: t.birthYear)),
        const SizedBox(height: 12),
        _dd(t.city, _city, ['berlin', 'hamburg'], (v) => _city = v),
        const SizedBox(height: 12),
        SwitchListTile(title: Text(t.smokes), value: _smokes, onChanged: (v) => setState(() => _smokes = v)),
        _dd(t.drinks, _drinks, ['never', 'sometimes', 'often'], (v) => _drinks = v),
        const SizedBox(height: 12),
        _dd(t.foodHabit, _food,
            ['everything', 'vegetarian', 'vegan', 'halal', 'kosher', 'other'], (v) => _food = v),
        const SizedBox(height: 12),
        _dd(t.guestsOk, _guests, ['never', 'sometimes', 'often'], (v) => _guests = v),
        const SizedBox(height: 12),
        Text(t.cleanliness),
        Slider(value: _clean, min: 1, max: 5, divisions: 4, label: '${_clean.round()}',
            onChanged: (v) => setState(() => _clean = v)),
        const SizedBox(height: 8),
        FilledButton(onPressed: _save, child: Text(t.save)),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () => context.go('/preferences'), child: Text(t.preferences)),
        const SizedBox(height: 24),
        TextButton(onPressed: _deleteAccount,
            child: Text(t.deleteAccount, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        TextButton(onPressed: () => db.auth.signOut(), child: Text(t.logOut)),
      ]),
    );
  }
}
