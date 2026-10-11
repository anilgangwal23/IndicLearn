import 'package:flutter/material.dart';

import 'levels/level.dart';
import 'ui/game_theme.dart';

class LanguageGameApp extends StatelessWidget {
  const LanguageGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Language Game',
      theme: buildGameTheme(),
      home: const LevelPage(assetPath: 'assets/levels/level_1.json'),
    );
  }
}

void main() {
  runApp(const LanguageGameApp());
}
