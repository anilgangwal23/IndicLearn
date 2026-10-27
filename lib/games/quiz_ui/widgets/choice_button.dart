import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../quiz_models.dart';
import '../../../ui/game_widgets.dart';
import '../../../animations/correct_answer.dart';
import '../../../ui/game_theme.dart';

class ChoiceButton extends StatelessWidget {
  final GameChoice choice;
  final String language;
  final String variant;
  final bool selected;
  final bool answered;
  final VoidCallback onPressed;

  const ChoiceButton({
    super.key,
    required this.choice,
    required this.language,
    required this.variant,
    required this.selected,
    required this.answered,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final languageText = choice.text[language]!;
    final state = answered && choice.correct
        ? AnswerVisualState.correct
        : answered && selected
        ? AnswerVisualState.incorrect
        : selected
        ? AnswerVisualState.selected
        : AnswerVisualState.idle;

    final tile =  SizedBox(
      width: double.infinity,
      child: GameAnswerTile(
        state: state,
        onPressed: answered ? null : onPressed,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  if (choice.image.isNotEmpty) ...[
                    SvgPicture.asset(
                      choice.image,
                      height: 96,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    languageText.native,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (languageText.romanized != null)
                    Text(
                      languageText.romanized!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    final theme = Theme.of(context);
    final burstColor = 
      theme.extension<GameFeedbackColors>()?.success ?? 
      theme.colorScheme.primary;
    return Stack(
      children: [
        tile,
        if(answered &&
        selected &&
        choice.correct &&
        !MediaQuery.of(context).disableAnimations)
        Positioned.fill(
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin : 0, end : 1), 
              duration: Duration(milliseconds: 500), 
              builder: (context, value, child) {
                return CustomPaint(
                  painter: CorrectAnswerBurstPainter(
                    color: burstColor,
                    progress: AlwaysStoppedAnimation<double>(value),
                  ),
                );
              },
            )
          )
        )
      ]
    );
  }
}
