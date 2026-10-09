import 'dart:convert';

import 'package:flutter/material.dart';

import '../match_the_pair/pairing.dart';
import '../quiz_ui/quiz.dart';

class LevelPage extends StatefulWidget {
  final String assetPath;

  const LevelPage({super.key, required this.assetPath});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  List<_LevelStep> _steps = [];
  bool _loadStarted = false;
  String? _loadError;
  int _currentStep = 0;
  int _score = 0;
  int _total = 0;
  int _attempt = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _loadLevel(DefaultAssetBundle.of(context));
    }
  }

  Future<void> _loadLevel(AssetBundle bundle) async {
    try {
      final json = jsonDecode(await bundle.loadString(widget.assetPath));
      final steps = (json['steps'] as List<dynamic>)
          .map((step) => _LevelStep.fromJson(step as Map<String, dynamic>))
          .toList();
      if (steps.isEmpty) {
        throw const FormatException('No steps available.');
      }
      if (!mounted) return;
      setState(() => _steps = steps);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = 'Unable to load level: $error');
    }
  }

  void _completeStep(int score, int total) {
    setState(() {
      _score += score;
      _total += total;
      _currentStep++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_loadError!, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    if (_steps.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_currentStep == _steps.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Level complete!')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You scored $_score out of $_total'),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.replay),
                label: const Text('Play Again'),
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                    _score = 0;
                    _total = 0;
                    _attempt++;
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    final step = _steps[_currentStep];
    final key = ValueKey('$_attempt-$_currentStep');
    final game = step.type == 'quiz'
        ? GamePage(
            key: key,
            assetPath: step.assetPath,
            onComplete: _completeStep,
          )
        : WordMatchPage(
            key: key,
            initialJsonData: step.assetPath,
            onComplete: _completeStep,
          );

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Text('Step ${_currentStep + 1}/${_steps.length}'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _currentStep / _steps.length),
                ],
              ),
            ),
          ),
          Expanded(child: game),
        ],
      ),
    );
  }
}

class _LevelStep {
  final String type;
  final String assetPath;

  const _LevelStep(this.type, this.assetPath);

  factory _LevelStep.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    final data = json['data'];
    if (type != 'quiz' && type != 'match_the_pair') {
      throw FormatException('Unsupported step type: $type');
    }
    if (data is! String || data.isEmpty) {
      throw const FormatException('Step data must be an asset path.');
    }
    return _LevelStep(type as String, data);
  }
}
