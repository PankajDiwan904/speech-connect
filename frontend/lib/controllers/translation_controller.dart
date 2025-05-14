import 'package:translator/translator.dart';

class TranslationController {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> translateText(String text, String fromLang, String toLang) async {
    try {
      final translation = await _translator.translate(text, from: fromLang, to: toLang);
      return translation.text;
    } catch (e) {
      print("Translation error: $e");
      return "Translation failed";
    }
  }
}
