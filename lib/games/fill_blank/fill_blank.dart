import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/game_widgets.dart';
import 'fill_blank_model.dart';

class FillBlankPage extends StatefulWidget {
  final String initialJsonData;
  final void Function(int score, int total)? onComplete;
  final bool embeddedInLevel;
  final VoidCallback? onLoseLife;
  final int? optionCount;

  const FillBlankPage({
    super.key,
    required this.initialJsonData,
    this.onComplete,
    this.embeddedInLevel = false,
    this.onLoseLife,
    this.optionCount,
  });

  @override
  State<FillBlankPage> createState() => _FillBlankPageState();
}

class _FillBlankPageState extends State<FillBlankPage> {
  final _random = Random();
  List<FillBlankQuestion> _questions = [];
  List<String> _options = [];
  int _index = 0;
  int _score = 0;
  bool _loading = true;
  bool _loadStarted = false;
  String? _loadError;
  bool _answered = false;
  bool _mistake = false;
  final Set<String> _wrongTaps = {};

  FillBlankQuestion get _current => _questions[_index];
  bool get _isLast => _index == _questions.length - 1;

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
      final questions = await FillBlankLoader.loadQuestions(
        widget.initialJsonData,
        bundle: bundle,
        random: _random,
      );
      if (!mounted) return;
      setState(() {
        _questions = questions;
        if (questions.isNotEmpty) _options = _buildOptions(questions.first);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _loadError = l10n.fillBlankUnableToLoad('$error');
        _loading = false;
      });
    }
  }

  List<String> _buildOptions(FillBlankQuestion question) {
    return FillBlankOptions.build(
      question,
      optionCount: widget.optionCount,
      random: _random,
    );
  }

  void _onOptionTap(String option) {
    if (_answered || _wrongTaps.contains(option)) return;
    if (option == _current.answer) {
      setState(() {
        _answered = true;
        if (!_mistake) _score++;
      });
      return;
    }
    widget.onLoseLife?.call();
    setState(() {
      _mistake = true;
      _wrongTaps.add(option);
    });
  }

  void _next() {
    if (_isLast) {
      widget.onComplete?.call(_score, _questions.length);
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _mistake = false;
      _wrongTaps.clear();
      _options = _buildOptions(_current);
    });
  }

  AnswerVisualState _stateFor(String option) {
    if (_answered && option == _current.answer) {
      return AnswerVisualState.correct;
    }
    if (_wrongTaps.contains(option)) return AnswerVisualState.incorrect;
    if (_answered) return AnswerVisualState.disabled;
    return AnswerVisualState.idle;
  }

  Widget _sentence(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final parts = _current.sentence.split(FillBlankQuestion.blank);
    final blank = TextSpan(
      text: _answered ? _current.answer : '______',
      style: TextStyle(
        color: _answered ? colors.primary : colors.outline,
        fontWeight: FontWeight.w800,
      ),
    );
    final spans = <InlineSpan>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0) spans.add(blank);
      spans.add(TextSpan(text: parts[i]));
    }
    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineSmall,
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
      return Text(l10n.fillBlankNoQuestions, textAlign: TextAlign.center);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: _index / _questions.length),
        const SizedBox(height: 16),
        QuestionPrompt(text: l10n.fillBlankPrompt),
        const SizedBox(height: 16),
        GameAnswerArea(child: _sentence(context)),
        const SizedBox(height: 16),
        for (final option in _options)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GameAnswerTile(
              state: _stateFor(option),
              onPressed: _answered || _wrongTaps.contains(option)
                  ? null
                  : () => _onOptionTap(option),
              child: Text(option, textAlign: TextAlign.center),
            ),
          ),
        if (!_answered && _wrongTaps.isNotEmpty)
          GameFeedback(correct: false, message: l10n.fillBlankWrong),
        if (_answered) ...[
          GameFeedback(correct: true, message: l10n.quizQuestionCorrect),
          const SizedBox(height: 12),
          GameButton(
            onPressed: _next,
            label: _isLast ? l10n.quizQuestionFinish : l10n.continueLabel,
            icon: _isLast ? Icons.check : Icons.arrow_forward,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GameScaffold(
      title: l10n.fillBlankTitle(
        _questions.isEmpty ? 0 : _index + 1,
        _questions.length,
      ),
      embeddedInLevel: widget.embeddedInLevel,
      child: _body(l10n),
    );
  }
}
