import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio_backend.dart';
import '../data/downloads.dart';
import '../data/reciters.dart';
import 'providers.dart';

@immutable
class AudioState {
  const AudioState({
    this.ayah,
    this.rangeStart,
    this.rangeEnd,
    this.playing = false,
    this.loading = false,
    this.loop = false,
    this.repeatEach = 1,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.error,
  });

  /// Global ayah number currently loaded, or null when idle.
  final int? ayah;
  final int? rangeStart;
  final int? rangeEnd;
  final bool playing;
  final bool loading;

  /// When true, playback restarts from [rangeStart] after [rangeEnd].
  final bool loop;

  /// How many times each ayah is repeated before advancing (memorisation).
  final int repeatEach;
  final Duration position;
  final Duration duration;
  final String? error;

  bool get isActive => ayah != null;
  bool isCurrent(int globalAyah) => ayah == globalAyah;

  AudioState copyWith({
    int? ayah,
    int? rangeStart,
    int? rangeEnd,
    bool? playing,
    bool? loading,
    bool? loop,
    int? repeatEach,
    Duration? position,
    Duration? duration,
    String? error,
    bool clearError = false,
  }) {
    return AudioState(
      ayah: ayah ?? this.ayah,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      playing: playing ?? this.playing,
      loading: loading ?? this.loading,
      loop: loop ?? this.loop,
      repeatEach: repeatEach ?? this.repeatEach,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      error: clearError ? null : (error ?? this.error),
    );
  }

  static const idle = AudioState();
}

/// Drives verse-by-verse recitation: plays one ayah, auto-advances through a
/// range, optionally loops it, and repeats each ayah N times.
class AudioController extends Notifier<AudioState> {
  late final AyahPlayer _player;
  final _subs = <StreamSubscription<dynamic>>[];
  int _token = 0;
  int _repeatsDone = 0;

  @override
  AudioState build() {
    _player = createAyahPlayer();
    _subs.addAll([
      _player.status.listen((s) {
        switch (s) {
          case PlayerStatus.playing:
            state = state.copyWith(playing: true, loading: false, clearError: true);
          case PlayerStatus.paused:
            state = state.copyWith(playing: false);
          case PlayerStatus.stopped:
            state = state.copyWith(playing: false, loading: false);
        }
      }),
      _player.position.listen((p) => state = state.copyWith(position: p)),
      _player.duration.listen((d) => state = state.copyWith(duration: d)),
      _player.completed.listen((_) => _onComplete()),
      _player.errors.listen((e) => state = state.copyWith(loading: false, playing: false, error: e)),
    ]);
    ref.onDispose(() {
      for (final s in _subs) {
        s.cancel();
      }
      _player.dispose();
    });
    return AudioState.idle;
  }

  Reciter get _reciter => reciterById(ref.read(settingsProvider).reciter);

  String _urlFor(int globalAyah) {
    final a = ref.read(repositoryProvider).requireValue.ayah(globalAyah);
    return _reciter.ayahUrl(a.surah, a.numberInSurah);
  }

  /// Plays a single ayah; continues to the end of its surah afterwards.
  /// Everything up to the player's play call runs synchronously so that the
  /// call stays inside the user's tap (required by iOS Safari).
  Future<void> playAyah(int globalAyah, {int? until}) {
    final repo = ref.read(repositoryProvider).requireValue;
    final a = repo.ayah(globalAyah);
    final s = repo.surah(a.surah);
    final end = until ?? (s.startAyah + s.numberOfAyahs - 1);
    state = state.copyWith(rangeStart: globalAyah, rangeEnd: end, loop: false, repeatEach: 1);
    return _load(globalAyah);
  }

  Future<void> playSurah(int surahNumber) {
    final s = ref.read(repositoryProvider).requireValue.surah(surahNumber);
    return playAyah(s.startAyah, until: s.startAyah + s.numberOfAyahs - 1);
  }

  /// Memorisation playback: loop [from]..[to], repeating each ayah [repeatEach] times.
  Future<void> playRange(int from, int to, {int repeatEach = 1, bool loop = true}) {
    state = state.copyWith(rangeStart: from, rangeEnd: to, loop: loop, repeatEach: repeatEach);
    return _load(from);
  }

  Future<void> _load(int globalAyah) async {
    final token = ++_token;
    _repeatsDone = 0;
    state = state.copyWith(
      ayah: globalAyah,
      loading: true,
      playing: false,
      position: Duration.zero,
      duration: Duration.zero,
      clearError: true,
    );
    try {
      var source = _urlFor(globalAyah);
      if (Downloads.supportsCache) {
        final a = ref.read(repositoryProvider).requireValue.ayah(globalAyah);
        final local = await Downloads.cachedAyahPath(_reciter.id, a.surah, a.numberInSurah);
        if (token != _token) return;
        if (local != null) source = local;
      }
      await _player.play(source);
    } catch (e) {
      if (token != _token) return;
      state = state.copyWith(loading: false, playing: false, error: 'Could not play audio ($e)');
    }
  }

  Future<void> _replay() async {
    try {
      await _player.seek(Duration.zero);
      await _player.resume();
    } catch (_) {}
  }

  void _onComplete() {
    final current = state.ayah;
    if (current == null) return;
    _repeatsDone++;
    if (_repeatsDone < state.repeatEach) {
      _replay();
      return;
    }
    final end = state.rangeEnd ?? current;
    if (current < end) {
      _load(current + 1);
    } else if (state.loop && state.rangeStart != null) {
      _load(state.rangeStart!);
    } else {
      state = state.copyWith(playing: false, loading: false, position: Duration.zero);
    }
  }

  Future<void> toggle() {
    if (state.ayah == null) return Future.value();
    if (state.playing) return _player.pause();
    if (state.position > Duration.zero) return _player.resume();
    return _load(state.ayah!);
  }

  Future<void> pause() => _player.pause();

  Future<void> next() {
    final a = state.ayah;
    if (a == null) return Future.value();
    final end = state.rangeEnd ?? a;
    return a < end ? _load(a + 1) : Future.value();
  }

  Future<void> previous() {
    final a = state.ayah;
    if (a == null) return Future.value();
    final start = state.rangeStart ?? a;
    return a > start ? _load(a - 1) : _player.seek(Duration.zero);
  }

  Future<void> seek(Duration d) => _player.seek(d);

  Future<void> stop() async {
    _token++;
    await _player.stop();
    state = AudioState.idle;
  }

  /// Reload the current ayah with the newly selected reciter.
  Future<void> reciterChanged() async {
    if (state.ayah != null && (state.playing || state.loading)) {
      await _load(state.ayah!);
    }
  }
}

final audioProvider = NotifierProvider<AudioController, AudioState>(AudioController.new);
