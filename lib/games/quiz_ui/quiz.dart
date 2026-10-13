import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../animations/confetti.dart';
import 'quiz_loader.dart';
import 'quiz_models.dart';
import 'widgets/question_view.dart';
import '../../audio/pronunciation_service.dart';

export 'quiz_loader.dart';
export 'quiz_models.dart';
export 'widgets/choice_button.dart';

@Preview(name: 'Game Page', size: Size(390, 844))
Widget previewGamePage() {
  return const MaterialApp(home: GamePage(assetPath: "packages/indic_learn/assets/Quizes/whatisthis_fruit_001.json"));
}

class GamePage extends StatefulWidget {
  final String assetPath;
  final void Function(int score, int total)? onComplete;

  const GamePage({
    super.key,
    this.assetPath = 'Quizes/whatisthis_fruit_001.json',
    this.onComplete,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  List<GameQuestion> questions = [];
  bool _loadStarted = false;
  String? _loadError;
  final pronunciationService = PronunciationService();
  int currentQuestion = 0;
  int score = 0;

  bool answered = false;
  String? selectedChoiceId;

  // Learner configuration.
  final String promptLanguage = 'en';
  final String targetLanguage = 'hi';

  // Change this to "native" when the learner is ready.
  final String displayVariant = 'romanized';

  late final AnimationController _confettiController;

  void showWinAnimation() {
    _confettiController.forward(from: 0);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      loadGame();
    }
  }

  Future<void> loadGame() async {
    final bundle = DefaultAssetBundle.of(context);
    try {
      final loadedQuestions = await GameLoader.loadQuestions(
        widget.assetPath,
        bundle: bundle,
      );
      if (!mounted) return;

      setState(() {
        questions = loadedQuestions;
        _loadError = loadedQuestions.isEmpty ? 'No questions available.' : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Unable to load quiz: $error';
      });
    }
  }

  void selectChoice(GameChoice choice) {
    
    if (answered) {
      return;
    }
    pronunciationService.playPronunciation(choice.id);
    setState(() {
      answered = true;
      selectedChoiceId = choice.id;

      if (choice.correct) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (currentQuestion >= questions.length - 1) {
      final onComplete = widget.onComplete;
      if (onComplete != null) {
        onComplete(score, questions.length);
        return;
      }
      showResult();
      return;
    }

    setState(() {
      currentQuestion++;
      answered = false;
      selectedChoiceId = null;
    });
  }

  void showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complete!'),
          content: Text('You scored $score out of ${questions.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showWinAnimation();
                setState(() {
                  currentQuestion = 0;
                  score = 0;
                  answered = false;
                  selectedChoiceId = null;
                });
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
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

    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentQuestion + 1}/${questions.length}'),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: QuestionView(
              question: question,
              progress: (currentQuestion + 1) / questions.length,
              isLastQuestion: currentQuestion == questions.length - 1,
              selectedChoiceId: selectedChoiceId,
              answered: answered,
              promptLanguage: promptLanguage,
              targetLanguage: targetLanguage,
              displayVariant: displayVariant,
              onChoiceSelected: selectChoice,
              onContinue: nextQuestion,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ConfettiPainter(progress: _confettiController),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
