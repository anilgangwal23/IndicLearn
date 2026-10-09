import 'package:flutter/material.dart';

import 'levels/level.dart';

class LanguageGameApp extends StatelessWidget {
  const LanguageGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Language Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LevelPage(assetPath: 'assets/levels/level_1.json'),
    );
  }
}

void main() {
  runApp(const LanguageGameApp());
}
