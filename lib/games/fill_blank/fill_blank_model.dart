import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../../language/language_pair.dart';

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

  factory FillBlankQuestion.fromJson(
    Map<String, dynamic> json, {
    required String source,
    required String target,
  }) {
    final answer = localizedJson<String>(json['answer'], target);
    return FillBlankQuestion(
      sentence: localizedJson<String>(json['sentence'], source),
      answer: answer,
      distractors: (json['distractors'] as List<dynamic>)
          .map((word) => localizedJson<String>(word, target))
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
    LanguagePair? pair,
  }) async {
    final languages = pair ?? LanguagePairController.pair.value;
    final jsonString = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final questions = (decoded['questions'] as List<dynamic>)
        .map(
          (q) => FillBlankQuestion.fromJson(
            q as Map<String, dynamic>,
            source: languages.source,
            target: languages.target,
          ),
        )
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
    final count =
        (optionCount ?? minCount + rng.nextInt(maxCount - minCount + 1)).clamp(
          minCount,
          maxCount,
        );
    final wrong = List<String>.of(question.distractors)..shuffle(rng);
    return [question.answer, ...wrong.take(count - 1)]..shuffle(rng);
  }
}
