import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  late final AudioPlayer _player;
  final _subs = <StreamSubscription<dynamic>>[];
  int _token = 0;
  int _repeatsDone = 0;

  @override
  AudioState build() {
    _player = AudioPlayer(playerId: 'quran_plus');
    _player.setReleaseMode(ReleaseMode.stop);
    _subs.addAll([
      _player.onPlayerStateChanged.listen((s) {
        if (s == PlayerState.playing) {
          state = state.copyWith(playing: true, loading: false, clearError: true);
        } else if (s == PlayerState.paused) {
          state = state.copyWith(playing: false);
        } else if (s == PlayerState.stopped) {
          state = state.copyWith(playing: false, loading: false);
        }
      }),
      _player.onPositionChanged.listen((p) => state = state.copyWith(position: p)),
      _player.onDurationChanged.listen((d) => state = state.copyWith(duration: d)),
      _player.onPlayerComplete.listen((_) => _onComplete()),
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
  Future<void> playAyah(int globalAyah, {int? until}) async {
    final repo = ref.read(repositoryProvider).requireValue;
    final a = repo.ayah(globalAyah);
    final s = repo.surah(a.surah);
    final end = until ?? (s.startAyah + s.numberOfAyahs - 1);
    state = state.copyWith(rangeStart: globalAyah, rangeEnd: end, loop: false, repeatEach: 1);
    await _load(globalAyah);
  }

  Future<void> playSurah(int surahNumber) async {
    final s = ref.read(repositoryProvider).requireValue.surah(surahNumber);
    await playAyah(s.startAyah, until: s.startAyah + s.numberOfAyahs - 1);
  }

  /// Memorisation playback: loop [from]..[to], repeating each ayah [repeatEach] times.
  Future<void> playRange(int from, int to, {int repeatEach = 1, bool loop = true}) async {
    state = state.copyWith(rangeStart: from, rangeEnd: to, loop: loop, repeatEach: repeatEach);
    await _load(from);
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
      await _player.stop();
      if (token != _token) return;
      await _player.play(UrlSource(_urlFor(globalAyah)));
    } catch (e) {
      if (token != _token) return;
      state = state.copyWith(loading: false, playing: false, error: 'Could not play audio ($e)');
    }
  }

  Future<void> _replay() async {
    final token = ++_token;
    try {
      await _player.stop();
      if (token != _token) return;
      await _player.play(UrlSource(_urlFor(state.ayah!)));
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

  Future<void> toggle() async {
    if (state.ayah == null) return;
    if (state.playing) {
      await _player.pause();
    } else if (state.position > Duration.zero) {
      await _player.resume();
    } else {
      await _load(state.ayah!);
    }
  }

  Future<void> pause() => _player.pause();

  Future<void> next() async {
    final a = state.ayah;
    if (a == null) return;
    final end = state.rangeEnd ?? a;
    if (a < end) await _load(a + 1);
  }

  Future<void> previous() async {
    final a = state.ayah;
    if (a == null) return;
    final start = state.rangeStart ?? a;
    if (a > start) {
      await _load(a - 1);
    } else {
      await _player.seek(Duration.zero);
    }
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
