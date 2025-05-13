// lib/controllers/stt_controller.dart
import 'package:speech_to_text/speech_to_text.dart';

class STTController {
  final SpeechToText _speech = SpeechToText();

  Future<bool> initialize() async {
    return await _speech.initialize();
  }

  Future<void> startListening(
    Function(String) onResult,
    Function onFinalResult,
    String localeId,
  ) async {
    await _speech.listen(
      localeId: localeId,
      listenMode: ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onFinalResult();
        }
      },
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
}
