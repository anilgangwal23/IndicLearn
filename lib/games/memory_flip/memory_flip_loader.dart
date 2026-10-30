import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'memory_flip_model.dart';

class MemoryFlipLoader {
  static Future<List<MemoryFlipCard>> loadCards(
    String assetPath, {
    required int pairCount,
    AssetBundle? bundle,
    Random? random,
  }) async {
    final jsonString = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final allPairs = decoded['pairs'] as List<dynamic>;
    final rng = random ?? Random();
    final pairs = List<dynamic>.of(allPairs)..shuffle(rng);

    final cards = <MemoryFlipCard>[];
    for (var i = 0; i < pairs.length && i < pairCount; i++) {
      final pair = pairs[i] as Map<String, dynamic>;
      cards.add(MemoryFlipCard(pairId: i, text: pair['word'] as String));
      cards.add(MemoryFlipCard(pairId: i, text: pair['translation'] as String));
    }
    cards.shuffle(rng);
    return cards;
  }
}
