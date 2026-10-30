import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indic_learn/audio/pronunciation_service.dart';
import 'package:indic_learn/levels/fail_screen.dart';
import 'package:indic_learn/onboarding/game_intro.dart';

import 'level_model.dart';
import 'level_factory.dart';
import 'winscreen.dart';
import '../l10n/app_localizations.dart';
import '../ui/mascot_catalog.dart';
import '../ui/svg_mascot.dart';
import '../session/session.dart';

import 'package:flutter_svg/flutter_svg.dart';

class LevelPage extends StatefulWidget {
  final String assetPath;
  final String? mascotAsset;
  final VoidCallback? onCompleted;
  final SessionStats sessionStats;

  const LevelPage({
    super.key,
    required this.assetPath,
    this.mascotAsset,
    this.onCompleted,
    required this.sessionStats,
  });

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  late final String _mascotAsset = widget.mascotAsset ?? pickSpeakingMascot();
  List<LevelStep> _steps = [];
  bool _loadStarted = false;
  String? _loadError;
  int _currentStep = 0;
  int _score = 0;
  int _total = 0;
  int _attempt = 0;
  bool _completionReported = false;
  Set<String>? _seenIntros;

  @override
  void initState() {
    super.initState();
    GameIntroStore.loadSeen().then((seen) {
      if (mounted) setState(() => _seenIntros = seen);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _loadLevel(DefaultAssetBundle.of(context));
    }
  }

  // Games that show their own mascot in the main game area, so the header mascot is hidden.
  static const _handlersWithOwnMascot = {'FollowTheSound', 'MTSPage'};

  Widget? _handleWinOrLose(int stepCount) {
    if (_currentStep == _steps.length) {
      PronunciationService.instance.playGameAudio(gameAudioTypes.levelComplete);
      return WinScreen(
        score: _score,
        total: _total,
        mascotAsset: _mascotAsset,
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
        mascotAsset: _mascotAsset,
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

  Future<void> _acknowledgeIntro(String handler) async {
    setState(() => _seenIntros = {...?_seenIntros, handler});
    await GameIntroStore.markSeen(handler);
  }

  Widget _buildGame(LevelStep step, AppLocalizations l10n) {
    final seen = _seenIntros;
    if (seen == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final intro = gameIntroFor(step.handler, l10n);
    if (intro != null && !seen.contains(step.handler)) {
      return GameIntroView(
        intro: intro,
        onStart: () => _acknowledgeIntro(step.handler),
      );
    }
    final key = ValueKey('$_attempt-$_currentStep');
    // Get the appropriate game handler based on the step's handler field
    return getHandler(
      step.handler,
      key,
      step.assetPath,
      _completeStep,
      embeddedInLevel: true,
      onLoseLife: _loseLife,
      mascotAsset: _mascotAsset,
      config: step.config,
    );
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
    final game = _buildGame(step, l10n);

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
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.levelStepProgress(
                                _currentStep + 1,
                                _steps.length,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(
                                  end: _currentStep / _steps.length,
                                ),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) =>
                                    LinearProgressIndicator(
                                  value: value,
                                  minHeight: 12,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!_handlersWithOwnMascot.contains(step.handler))
                    SvgMascot(
                      asset: _mascotAsset,
                      width: 88,
                      height: 88,
                      autoIdle: true,
                      speaking: PronunciationService.instance.speaking,
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
