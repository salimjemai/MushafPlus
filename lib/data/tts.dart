import 'package:flutter/foundation.dart';

import 'tts_stub.dart' if (dart.library.js_interop) 'tts_web.dart' if (dart.library.io) 'tts_io.dart' as impl;

/// Reads hadith text aloud with the device's text-to-speech voices. Recorded
/// recitations (Hadith.to) are preferred where they exist; see
/// hadith_audio.dart, which falls back to this for translations and for the
/// collections without recordings.
///
/// On the web the browser's speech API is driven directly and every
/// utterance is queued synchronously inside the user's tap, which Safari on
/// iPhone and iPad requires; long texts are split into short sentences so
/// Chrome does not cut them off. Native platforms use flutter_tts.
class Tts {
  Tts._();

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

  /// Speaks [parts] (text, language) one after another. Must be called
  /// synchronously from a tap handler. Resolves to false when no voice could
  /// be used.
  static Future<bool> speak(String id, List<(String, String)> parts) => impl.speak(id, parts, speaking);

  static Future<void> stop() => impl.stop(speaking);

  /// Splits text into utterances of roughly [max] characters at sentence
  /// and clause boundaries.
  static List<String> chunk(String text, {int max = 180}) {
    final out = <String>[];
    final buf = StringBuffer();
    for (final piece in text.split(RegExp(r'(?<=[.!?؟।۔:;،,])\s+|\n+'))) {
      final p = piece.trim();
      if (p.isEmpty) continue;
      if (buf.isNotEmpty && buf.length + p.length + 1 > max) {
        out.add(buf.toString());
        buf.clear();
      }
      if (p.length > max) {
        if (buf.isNotEmpty) {
          out.add(buf.toString());
          buf.clear();
        }
        // very long clause: cut at spaces
        var rest = p;
        while (rest.length > max) {
          var cut = rest.lastIndexOf(' ', max);
          if (cut < max ~/ 2) cut = max;
          out.add(rest.substring(0, cut).trim());
          rest = rest.substring(cut).trim();
        }
        if (rest.isNotEmpty) buf.write(rest);
        continue;
      }
      if (buf.isNotEmpty) buf.write(' ');
      buf.write(p);
    }
    if (buf.isNotEmpty) out.add(buf.toString());
    return out;
  }
}
