import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PronunciationService {
  Map<String, dynamic> _pronunciationMapping = {};
  final audioPlayer = AudioPlayer();
  final tts = FlutterTts();
  late final Future<void> _mappingReady;
  PronunciationService() {
    _mappingReady = _loadPronunciationMapping();
  }

  Future<void> _loadPronunciationMapping() async {
    _pronunciationMapping = jsonDecode(
      await rootBundle.loadString('assets/audio/mapping.json'),
    );
  }

  Future<void> playPronunciation(String id) async {
    await _mappingReady;
    final entry = _pronunciationMapping[id];
    await tts.setLanguage(entry?['language'] as String? ?? 'hi-IN');
    // Implementation for playing pronunciation audio
    if (_pronunciationMapping[id] != null) {
      String file = _pronunciationMapping[id]['file'];
      if (file.isNotEmpty) {
        // Play the audio file using your preferred audio player
        await audioPlayer.setAsset('assets/audio/$file');
        await audioPlayer.play();
      } else {
        String native = _pronunciationMapping[id]['native'];
        await tts.speak(native);
      }
    } else {
      // If no mapping is found, fallback to TTS
      await tts.speak(id);
    }
  }
}
