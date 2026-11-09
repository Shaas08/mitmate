import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale.dart';
import '../../core/onboarding.dart';
import '../../core/supabase.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _delete(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(t.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t.cancel)),
          FilledButton(style: FilledButton.styleFrom(minimumSize: const Size(96, 44), backgroundColor: MC.warn), onPressed: () => Navigator.pop(c, true), child: Text(t.delete)),
        ],
      ),
    );
    if (ok == true) {
      await db.rpc('delete_my_account');
      await db.auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final city = ref.watch(onboardingProvider).city;
    Widget row(String a, Widget b, {VoidCallback? onTap}) => InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: MC.line))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(a, style: const TextStyle(fontSize: 16)), b]),
          ),
        );
    return Scaffold(
      appBar: AppBar(backgroundColor: MC.bg, title: Text(t.settings, style: serif(size: 28, weight: FontWeight.w600)), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/'))),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          row(t.language, Row(children: [
            Pill(label: 'DE', selected: locale.languageCode == 'de', onTap: () => ref.read(localeProvider.notifier).state = const Locale('de')),
            const SizedBox(width: 4),
            Pill(label: 'EN', selected: locale.languageCode == 'en', onTap: () => ref.read(localeProvider.notifier).state = const Locale('en')),
          ])),
          row(t.city, Text(city == 'hamburg' ? t.hamburg : t.berlin, style: const TextStyle(color: MC.mute)), onTap: () => context.go('/city')),
          row(t.prefsRow, const Icon(Icons.chevron_right, color: MC.mute), onTap: () => context.go('/preferences')),
          row(t.consentRow, const Icon(Icons.chevron_right, color: MC.mute), onTap: () => context.go('/consent')),
          const SizedBox(height: 32),
          OutlinedButton(onPressed: () => db.auth.signOut(), child: Text(t.logOut)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFFBEDED), borderRadius: BorderRadius.circular(12), border: Border.all(color: MC.warn, width: 1.5)),
            child: Column(children: [
              Text(t.deleteWarn, style: const TextStyle(fontSize: 15, height: 1.45)),
              const SizedBox(height: 12),
              FilledButton(style: FilledButton.styleFrom(backgroundColor: MC.warn, minimumSize: const Size.fromHeight(48)), onPressed: () => _delete(context), child: Text(t.deleteAccount)),
            ]),
          ),
        ]),
      ),
    );
  }
}
