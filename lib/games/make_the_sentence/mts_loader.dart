import 'dart:convert';

import 'package:flutter/services.dart';

import '../../language/language_pair.dart';
import 'mts_model.dart';

class GameLoader {
  static Future<MTSModel> loadMTSModel(
    String assetPath, {
    AssetBundle? bundle,
    LanguagePair? pair,
  }) async {
    final languages = pair ?? LanguagePairController.pair.value;
    final jsonString = await (bundle ?? rootBundle).loadString(assetPath);
    final dynamic decoded = jsonDecode(jsonString);
    MTSModel model = MTSModel.fromJson(
      decoded as Map<String, dynamic>,
      source: languages.source,
      target: languages.target,
    );
    return model;
  }
}
