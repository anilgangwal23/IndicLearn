import 'dart:convert';

import 'package:flutter/services.dart';

import 'pair_model.dart';

class GameLoader {
  static Future<List<MatchPairData>> loadPairings(
    String assetPath, {
    AssetBundle? bundle,
  }) async {
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
            leftWord: entry.value['left_word'],
            rightDef: entry.value['right_definition'],
            originalIndex: entry.value['original_index'] ?? entry.key,
          ),
        )
        .toList();
  }
}
