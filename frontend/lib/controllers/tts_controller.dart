import 'package:flutter_tts/flutter_tts.dart';

class TTSController {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> initialize() async {
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.9);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> speak(String text, {required String langCode}) async {
    await setLanguage(langCode);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> setLanguage(String langCode) async {
    await _flutterTts.setLanguage(langCode);

    List<dynamic> voices = await _flutterTts.getVoices;

    for (var voice in voices) {
      final voiceMap = Map<String, dynamic>.from(voice);
      final name = voiceMap['name']?.toLowerCase() ?? '';
      final locale = voiceMap['locale'] ?? '';

      if (locale.toString().startsWith(langCode) && name.contains('male')) {
        await _flutterTts.setVoice(Map<String, String>.from(voiceMap));
        break;
      }
    }
  }
}
