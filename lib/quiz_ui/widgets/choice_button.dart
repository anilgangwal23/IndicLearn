import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../quiz_models.dart';

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
    Color? backgroundColor;

    if (answered) {
      if (choice.correct) {
        backgroundColor = Colors.green.withValues(alpha: 0.15);
      } else if (selected) {
        backgroundColor = Colors.red.withValues(alpha: 0.15);
      }
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: answered ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  if (choice.image.isNotEmpty)
                    SvgPicture.asset(
                      '${choice.image}',
                      fit: BoxFit.contain,
                    ),
                  const SizedBox(height: 20),
                  Text(
                    languageText.native,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (languageText.romanized != null)
                    Text(
                      languageText.romanized!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            if (answered && choice.correct)
              const Icon(Icons.check_circle, color: Colors.green),
            if (answered && selected && !choice.correct)
              const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
