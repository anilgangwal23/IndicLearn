import 'dart:convert';

import 'package:flutter/services.dart';

import '../../language/language_pair.dart';
import 'pair_model.dart';

class GameLoader {
  static Future<List<MatchPairData>> loadPairings(
    String assetPath, {
    AssetBundle? bundle,
    LanguagePair? pair,
  }) async {
    final languages = pair ?? LanguagePairController.pair.value;
    final jsonString = await (bundle ?? rootBundle).loadString(assetPath);
    final dynamic decoded = jsonDecode(jsonString);
    final List<dynamic> json = decoded is List
        ? decoded
        : decoded['word_pair_list'] as List<dynamic>;

    return json
        .asMap()
        .entries
        .map(
          (entry) => MatchPairData(
            leftWord: localizedJson<String>(
              entry.value['left_word'],
              languages.source,
            ),
            rightDef: localizedJson<String>(
              entry.value['right_definition'],
              languages.target,
            ),
            originalIndex: entry.value['original_index'] ?? entry.key,
          ),
        )
        .toList();
  }
}
