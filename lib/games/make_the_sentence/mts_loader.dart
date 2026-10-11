import 'dart:convert';

import 'package:flutter/services.dart';

import 'mts_model.dart';

class GameLoader {
  static Future<MTSModel> loadMTSModel(
    String assetPath, {
    AssetBundle? bundle,
  }) async {
    final jsonString = await (bundle ?? rootBundle).loadString(assetPath);
    final dynamic decoded = jsonDecode(jsonString);
    MTSModel model = MTSModel.fromJson(decoded as Map<String, dynamic>);
    return model;
  }

}