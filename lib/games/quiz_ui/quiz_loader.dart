import 'dart:convert';

import 'package:flutter/services.dart';

import '../../language/language_pair.dart';
import 'quiz_models.dart';

class GameLoader {
  static Future<List<GameQuestion>> loadQuestions(
    String assetPath, {
    AssetBundle? bundle,
    LanguagePair? pair,
  }) async {
    final jsonString = await (bundle ?? rootBundle).loadString(assetPath);
    final List<dynamic> json = jsonDecode(jsonString);

    return json.map((item) {
      final question = GameQuestion.fromJson(item);
      return pair == null ? question : question.withPair(pair);
    }).toList();
  }
}
