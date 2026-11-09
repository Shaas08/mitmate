import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Placeholder for Sprint 2 (swipe deck, mutual match, chat).
class SwipeScreen extends StatelessWidget {
  const SwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const MitmateWordmark(), toolbarHeight: 72, actions: [
        IconButton(onPressed: () => context.go('/profile'), icon: const Icon(Icons.person), tooltip: t.profileTitle),
        IconButton(onPressed: () => context.go('/settings'), icon: const Icon(Icons.settings), tooltip: t.settings),
      ]),
      body: Center(child: Text(t.discoverSoon)),
    );
  }
}
