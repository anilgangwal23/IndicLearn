import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'dart:async';
import 'mts_model.dart';
import 'mts_loader.dart';
import '../../ui/game_theme.dart';
import '../../ui/game_widgets.dart';

import '../../animations/common_animations.dart';
import '../../widgets/svg_mascot.dart';
@Preview(name: 'Quiz', size: Size(390, 844))
Widget previewQuiz() {
  return MaterialApp(
    theme: buildGameTheme(),
    home: const mts(
      initialJsonData:
          'packages/indic_learn/assets/make_the_sentence/en_hi_lvl1.json',
    ),
  );
}

class mts extends StatefulWidget {
  final String initialJsonData;
  final void Function(int score, int total)? onComplete;
  final bool embeddedInLevel;
  final VoidCallback? onLoseLife;
  const mts({
    super.key,
    required this.initialJsonData,
    this.onComplete,
    this.embeddedInLevel = false,
    this.onLoseLife,
  });

  @override
  State<mts> createState() => _mtsGameState();
}

class _mtsGameState extends State<mts> {
  late final MTSModel _model;
  bool _isModelLoaded = false;
  String? _loadError;
  final List<int> selectedWordIDs = [];
  bool isSolved = false;
  Timer? _wrongPickTimer;
  int? wrongWordID;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final model = await GameLoader.loadMTSModel(widget.initialJsonData);
      if (!mounted) return;
      setState(() {
        _model = model;
        _isModelLoaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = 'Unable to load sentence: $error');
    }
  }

  Widget _buildGame() {
    if (_loadError != null) {
      return GameScaffold(
        embeddedInLevel: widget.embeddedInLevel,
        title: 'Make the Sentence',
        child: Text(_loadError!, textAlign: TextAlign.center),
      );
    }
    return GameScaffold(
      embeddedInLevel: widget.embeddedInLevel,
      title: 'Make the Sentence',
      footer: isSolved
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GameFeedback(
                  correct: true,
                  message: 'Sentence complete!',
                ),
                const SizedBox(height: 12),
                GameButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward,
                  onPressed: () => widget.onComplete?.call(1, 1),
                ),
              ],
            )
          : null,
      child: _isModelLoaded
          ? AbsorbPointer(
              absorbing: isSolved,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CommonAnimation(
                  'assets/mascots/fox.svg',
                  isSolved?MascotAnimation.spin:MascotAnimation.blink,
                ),
                QuestionPrompt(text: _model.source),
                const SizedBox(height: 24),

                GameAnswerArea(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Selected word tiles go here.
                      for (final wordId in selectedWordIDs)
                        GameAnswerTile(
                          state: AnswerVisualState.selected,
                          onPressed: null,
                          child: Text(_model.words[wordId]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 12,
                  children: [
                    // Available word tiles go here.
                    for (int i = 0; i < _model.words.length; i++)
                      GameAnswerTile(
                        state: selectedWordIDs.contains(i)
                            ? AnswerVisualState.disabled
                            : wrongWordID == i ? AnswerVisualState.incorrect : AnswerVisualState.idle,
                        onPressed: selectedWordIDs.contains(i)
                            ? null
                            : () => pickWord(i),
                        child: Text(_model.words[i]),
                      ),
                  ],
                ),
              ],
            ),
          )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void showWrongPick(int wordId) {
    _wrongPickTimer?.cancel();
    setState(() {
      wrongWordID = wordId;
    });
    _wrongPickTimer = Timer(
      const Duration(milliseconds: 500),
        () {
          if (!mounted) return;
          setState(
            (){
                wrongWordID = null;
                widget.onLoseLife?.call();
              }
            );
        }
    );
  }

  void pickWord(int wordId) {
    if (!_model.acceptsNextWord(selectedWordIDs, wordId)) {
      showWrongPick(wordId);
      return;
    }
    setState(() {
      selectedWordIDs.add(wordId);
      if(selectedWordIDs.length == _model.index.length){
        win();
      } 
    });
  }

  void win() {
    setState(() {
      isSolved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildGame();
  }

  @override
  void dispose() {
    _wrongPickTimer?.cancel();
    super.dispose();
  }
}
