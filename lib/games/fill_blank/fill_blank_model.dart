import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

class FillBlankQuestion {
  static const blank = '___';

  final String sentence;
  final String answer;
  final List<String> distractors;

  const FillBlankQuestion({
    required this.sentence,
    required this.answer,
    required this.distractors,
  });

  factory FillBlankQuestion.fromJson(Map<String, dynamic> json) {
    final answer = json['answer'] as String;
    return FillBlankQuestion(
      sentence: json['sentence'] as String,
      answer: answer,
      distractors: (json['distractors'] as List<dynamic>)
          .cast<String>()
          .where((word) => word != answer)
          .toList(),
    );
  }
}

class FillBlankLoader {
  static Future<List<FillBlankQuestion>> loadQuestions(
    String assetPath, {
    AssetBundle? bundle,
    Random? random,
  }) async {
    final jsonString = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final questions = (decoded['questions'] as List<dynamic>)
        .map((q) => FillBlankQuestion.fromJson(q as Map<String, dynamic>))
        .toList();
    return questions..shuffle(random ?? Random());
  }
}

class FillBlankOptions {
  static const minCount = 2;
  static const maxCount = 4;

  /// Builds the answer choices for [question]. [optionCount] comes from the
  /// level config; when null, a count between [minCount] and [maxCount] is picked.
  static List<String> build(
    FillBlankQuestion question, {
    int? optionCount,
    Random? random,
  }) {
    final rng = random ?? Random();
    final count = (optionCount ?? minCount + rng.nextInt(maxCount - minCount + 1))
        .clamp(minCount, maxCount);
    final wrong = List<String>.of(question.distractors)..shuffle(rng);
    return [question.answer, ...wrong.take(count - 1)]..shuffle(rng);
  }
}
