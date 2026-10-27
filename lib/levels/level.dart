import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indic_learn/audio/pronunciation_service.dart';
import 'package:indic_learn/levels/fail_screen.dart';

import 'level_model.dart';
import 'level_factory.dart';
import 'winscreen.dart';
import '../l10n/app_localizations.dart';
import '../widgets/svg_mascot.dart';
import '../session/session.dart';

import 'package:flutter_svg/flutter_svg.dart';

class LevelPage extends StatefulWidget {
  final String assetPath;
  final String mascotAsset;
  final VoidCallback? onCompleted;
  final SessionStats sessionStats;

  const LevelPage({
    super.key,
    required this.assetPath,
    this.mascotAsset = 'assets/mascots/sprout.svg',
    this.onCompleted,
    required this.sessionStats,
  });

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  List<LevelStep> _steps = [];
  bool _loadStarted = false;
  String? _loadError;
  int _currentStep = 0;
  int _score = 0;
  int _total = 0;
  int _attempt = 0;
  bool _completionReported = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _loadLevel(DefaultAssetBundle.of(context));
    }
  }

  Widget? _handleWinOrLose(int stepCount) {
    if (_currentStep == _steps.length) {
      PronunciationService.instance.playGameAudio(gameAudioTypes.levelComplete);
      return WinScreen(
        score: _score,
        total: _total,
        mascotAsset: widget.mascotAsset,
        onPlayAgain: () {
          setState(() {
            _currentStep = 0;
            _score = 0;
            _total = 0;
            _attempt++;
          });
        },
        onContinue: () {
          Navigator.of(context).pop(true);
        },
      );
    }

    if (widget.sessionStats.lives <= 0) {
      PronunciationService.instance.playGameAudio(gameAudioTypes.levelFailed);
      return FailScreen(
        score: _score,
        total: _total,
        mascotAsset: widget.mascotAsset,
        onPlayAgain: () {
          setState(() {
            widget.sessionStats.lives = 5;
            _currentStep = 0;
            _score = 0;
            _total = 0;
            _attempt++;
          });
        },
        onContinue: () {
          Navigator.of(context).pop(true);
        },
      );
    }
  }

  void _loseLife() {
    setState(() {
      widget.sessionStats.loseLife();
    });
  }

  Future<void> _loadLevel(AssetBundle bundle) async {
    try {
      final json = jsonDecode(await bundle.loadString(widget.assetPath));
      final steps = (json['steps'] as List<dynamic>)
          .map((step) => LevelStep.fromJson(step as Map<String, dynamic>))
          .toList();
      if (steps.isEmpty) {
        throw const FormatException('No steps available.');
      }
      if (!mounted) return;
      setState(() => _steps = steps);
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() => _loadError = l10n.levelLoadError('$error'));
    }
  }

  void _completeStep(int score, int total) {
    setState(() {
      _score += score;
      _total += total;
      _currentStep++;
    });
    if (_currentStep == _steps.length && !_completionReported) {
      _completionReported = true;
      widget.onCompleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.levelUnavailableTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_loadError!, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    if (_steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.levelLoading)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final overlay = _handleWinOrLose(_currentStep);
    if (overlay != null) {
      return overlay;
    }

    final step = _steps[_currentStep];
    final key = ValueKey('$_attempt-$_currentStep');
    // Get the appropriate game handler based on the step's handler field
    final game = getHandler(
      step.handler,
      key,
      step.assetPath,
      _completeStep,
      embeddedInLevel: true,
      onLoseLife: _loseLife,
    );

    // final game = gameHandler(
    //   key: key,
    //   assetPath: step.assetPath,
    //   onComplete: _completeStep,
    // );

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  if (Navigator.of(context).canPop()) const BackButton(),
                  Expanded(
                    child: Column(
                      children: [
                        Text(l10n.levelStepProgress(
                          _currentStep + 1,
                          _steps.length,
                        )),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _currentStep / _steps.length,
                        ),
                      ],
                    ),
                  ),
                  SvgMascot(
                    asset: widget.mascotAsset,
                    width: 88,
                    height: 88,
                    autoIdle: true,
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/svg_assets/heart.svg",
                          width: 40,
                          height: 40,
                        ),
                        Text(
                          widget.sessionStats.lives.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
