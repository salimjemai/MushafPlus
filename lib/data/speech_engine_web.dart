import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'speech_engine.dart';
import 'speech_engine_whisper_web.dart';

SpeechEngine createSpeechEngine({bool voiceModel = false}) =>
    voiceModel && WhisperWebSpeechEngine.supported ? WhisperWebSpeechEngine() : _WebSpeechEngine();

/// Direct Web Speech API client.
///
/// Chrome and Edge deliver interim and final results in one long continuous
/// session. WebKit (Safari, and every browser on iOS and iPadOS) only
/// delivers results reliably when `continuous` is false, one utterance per
/// session, so there each session is short and the caller restarts it.
class _WebSpeechEngine implements SpeechEngine {
  web.SpeechRecognition? _rec;
  bool _listening = false;
  bool _supported = false;

  static bool get _isAppleWebKit {
    final ua = web.window.navigator.userAgent;
    final apple = ua.contains('AppleWebKit') && !ua.contains('Chrome/') && !ua.contains('Chromium/');
    final ios = ua.contains('iPhone') || ua.contains('iPad') || ua.contains('iPod') || ua.contains('CriOS') || ua.contains('FxiOS') ||
        (ua.contains('Macintosh') && web.window.navigator.maxTouchPoints > 1);
    return apple || ios;
  }

  static String? get _ctorName {
    if (globalContext.has('SpeechRecognition')) return 'SpeechRecognition';
    if (globalContext.has('webkitSpeechRecognition')) return 'webkitSpeechRecognition';
    return null;
  }

  @override
  Future<bool> init() async {
    _supported = _ctorName != null;
    return _supported;
  }

  @override
  Future<String> arabicLocale() async => 'ar-SA';

  @override
  bool get isListening => _listening;

  @override
  bool get shortSessions => _isAppleWebKit;

  @override
  String get description => 'Web Speech API (${_ctorName ?? 'unsupported'}, ${_isAppleWebKit ? 'short sessions' : 'continuous'})';

  @override
  Future<void> start({
    required String locale,
    required SpeechTextCallback onText,
    required void Function() onEnd,
    required void Function(String message, bool permanent) onError,
    void Function(double level)? onLevel,
  }) async {
    final name = _ctorName;
    if (name == null) {
      onError('speech_not_supported', true);
      return;
    }
    await stop();
    final ctor = globalContext.getProperty<JSFunction>(name.toJS);
    final rec = ctor.callAsConstructor<web.SpeechRecognition>();
    _rec = rec;
    rec.lang = locale;
    rec.interimResults = true;
    rec.continuous = !_isAppleWebKit;
    rec.maxAlternatives = 1;

    var ended = false;
    void end() {
      if (ended) return;
      ended = true;
      _listening = false;
      if (identical(_rec, rec)) _rec = null;
      onEnd();
    }

    rec.onstart = ((web.Event _) {
      _listening = true;
    }).toJS;
    rec.onresult = ((web.SpeechRecognitionEvent e) {
      final finals = StringBuffer();
      final partials = StringBuffer();
      final results = e.results;
      for (var i = 0; i < results.length; i++) {
        final r = results.item(i);
        if (r.length == 0) continue;
        final t = r.item(0).transcript.trim();
        if (t.isEmpty) continue;
        (r.isFinal ? finals : partials)
          ..write(t)
          ..write(' ');
      }
      onText(finals.toString().trim(), partials.toString().trim());
    }).toJS;
    rec.onerror = ((web.SpeechRecognitionErrorEvent e) {
      final code = e.error;
      final permanent = code == 'not-allowed' || code == 'service-not-allowed' || code == 'language-not-supported' || code == 'audio-capture';
      onError(code, permanent);
      if (permanent) end();
    }).toJS;
    rec.onend = ((web.Event _) => end()).toJS;
    try {
      rec.start();
      _listening = true;
    } catch (e) {
      onError('$e', false);
      end();
    }
  }

  @override
  Future<void> stop() async {
    final rec = _rec;
    _rec = null;
    _listening = false;
    if (rec != null) {
      try {
        rec.onend = null;
        rec.onresult = null;
        rec.onerror = null;
        rec.abort();
      } catch (_) {}
    }
  }
}
