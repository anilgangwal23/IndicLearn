import '../games/quiz_ui/quiz.dart';
import 'package:flutter/material.dart';
import '../games/match_the_pair/pairing.dart';
import '../games/make_the_sentence/mts.dart';
import '../games/follow_the_sound/fts.dart';
import '../games/memory_flip/memory_flip.dart';
import '../games/fill_blank/fill_blank.dart';
import '../games/speed_round/speed_round.dart';
dynamic getHandler(
  String handler,
  ValueKey key,
  String? assetPath,
  void Function(int, int)? onComplete, {
  bool embeddedInLevel = false,
  VoidCallback? onLoseLife,
  String? mascotAsset,
  Map<String, dynamic> config = const {},
}) {
  switch (handler) {
    case 'GamePage':
      return GamePage(
        key: key,
        assetPath: assetPath!,
        onComplete: onComplete!,
        embeddedInLevel: embeddedInLevel,
        onLoseLife: onLoseLife,
      );
    case 'WordMatchPage':
      return WordMatchPage(
        key: key,
        initialJsonData: assetPath!,
        onComplete: onComplete!,
        embeddedInLevel: embeddedInLevel,
        onLoseLife: onLoseLife,
      );
    case 'MTSPage':
      return mts(
        key: key,
        initialJsonData: assetPath!,
        onComplete: onComplete!,
        embeddedInLevel: embeddedInLevel,
        onLoseLife: onLoseLife,
      );
    case 'FollowTheSound':
      return fts(
        key: key,
        initialJsonData: assetPath!,
        onComplete: onComplete!,
        embeddedInLevel: embeddedInLevel,
        onLoseLife: onLoseLife,
        mascotAsset: mascotAsset,
      );
    case 'MemoryFlipPage':
      return MemoryFlipPage(
        key: key,
        initialJsonData: assetPath!,
        onComplete: onComplete!,
        embeddedInLevel: embeddedInLevel,
        onLoseLife: onLoseLife,
      );
    case 'FillBlankPage':
      return FillBlankPage(
        key: key,
        initialJsonData: assetPath!,
        onComplete: onComplete!,
        embeddedInLevel: embeddedInLevel,
        onLoseLife: onLoseLife,
        optionCount: config['optionCount'] as int?,
      );
    case 'SpeedRoundPage':
      return SpeedRoundPage(
        key: key,
        initialJsonData: assetPath!,
        onComplete: onComplete!,
        embeddedInLevel: embeddedInLevel,
        onLoseLife: onLoseLife,
      );
    default:
      return null;
  }
}