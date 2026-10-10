import 'dart:convert';

import 'package:flutter/services.dart';

import 'quiz_models.dart';

class GameLoader {
  static Future<List<GameQuestion>> loadQuestions(
    String assetPath, {
    AssetBundle? bundle,
  }) async {
    final jsonString = await (bundle ?? rootBundle).loadString(assetPath);
    final List<dynamic> json = jsonDecode(jsonString);

    return json.map((item) => GameQuestion.fromJson(item)).toList();
  }
}
