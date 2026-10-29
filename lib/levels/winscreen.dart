import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../ui/svg_mascot.dart';

class WinScreen extends StatelessWidget {
  final int score;
  final int total;
  final String mascotAsset;
  final VoidCallback onPlayAgain;
  final VoidCallback onContinue;

  const WinScreen({
    super.key,
    required this.score,
    required this.total,
    required this.mascotAsset,
    required this.onPlayAgain,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.winTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgMascot(asset: mascotAsset, autoIdle: true),
            Text(l10n.winScore(score, total)),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.replay),
              label: Text(l10n.winTryAgain),
              onPressed: onPlayAgain,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.next_plan),
              label: Text(l10n.winContinue),
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
