import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../quiz.dart' show GamePage;
import '../quiz_models.dart';
import 'choice_button.dart';
import '../../../ui/game_theme.dart';
import '../../../ui/game_widgets.dart';
import '../../../l10n/app_localizations.dart';

@Preview(name: 'Quiz', size: Size(390, 844))
Widget previewQuiz() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: buildGameTheme(),
    home: const GamePage(),
  );
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
  final bool introducing;
  final VoidCallback? onIntroductionComplete;
  final VoidCallback? onPlayPronunciation;

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
    this.introducing = false,
    this.onIntroductionComplete,
    this.onPlayPronunciation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (introducing) {
      final choice = question.choices.firstWhere((choice) => choice.correct);
      final meaning =
          choice.text[promptLanguage] ?? question.prompt[promptLanguage];
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 24),
                if (choice.image.isNotEmpty)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 480,
                        maxHeight: 280,
                      ),
                      child: Semantics(
                        image: true,
                        label:
                            meaning?.native ??
                            choice.text[targetLanguage]!.native,
                        child: AspectRatio(
                          aspectRatio: 5 / 3,
                          child: SvgPicture.asset(
                            choice.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  choice.text[targetLanguage]!.display(variant: displayVariant),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (meaning != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    meaning.native,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Center(
                  child: IconButton.filledTonal(
                    tooltip: l10n.quizQuestionListen,
                    iconSize: 28,
                    padding: const EdgeInsets.all(16),
                    icon: const Icon(Icons.volume_up),
                    onPressed: onPlayPronunciation,
                  ),
                ),
                const SizedBox(height: 24),
                GameButton(
                  onPressed: onIntroductionComplete,
                  label: l10n.continueLabel,
                  icon: Icons.arrow_forward,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 24),
          QuestionPrompt(
            text: question.prompt[promptLanguage]!.display(variant: 'native'),
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
          if (answered) ...[
            GameFeedback(
              correct: question.choices.any(
                (choice) => choice.id == selectedChoiceId && choice.correct,
              ),
              message:
                  question.choices.any(
                    (choice) => choice.id == selectedChoiceId && choice.correct,
                  )
                  ? l10n.quizQuestionCorrect
                  : l10n.quizQuestionNotQuite,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: GameButton(
                onPressed: onContinue,
                label: isLastQuestion ? l10n.quizQuestionFinish : l10n.continueLabel,
                icon: isLastQuestion ? Icons.check : Icons.arrow_forward,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
