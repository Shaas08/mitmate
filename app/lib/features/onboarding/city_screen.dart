import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/onboarding.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Step 2: Berlin or Hamburg.
class CityScreen extends ConsumerWidget {
  const CityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final city = ref.watch(onboardingProvider).city;
    Widget card(String key, String name) {
      final on = city == key;
      return Semantics(
        button: true,
        selected: on,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => ref.read(onboardingProvider.notifier).state = ref.read(onboardingProvider).copyWith(city: key),
          child: Container(
            constraints: const BoxConstraints(minHeight: 104),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: on ? MC.priSoft : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: on ? MC.pri : MC.line, width: on ? 2 : 1.5),
            ),
            child: Row(children: [
              Container(
                width: 56, height: 56, alignment: Alignment.center,
                decoration: BoxDecoration(color: on ? MC.pri : MC.bg, borderRadius: BorderRadius.circular(16)),
                child: Text(name.substring(0, 1), style: serif(size: 24, weight: FontWeight.w700, color: on ? Colors.white : MC.pri)),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(name, style: serif(size: 22, weight: FontWeight.w600))),
              Icon(on ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: on ? MC.pri : MC.line),
            ]),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            StepHeader(step: 2, total: 5, label: t.stepLabel(2, 5), title: t.cityTitle, subtitle: t.citySub),
            const SizedBox(height: 24),
            card('berlin', t.berlin),
            const SizedBox(height: 12),
            card('hamburg', t.hamburg),
            const SizedBox(height: 12),
            Text(t.moreCities, style: const TextStyle(fontSize: 14, color: MC.mute)),
            const Spacer(),
            FilledButton(onPressed: () => context.go('/profile'), child: Text(t.continueLabel)),
          ]),
        ),
      ),
    );
  }
}
