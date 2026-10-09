import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../quiz.dart' show GamePage;
import '../quiz_models.dart';
import 'choice_button.dart';

@Preview(name: 'Quiz', size: Size(390, 844))
Widget previewQuiz() {
  return const MaterialApp(home: GamePage());
}

class QuestionView extends StatelessWidget {
  final GameQuestion question;
  final double progress;
  final bool isLastQuestion;
  final String? selectedChoiceId;
  final bool answered;
  final String promptLanguage;
  final String targetLanguage;
  final String displayVariant;
  final ValueChanged<GameChoice> onChoiceSelected;
  final VoidCallback onContinue;

  const QuestionView({
    super.key,
    required this.question,
    required this.progress,
    required this.isLastQuestion,
    required this.selectedChoiceId,
    required this.answered,
    required this.promptLanguage,
    required this.targetLanguage,
    required this.displayVariant,
    required this.onChoiceSelected,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          LinearProgressIndicator(value: progress),
          Text(
            question.prompt[promptLanguage]!.display(variant: 'native'),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 4,
            child: ListView.separated(
              itemCount: question.choices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final choice = question.choices[index];

                return ChoiceButton(
                  choice: choice,
                  language: targetLanguage,
                  variant: displayVariant,
                  selected: selectedChoiceId == choice.id,
                  answered: answered,
                  onPressed: () => onChoiceSelected(choice),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (answered)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onContinue,
                child: Text(isLastQuestion ? 'Finish' : 'Continue'),
              ),
            ),
        ],
      ),
    );
  }
}
