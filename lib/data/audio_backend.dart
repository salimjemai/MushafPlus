import 'audio_backend_stub.dart'
    if (dart.library.js_interop) 'audio_backend_web.dart'
    if (dart.library.io) 'audio_backend_native.dart' as impl;

enum PlayerStatus { playing, paused, stopped }

/// Minimal player used for verse-by-verse recitation. The web build drives an
/// HTML audio element directly so that playback starts synchronously inside
/// the user's tap, which iOS Safari requires; other platforms use audioplayers.
abstract class AyahPlayer {
  Stream<PlayerStatus> get status;
  Stream<Duration> get position;
  Stream<Duration> get duration;
  Stream<void> get completed;
  Stream<String> get errors;

  /// Loads [url] and starts playing. Must not await anything before the
  /// underlying play call.
  Future<void> play(String url);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration position);
  void dispose();
}

AyahPlayer createAyahPlayer() => impl.createAyahPlayer();
