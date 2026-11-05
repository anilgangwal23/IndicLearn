import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:indic_learn/games/fill_blank/fill_blank_model.dart';
import 'package:indic_learn/games/speed_round/speed_round_model.dart';

void main() {
  const question = FillBlankQuestion(
    sentence: 'मैं ___ जाता हूँ।',
    answer: 'स्कूल',
    distractors: ['घर', 'बाज़ार', 'पानी'],
  );

  group('FillBlankOptions.build', () {
    test('always includes the answer and respects the configured count', () {
      for (final count in [2, 3, 4]) {
        for (var seed = 0; seed < 20; seed++) {
          final options = FillBlankOptions.build(
            question,
            optionCount: count,
            random: Random(seed),
          );
          expect(options, hasLength(count));
          expect(options, contains(question.answer));
          expect(options.toSet(), hasLength(count));
        }
      }
    });

    test('clamps the configured count to the 2 to 4 range', () {
      final low = FillBlankOptions.build(question, optionCount: 1, random: Random(1));
      final high = FillBlankOptions.build(question, optionCount: 9, random: Random(1));
      expect(low, hasLength(2));
      expect(high, hasLength(4));
    });
  });

  group('SpeedRound.multiplierFor', () {
    test('rises every streakPerMultiplier correct answers and caps at max', () {
      expect(SpeedRound.multiplierFor(0), 1);
      expect(SpeedRound.multiplierFor(SpeedRound.streakPerMultiplier), 2);
      expect(SpeedRound.multiplierFor(100), SpeedRound.maxMultiplier);
    });
  });
}
