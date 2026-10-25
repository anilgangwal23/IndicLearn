import 'package:flutter/material.dart';

import '../widgets/svg_mascot.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Level complete!')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgMascot(asset: mascotAsset, autoIdle: true),
            Text('You scored $score out of $total'),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.replay),
              label: const Text('Try Again'),
              onPressed: onPlayAgain,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.next_plan),
              label: const Text('Continue...'),
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
