import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Reads hadith text aloud with the device's text-to-speech voices (there is
/// no recorded hadith audio anywhere public). Speaks the parts in order and
/// reports which item is being read so buttons can show a stop state.
class Tts {
  Tts._();
  static final _tts = FlutterTts();
  static bool _ready = false;
  static int _token = 0;

  /// Id of the item being read, or null.
  static final speaking = ValueNotifier<String?>(null);

  /// BCP-47 voice for the app's hadith language codes.
  static String voiceFor(String hadithLang) => switch (hadithLang) {
        'ara' => 'ar-SA',
        'eng' => 'en-US',
        'urd' => 'ur-PK',
        'fra' => 'fr-FR',
        'ind' => 'id-ID',
        'tur' => 'tr-TR',
        'ben' => 'bn-BD',
        'rus' => 'ru-RU',
        'tam' => 'ta-IN',
        _ => 'en-US',
      };

  static Future<void> _init() async {
    if (_ready) return;
    _ready = true;
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  /// Speaks [parts] (text, language) one after another. Returns false when
  /// no voice exists for the first language.
  static Future<bool> speak(String id, List<(String, String)> parts) async {
    await _init();
    await stop();
    final token = ++_token;
    speaking.value = id;
    var spoke = false;
    try {
      for (final (text, lang) in parts) {
        if (text.trim().isEmpty) continue;
        if (token != _token) break;
        try {
          await _tts.setLanguage(lang);
        } catch (_) {}
        final r = await _tts.speak(text);
        if (r == 1 || r == true) spoke = true;
      }
    } catch (_) {
      // fall through
    } finally {
      if (token == _token) speaking.value = null;
    }
    return spoke;
  }

  static Future<void> stop() async {
    _token++;
    speaking.value = null;
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
