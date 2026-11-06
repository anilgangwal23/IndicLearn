import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum gameAudioTypes {
  correctAnswer,
  incorrectAnswer,
  levelComplete,
  levelFailed
}

/// Maps a learner language code to the TTS locale used to speak it.
const Map<String, String> ttsLocales = {
  'en': 'en-IN',
  'hi': 'hi-IN',
  'kn': 'kn-IN',
  'mr': 'mr-IN',
  'pa': 'pa-IN',
  'te': 'te-IN',
};

class PronunciationService {
  final audioPlayer = AudioPlayer();
  final tts = FlutterTts();
  final Map<gameAudioTypes, AudioPlayer> _sfxPlayers = {
    for (final type in gameAudioTypes.values) type: AudioPlayer(),
  };

  PronunciationService._() {
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _setSpeaking(false);
      }
    });
    tts.setStartHandler(() => _setSpeaking(true));
    tts.setCompletionHandler(() => _setSpeaking(false));
    tts.setCancelHandler(() => _setSpeaking(false));
    tts.setErrorHandler((_) => _setSpeaking(false));
  }
  static final PronunciationService instance = PronunciationService._();

  /// True while a pronunciation (audio file or TTS) is playing.
  final ValueNotifier<bool> speaking = ValueNotifier<bool>(false);

  Future<Map<String, dynamic>>? _mappingFuture;
  String? _currentLanguage;
  Future<void>? _warmUpFuture;

  /// Loads the sound effects and the TTS engine ahead of the first tap so
  /// the first pronunciation does not pay the cold-start cost.
  Future<void> warmUp() {
    return _warmUpFuture ??= Future.wait([
      for (final entry in _sfxPlayers.entries)
        entry.value.setAsset(_sfxAssetPath(entry.key)),
      tts.awaitSpeakCompletion(false),
      tts.setLanguage('hi-IN').then((_) => _currentLanguage = 'hi-IN'),
    ]).then((_) {}).catchError((Object _) {
      _warmUpFuture = null;
    });
  }

  void _setSpeaking(bool value) {
    if (speaking.value != value) speaking.value = value;
  }

  Future<void> _setLanguageIfChanged(String language) async {
    if (_currentLanguage == language) return;
    await tts.setLanguage(language);
    _currentLanguage = language;
  }

  static String _sfxAssetPath(gameAudioTypes type) {
    switch (type) {
      case gameAudioTypes.correctAnswer:
        return 'assets/audio/game_sounds/correct_answer.wav';
      case gameAudioTypes.incorrectAnswer:
        return 'assets/audio/game_sounds/wrong_answer.wav';
      case gameAudioTypes.levelComplete:
        return 'assets/audio/game_sounds/level_complete.wav';
      case gameAudioTypes.levelFailed:
        return 'assets/audio/game_sounds/level_failed.wav';
    }
  }

  Future<Map<String, dynamic>> _loadMapping() {
    return _mappingFuture ??= rootBundle
        .loadString('assets/audio/mapping.json')
        .then((s) => jsonDecode(s) as Map<String, dynamic>)
        .catchError((Object e) {
          _mappingFuture = null;
          throw e;
        });
  }


  /// Plays a sound effect on its own player, so it never cuts off a
  /// pronunciation and never reloads its asset.
  Future<void> playGameAudio(gameAudioTypes type) async {
    await warmUp();
    final player = _sfxPlayers[type]!;
    try {
      await player.seek(Duration.zero);
      await player.play();
    } on PlayerInterruptedException {
      // A newer sound replaced this one while it was loading.
    }
  }

  Future<void> playPronunciation(
    String id, {
    String? text,
    String? language,
  }) async {
    final mapping = await _loadMapping();
    final entry = (text != null ? mapping[text] : null) ?? mapping[id];
    final locale = language == null ? null : ttsLocales[language];
    final clip = entry?['file'] as String? ?? '';
    final clipLocale = entry?['language'] as String? ?? 'hi-IN';
    await tts.stop();
    if (clip.isNotEmpty && (locale == null || clipLocale == locale)) {
      _setSpeaking(true);
      try {
        await audioPlayer.setAsset('assets/audio/$clip');
        await audioPlayer.play();
        return;
      } on PlayerInterruptedException {
        // A newer sound replaced this one while it was loading.
        return;
      } catch (e) {
        // Clip is missing or unplayable; speak the text with TTS instead.
        debugPrint('Pronunciation clip "$clip" failed, using TTS: $e');
      }
    }
    await _setLanguageIfChanged(locale ?? clipLocale);
    await tts.speak(text ?? entry?['native'] as String? ?? id);
  }
}
