import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

class SpeedRoundQuestion {
  final String prompt;
  final String answer;
  final List<String> distractors;

  const SpeedRoundQuestion({
    required this.prompt,
    required this.answer,
    required this.distractors,
  });

  factory SpeedRoundQuestion.fromJson(Map<String, dynamic> json) {
    final answer = json['answer'] as String;
    return SpeedRoundQuestion(
      prompt: json['prompt'] as String,
      answer: answer,
      distractors: (json['distractors'] as List<dynamic>)
          .cast<String>()
          .where((word) => word != answer)
          .toList(),
    );
  }

  List<String> options(Random random) {
    final wrong = List<String>.of(distractors)..shuffle(random);
    return [answer, ...wrong.take(SpeedRound.optionCount - 1)]
      ..shuffle(random);
  }
}

class SpeedRound {
  static const roundSeconds = 80;
  static const optionCount = 4;
  static const maxMultiplier = 3;
  static const streakPerMultiplier = 3;

  /// Points for a correct answer given the current streak.
  static int multiplierFor(int streak) =>
      (1 + streak ~/ streakPerMultiplier).clamp(1, maxMultiplier);
}

class SpeedRoundLoader {
  static Future<List<SpeedRoundQuestion>> loadQuestions(
    String assetPath, {
    AssetBundle? bundle,
    Random? random,
  }) async {
    final jsonString = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final questions = (decoded['questions'] as List<dynamic>)
        .map((q) => SpeedRoundQuestion.fromJson(q as Map<String, dynamic>))
        .toList();
    return questions..shuffle(random ?? Random());
  }
}
