import '../games/quiz_ui/quiz.dart';
import 'package:flutter/material.dart';
import '../games/match_the_pair/pairing.dart';
import '../games/make_the_sentence/mts.dart';
import '../games/follow_the_sound/fts.dart';
dynamic getHandler(String handler,ValueKey key, String? assetPath, void Function(int,int)? onComplete) {
  switch (handler) {
    case 'GamePage':
      return GamePage(
        key: key,
        assetPath: assetPath!,
        onComplete: onComplete!,
      );
    case 'WordMatchPage':
      return WordMatchPage(
        key: key,
        initialJsonData: assetPath!,
        onComplete: onComplete!,
      );
    case 'MTSPage':
      return mts(
        key: key,
        initialJsonData: assetPath!,
        onComplete: onComplete!,
      );
    case 'FollowTheSound':
      return fts(
        key: key,
        initialJsonData: assetPath!,
        onComplete: onComplete!,
      );
    default:
      return null;
  }
}