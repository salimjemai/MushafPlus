import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'audio_backend.dart';

AyahPlayer createAyahPlayer() => _WebAyahPlayer();

/// One HTML audio element for the whole app. iOS Safari "unlocks" an element
/// the first time play() runs inside a user gesture; later plays on the same
/// element (auto-advance to the next ayah) are then allowed.
class _WebAyahPlayer implements AyahPlayer {
  _WebAyahPlayer() {
    _el.preload = 'auto';
    _el.setAttribute('playsinline', '');
    _el.setAttribute('webkit-playsinline', '');
    _listen('playing', (_) => _status.add(PlayerStatus.playing));
    _listen('pause', (_) {
      if (!_el.ended && !_stopping) _status.add(PlayerStatus.paused);
    });
    _listen('ended', (_) => _completed.add(null));
    _listen('timeupdate', (_) {
      final t = _el.currentTime;
      if (t.isFinite) _position.add(Duration(milliseconds: (t * 1000).round()));
    });
    _listen('durationchange', (_) {
      final d = _el.duration;
      if (d.isFinite && d > 0) _duration.add(Duration(milliseconds: (d * 1000).round()));
    });
    _listen('error', (_) {
      final code = _el.error?.code;
      _errors.add('audio element error${code == null ? '' : ' $code'}');
      _status.add(PlayerStatus.stopped);
    });
  }

  final web.HTMLAudioElement _el = web.HTMLAudioElement();
  final _status = StreamController<PlayerStatus>.broadcast();
  final _position = StreamController<Duration>.broadcast();
  final _duration = StreamController<Duration>.broadcast();
  final _completed = StreamController<void>.broadcast();
  final _errors = StreamController<String>.broadcast();
  final _handlers = <(String, JSFunction)>[];
  bool _stopping = false;

  void _listen(String type, void Function(web.Event) handler) {
    final js = handler.toJS;
    _el.addEventListener(type, js);
    _handlers.add((type, js));
  }

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
  Future<void> play(String url) async {
    _stopping = false;
    // Set the source and call play() synchronously: this is the call that
    // must happen inside the user's tap on iOS Safari.
    _el.src = url;
    final promise = _el.play();
    try {
      await promise.toDart;
    } catch (e) {
      throw Exception('playback blocked or failed: $e');
    }
  }

  @override
  Future<void> pause() async => _el.pause();

  @override
  Future<void> resume() async {
    try {
      await _el.play().toDart;
    } catch (e) {
      _errors.add('resume failed: $e');
    }
  }

  @override
  Future<void> stop() async {
    _stopping = true;
    _el.pause();
    try {
      _el.currentTime = 0;
    } catch (_) {}
    _status.add(PlayerStatus.stopped);
  }

  @override
  Future<void> seek(Duration position) async {
    _el.currentTime = position.inMilliseconds / 1000;
  }

  @override
  Future<void> setRate(double rate) async {
    _el.defaultPlaybackRate = rate;
    _el.playbackRate = rate;
  }

  @override
  void dispose() {
    for (final (type, js) in _handlers) {
      _el.removeEventListener(type, js);
    }
    _el.pause();
    _el.removeAttribute('src');
    _status.close();
    _position.close();
    _duration.close();
    _completed.close();
    _errors.close();
  }
}
