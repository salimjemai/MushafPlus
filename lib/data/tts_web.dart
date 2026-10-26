import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'tts.dart';

int _token = 0;

bool get _supported => globalContext.has('speechSynthesis');

web.SpeechSynthesisVoice? _voiceFor(String lang, List<web.SpeechSynthesisVoice> voices) {
  final family = lang.split('-').first.toLowerCase();
  web.SpeechSynthesisVoice? exact;
  web.SpeechSynthesisVoice? sameFamily;
  for (final v in voices) {
    final vl = v.lang.toLowerCase().replaceAll('_', '-');
    if (vl == lang.toLowerCase()) exact ??= v;
    if (vl.startsWith(family)) sameFamily ??= v;
  }
  return exact ?? sameFamily;
}

/// Queues every utterance synchronously: Safari only speaks what was queued
/// during the tap, and queuing several utterances at once is allowed.
Future<bool> speak(String id, List<(String, String)> parts, ValueNotifier<String?> speaking) async {
  if (!_supported) return false;
  final synth = web.window.speechSynthesis;
  final token = ++_token;
  // Cancelling right before speaking makes Safari drop the new speech, so
  // cancel only when something is actually playing.
  if (synth.speaking || synth.pending) synth.cancel();
  final voices = synth.getVoices().toDart;
  final utterances = <web.SpeechSynthesisUtterance>[];
  for (final (text, lang) in parts) {
    if (text.trim().isEmpty) continue;
    final voice = _voiceFor(lang, voices);
    // No voice for that language on this device: skip the part rather than
    // read Arabic with an English voice.
    if (voices.isNotEmpty && voice == null) continue;
    for (final piece in Tts.chunk(text)) {
      final u = web.SpeechSynthesisUtterance(piece)
        ..lang = lang
        ..rate = 0.9
        ..pitch = 1.0;
      if (voice != null) u.voice = voice;
      utterances.add(u);
    }
  }
  if (utterances.isEmpty) return false;

  speaking.value = id;
  final last = utterances.last;
  void done(web.Event _) {
    if (token == _token) speaking.value = null;
  }

  last.onend = done.toJS;
  for (final u in utterances) {
    u.onerror = done.toJS;
    synth.speak(u);
  }
  // Safari sometimes starts in a paused state.
  synth.resume();
  return true;
}

Future<void> stop(ValueNotifier<String?> speaking) async {
  _token++;
  speaking.value = null;
  if (_supported) web.window.speechSynthesis.cancel();
}
