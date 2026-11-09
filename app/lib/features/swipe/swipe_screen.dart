import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

/// Placeholder for Sprint 2 (swipe deck, mutual match, chat).
class SwipeScreen extends StatelessWidget {
  const SwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.discover), actions: [
        IconButton(onPressed: () => context.go('/profile'), icon: const Icon(Icons.person)),
      ]),
      body: Center(child: Text(t.discoverSoon)),
    );
  }
}
