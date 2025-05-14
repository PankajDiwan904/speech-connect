import 'package:speech_to_text/speech_to_text.dart';

class STTController {
  final SpeechToText _speech = SpeechToText();
  bool isListening = false;

  Future<void> initialize() async {
    await _speech.initialize();
  }

  Future<void> startListening(
    Function(String) onResult,
    Function onFinalResult,
    String langCode,
  ) async {
    isListening = true;
    await _speech.listen(
      localeId: langCode,
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) onFinalResult();
      },
    );
  }

  Future<void> stop() async {
    await _speech.stop();
    isListening = false;
  }
}
