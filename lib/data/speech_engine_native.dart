import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'speech_engine.dart';

SpeechEngine createSpeechEngine({bool voiceModel = false}) => _PluginSpeechEngine();

/// Android, iOS, macOS and Windows via the speech_to_text plugin.
class _PluginSpeechEngine implements SpeechEngine {
  final _speech = SpeechToText();
  bool _available = false;
  void Function()? _onEnd;
  void Function(String message, bool permanent)? _onError;

  @override
  Future<bool> init() async {
    try {
      _available = await _speech.initialize(
        onError: (SpeechRecognitionError e) {
          _onError?.call(e.errorMsg, e.permanent);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') _onEnd?.call();
        },
      );
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  @override
  Future<String> arabicLocale() async {
    try {
      final locales = await _speech.locales();
      final ar = locales.where((l) => l.localeId.toLowerCase().startsWith('ar'));
      return ar.where((l) => l.localeId.toLowerCase().contains('sa')).firstOrNull?.localeId ?? ar.firstOrNull?.localeId ?? 'ar-SA';
    } catch (_) {
      return 'ar-SA';
    }
  }

  @override
  bool get isListening => _speech.isListening;

  @override
  bool get shortSessions => false;

  @override
  String get description => 'speech_to_text plugin';

  @override
  Future<void> start({
    required String locale,
    required SpeechTextCallback onText,
    required void Function() onEnd,
    required void Function(String message, bool permanent) onError,
    void Function(double level)? onLevel,
  }) async {
    _onEnd = onEnd;
    _onError = onError;
    var finalText = '';
    await _speech.listen(
      onResult: (SpeechRecognitionResult r) {
        if (r.finalResult) {
          finalText = '$finalText ${r.recognizedWords}'.trim();
          onText(finalText, '');
        } else {
          onText(finalText, r.recognizedWords);
        }
      },
      onSoundLevelChange: onLevel,
      listenOptions: SpeechListenOptions(
        localeId: locale,
        partialResults: true,
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        pauseFor: const Duration(seconds: 8),
        listenFor: const Duration(minutes: 10),
      ),
    );
  }

  @override
  Future<void> stop() async {
    _onEnd = null;
    await _speech.stop();
  }
}
