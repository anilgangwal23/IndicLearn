import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../../language/language_pair.dart';

class SpeedRoundQuestion {
  final String prompt;
  final String answer;
  final List<String> distractors;

  const SpeedRoundQuestion({
    required this.prompt,
    required this.answer,
    required this.distractors,
  });

  factory SpeedRoundQuestion.fromJson(
    Map<String, dynamic> json, {
    required String source,
    required String target,
  }) {
    final answer = localizedJson<String>(json['answer'], target);
    return SpeedRoundQuestion(
      prompt: localizedJson<String>(json['prompt'], source),
      answer: answer,
      distractors: (json['distractors'] as List<dynamic>)
          .map((word) => localizedJson<String>(word, target))
          .where((word) => word != answer)
          .toList(),
    );
  }

  List<String> options(Random random) {
    final wrong = List<String>.of(distractors)..shuffle(random);
    return [answer, ...wrong.take(SpeedRound.optionCount - 1)]..shuffle(random);
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
    LanguagePair? pair,
  }) async {
    final languages = pair ?? LanguagePairController.pair.value;
    final jsonString = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final questions = (decoded['questions'] as List<dynamic>)
        .map(
          (q) => SpeedRoundQuestion.fromJson(
            q as Map<String, dynamic>,
            source: languages.source,
            target: languages.target,
          ),
        )
        .toList();
    return questions..shuffle(random ?? Random());
  }
}
