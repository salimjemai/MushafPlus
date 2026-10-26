import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts.dart';

final _tts = FlutterTts();
bool _ready = false;
int _token = 0;

Future<void> _init() async {
  if (_ready) return;
  _ready = true;
  try {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
  } catch (_) {}
}

Future<bool> speak(String id, List<(String, String)> parts, ValueNotifier<String?> speaking) async {
  await _init();
  await stop(speaking);
  final token = ++_token;
  speaking.value = id;
  var spoke = false;
  try {
    List<String> voices = const [];
    try {
      final v = await _tts.getLanguages;
      if (v is List) voices = v.map((e) => '$e'.toLowerCase().replaceAll('_', '-')).toList();
    } catch (_) {}
    for (final (text, lang) in parts) {
      if (text.trim().isEmpty) continue;
      final family = lang.split('-').first.toLowerCase();
      if (voices.isNotEmpty && !voices.any((v) => v.startsWith(family))) continue;
      try {
        await _tts.setLanguage(lang);
      } catch (_) {}
      for (final piece in Tts.chunk(text, max: 400)) {
        if (token != _token) break;
        final r = await _tts.speak(piece);
        if (r == 1 || r == true) spoke = true;
      }
    }
  } catch (_) {
    // fall through
  } finally {
    if (token == _token) speaking.value = null;
  }
  return spoke;
}

Future<void> stop(ValueNotifier<String?> speaking) async {
  _token++;
  speaking.value = null;
  try {
    await _tts.stop();
  } catch (_) {}
}
