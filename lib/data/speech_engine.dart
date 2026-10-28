import 'speech_engine_stub.dart' if (dart.library.js_interop) 'speech_engine_web.dart' if (dart.library.io) 'speech_engine_native.dart'
    as impl;

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

/// Progress of the one-time download and initialisation of a downloadable
/// engine's model. [stage] is "download", "init" or "ready"; [loaded] and
/// [total] are bytes (0 until known).
class ModelLoadProgress {
  const ModelLoadProgress({required this.stage, required this.loaded, required this.total});
  final String stage;
  final int loaded;
  final int total;
  bool get ready => stage == 'ready';
}

/// A [SpeechEngine] whose model must be fetched once and kept on the device.
/// The caller asks before the download and shows the progress.
abstract class DownloadableSpeechEngine implements SpeechEngine {
  /// Whether the model is loaded and recognition can start at once.
  bool get isReady;

  /// Whether the model files are already stored on this device, so that
  /// [prepare] will not download anything.
  Future<bool> isCached();

  /// Size of the one-time download, for the consent dialog.
  int get approximateDownloadBytes;

  /// Whether inference is hardware accelerated (otherwise results lag).
  bool get accelerated;

  /// One short technical line for the screen: backend, threads and the time
  /// of the last recognition pass, e.g. "wasm ×3 · 2.4 s". Empty until loaded.
  String get diagnostics;

  /// Downloads (if needed) and loads the model, reporting progress.
  Future<void> prepare({void Function(ModelLoadProgress p)? onProgress});

  /// Called when the screen that used the engine goes away: frees the model
  /// where memory is tight (phones and tablets), so the rest of the app does
  /// not slow down; it is reloaded from the on-device cache next time.
  void release();
}

/// Creates the engine for this platform. [voiceModel] asks for the on-device
/// Mushaf+ voice model where it exists (web); other platforms ignore it.
SpeechEngine createSpeechEngine({bool voiceModel = false}) => impl.createSpeechEngine(voiceModel: voiceModel);

/// True (once) when the last page load died while the on-device voice model
/// was loading or listening; the caller should fall back to the browser
/// recogniser and tell the user. Always false off the web.
bool voiceModelCrashedLastTime() => impl.voiceModelCrashedLastTime();
