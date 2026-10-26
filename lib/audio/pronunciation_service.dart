import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum gameAudioTypes {
  correctAnswer,
  incorrectAnswer,
  levelComplete,
  levelFailed
}

class PronunciationService {
  //Map<String, dynamic> _pronunciationMapping = {};
  final audioPlayer = AudioPlayer();
  final tts = FlutterTts();
  //late final Future<void> _mappingReady;
  PronunciationService._();
  static final PronunciationService instance = PronunciationService._();

  Future<Map<String, dynamic>>? _mappingFuture;
  String? _currentLanguage;

  Future<void> _setLanguageIfChanged(String language) async {
    if (_currentLanguage == language) return;
    await tts.setLanguage(language);
    _currentLanguage = language;
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


  Future<void> playGameAudio(gameAudioTypes type) async {
    // Implementation for playing game audio based on the type
    String file = '';
    switch (type) {
      case gameAudioTypes.correctAnswer:
        file = 'correct_answer.wav';
        break;
      case gameAudioTypes.incorrectAnswer:
        file = 'wrong_answer.wav';
        break;
      case gameAudioTypes.levelComplete:
        file = 'level_complete.wav';
        break;
      case gameAudioTypes.levelFailed:
        file = 'level_failed.wav';
        break;
    }
    if (file.isNotEmpty) {
      await audioPlayer.setAsset('assets/audio/game_sounds/$file');
      await audioPlayer.play();
    }
  }


  Future<void> playPronunciation(String id) async {
    final mapping = await _loadMapping();
    final entry = mapping[id];
    await _setLanguageIfChanged(entry?['language'] as String? ?? 'hi-IN');
    // Implementation for playing pronunciation audio
    if (mapping[id] != null) {
      String file = mapping[id]['file'];
      if (file.isNotEmpty) {
        // Play the audio file using your preferred audio player
        await audioPlayer.setAsset('assets/audio/$file');
        await audioPlayer.play();
      } else {
        String native = mapping[id]['native'];
        await tts.speak(native);
      }
    } else {
      // If no mapping is found, fallback to TTS
      await tts.speak(id);
    }
  }
}
