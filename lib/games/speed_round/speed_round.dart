import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/game_widgets.dart';
import 'speed_round_model.dart';

class SpeedRoundPage extends StatefulWidget {
  final String initialJsonData;
  final void Function(int score, int total)? onComplete;
  final bool embeddedInLevel;
  final VoidCallback? onLoseLife;

  const SpeedRoundPage({
    super.key,
    required this.initialJsonData,
    this.onComplete,
    this.embeddedInLevel = false,
    this.onLoseLife,
  });

  @override
  State<SpeedRoundPage> createState() => _SpeedRoundPageState();
}

class _SpeedRoundPageState extends State<SpeedRoundPage> {
  static const _feedbackDelay = Duration(milliseconds: 500);

  final _random = Random();
  List<SpeedRoundQuestion> _questions = [];
  List<String> _options = [];
  int _index = 0;
  int _score = 0;
  int _maxScore = 0;
  int _streak = 0;
  int _secondsLeft = SpeedRound.roundSeconds;
  bool _loading = true;
  bool _loadStarted = false;
  String? _loadError;
  bool _locked = false;
  bool _finished = false;
  String? _selected;
  Timer? _clock;
  Timer? _advanceTimer;

  SpeedRoundQuestion get _current => _questions[_index];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _loadQuestions(DefaultAssetBundle.of(context));
    }
  }

  Future<void> _loadQuestions(AssetBundle bundle) async {
    try {
      final questions = await SpeedRoundLoader.loadQuestions(
        widget.initialJsonData,
        bundle: bundle,
        random: _random,
      );
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _loading = false;
        if (questions.isNotEmpty) {
          _options = _current.options(_random);
          _clock = Timer.periodic(const Duration(seconds: 1), _tick);
        }
      });
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _loadError = l10n.speedRoundUnableToLoad('$error');
        _loading = false;
      });
    }
  }

  void _tick(Timer timer) {
    if (!mounted) return;
    setState(() => _secondsLeft--);
    if (_secondsLeft <= 0) _finish();
  }

  void _onOptionTap(String option) {
    if (_locked || _finished) return;
    final points = SpeedRound.multiplierFor(_streak);
    final correct = option == _current.answer;
    setState(() {
      _locked = true;
      _selected = option;
      _maxScore += points;
      if (correct) {
        _score += points;
        _streak++;
      } else {
        _streak = 0;
      }
    });
    if (!correct) widget.onLoseLife?.call();
    _advanceTimer = Timer(_feedbackDelay, _advance);
  }

  void _advance() {
    if (!mounted || _finished) return;
    if (_index + 1 >= _questions.length) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _locked = false;
      _selected = null;
      _options = _current.options(_random);
    });
  }

  void _finish() {
    _clock?.cancel();
    _advanceTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _finished = true;
      _locked = true;
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }

  AnswerVisualState _stateFor(String option) {
    if (_locked && option == _current.answer) {
      return AnswerVisualState.correct;
    }
    if (option == _selected) return AnswerVisualState.incorrect;
    if (_locked) return AnswerVisualState.disabled;
    return AnswerVisualState.idle;
  }

  Widget _round(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: _secondsLeft / SpeedRound.roundSeconds),
        const SizedBox(height: 8),
        Text(
          l10n.speedRoundTimeLeft(_secondsLeft),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.speedRoundStatus(_score, _streak),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        QuestionPrompt(text: l10n.speedRoundPrompt),
        const SizedBox(height: 16),
        GameAnswerArea(
          child: Text(
            _current.prompt,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 16),
        for (final option in _options)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GameAnswerTile(
              state: _stateFor(option),
              onPressed: _locked ? null : () => _onOptionTap(option),
              child: Text(option, textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Text(_loadError!, textAlign: TextAlign.center);
    }
    if (_questions.isEmpty) {
      return Text(l10n.speedRoundNoQuestions, textAlign: TextAlign.center);
    }
    if (_finished) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.speedRoundOver, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            l10n.speedRoundStatus(_score, _streak),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return _round(l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GameScaffold(
      title: l10n.speedRoundTitle,
      embeddedInLevel: widget.embeddedInLevel,
      footer: _finished && widget.onComplete != null
          ? GameButton(
              icon: Icons.arrow_forward,
              label: l10n.continueLabel,
              onPressed: () => widget.onComplete!(_score, _maxScore),
            )
          : null,
      child: _body(l10n),
    );
  }
}
