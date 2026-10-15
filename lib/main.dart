import 'package:flutter/material.dart';

import 'level_loader/level_loader.dart';
import 'ui/game_theme.dart';

class LanguageGameApp extends StatelessWidget {
  const LanguageGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Language Game',
      theme: buildGameTheme(),
      home: const LevelLoader(),
    );
  }
}

void main() {
  runApp(const LanguageGameApp());
}
