import 'speech_engine_stub.dart'
    if (dart.library.js_interop) 'speech_engine_web.dart'
    if (dart.library.io) 'speech_engine_native.dart' as impl;

/// One listening session's text: what the recogniser has finalised and what
/// it is still refining.
typedef SpeechTextCallback = void Function(String finalText, String partialText);

/// Continuous Arabic speech recognition for the recitation checker. The web
/// build talks to the Web Speech API directly (so that Safari and iOS, which
/// only deliver results in non-continuous sessions, work); other platforms
/// use the speech_to_text plugin.
abstract class SpeechEngine {
  /// True when recognition exists on this platform and the user allowed it.
  Future<bool> init();

  /// Best available Arabic locale id (e.g. `ar-SA`).
  Future<String> arabicLocale();

  bool get isListening;

  /// Starts one session. [onText] fires with the session's text so far;
  /// [onEnd] when the session ends for any reason (the caller restarts);
  /// [onError] with a message and whether it is permanent (e.g. permission
  /// denied) or transient (e.g. silence).
  Future<void> start({
    required String locale,
    required SpeechTextCallback onText,
    required void Function() onEnd,
    required void Function(String message, bool permanent) onError,
    void Function(double level)? onLevel,
  });

  Future<void> stop();

  /// Short technical description shown in diagnostics.
  String get description;

  /// Whether sessions are short (non-continuous) and restart often, so the
  /// UI should not treat a session end as a pause.
  bool get shortSessions;
}

SpeechEngine createSpeechEngine() => impl.createSpeechEngine();
