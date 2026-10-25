import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'audio_backend.dart';

AyahPlayer createAyahPlayer() => _NativeAyahPlayer();

class _NativeAyahPlayer implements AyahPlayer {
  _NativeAyahPlayer() {
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setPlayerMode(PlayerMode.mediaPlayer);
    // Media channel: iPhones play with the silent switch on, Android takes
    // audio focus like a music app.
    AudioPlayer.global.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.defaultToSpeaker},
      ),
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,
        contentType: AndroidContentType.speech,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    ));
    _subs.addAll([
      _player.onPlayerStateChanged.listen((s) {
        switch (s) {
          case PlayerState.playing:
            _status.add(PlayerStatus.playing);
          case PlayerState.paused:
            _status.add(PlayerStatus.paused);
          case PlayerState.stopped:
          case PlayerState.completed:
          case PlayerState.disposed:
            _status.add(PlayerStatus.stopped);
        }
      }),
      _player.onPositionChanged.listen(_position.add),
      _player.onDurationChanged.listen(_duration.add),
      _player.onPlayerComplete.listen((_) => _completed.add(null)),
    ]);
  }

  final _player = AudioPlayer(playerId: 'quran_plus');
  final _subs = <StreamSubscription<dynamic>>[];
  final _status = StreamController<PlayerStatus>.broadcast();
  final _position = StreamController<Duration>.broadcast();
  final _duration = StreamController<Duration>.broadcast();
  final _completed = StreamController<void>.broadcast();
  final _errors = StreamController<String>.broadcast();

  @override
  Stream<PlayerStatus> get status => _status.stream;
  @override
  Stream<Duration> get position => _position.stream;
  @override
  Stream<Duration> get duration => _duration.stream;
  @override
  Stream<void> get completed => _completed.stream;
  @override
  Stream<String> get errors => _errors.stream;

  @override
  Future<void> play(String url) => _player.play(UrlSource(url), mode: PlayerMode.mediaPlayer);
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> resume() => _player.resume();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    _status.close();
    _position.close();
    _duration.close();
    _completed.close();
    _errors.close();
  }
}
