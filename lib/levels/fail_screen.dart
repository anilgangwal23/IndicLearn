import 'package:flutter/material.dart';

import '../widgets/svg_mascot.dart';

class FailScreen extends StatelessWidget {
  final int score;
  final int total;
  final String mascotAsset;
  final VoidCallback onPlayAgain;
  final VoidCallback onContinue;

  const FailScreen({
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
            SvgMascot(asset: "assets/mascots/grim_reaper.svg", autoIdle: true),
            Text('Out of lives :('),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.replay),
              label: const Text('Try Again'),
              onPressed: onPlayAgain,
            ),
          ],
        ),
      ),
    );
  }
}
