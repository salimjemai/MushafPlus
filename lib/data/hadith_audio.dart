import 'dart:async';

import 'package:flutter/foundation.dart';

import 'audio_backend.dart';
import 'downloads.dart';
import 'tts.dart';

/// Recorded hadith recitation from Hadith.to (api.hadith.to / cdn.hadith.to):
/// human recordings for the seven major collections, numbered like our
/// fawazahmed0 data. The three forty-hadith collections only have synthetic
/// voices there, so they keep the device voice instead.
/// Hadith.to publishes no licence or terms of use. The recordings stay off
/// until written permission is on file; the device voice is used meanwhile.
const hadithRecordingsEnabled = false;

const _recordedBooks = <String>{'bukhari', 'muslim', 'nasai', 'abudawud', 'tirmidhi', 'ibnmajah', 'malik'};

/// Direct CDN url of the recording for [book]/[number], or null when the
/// book has none or the number is fractional. Built locally so playback can
/// start synchronously inside the tap (iOS Safari).
String? hadithAudioUrl(String book, num number) {
  if (!hadithRecordingsEnabled || !_recordedBooks.contains(book)) return null;
  if (number != number.toInt() || number < 1) return null;
  return 'https://cdn.hadith.to/$book/${number.toInt().toString().padLeft(4, '0')}.mp3';
}

bool hasRecordedHadith(String book) => hadithRecordingsEnabled && _recordedBooks.contains(book);

/// One hadith to read: its recording (if any) and what the device voice
/// should say. [arabic] is only spoken when there is no recording.
class HadithReadItem {
  const HadithReadItem({required this.book, required this.number, this.arabic = '', this.ttsParts = const []});
  final String book;
  final num number;
  final String arabic;

  /// (text, BCP-47 voice) pairs, usually the translation.
  final List<(String, String)> ttsParts;

  String? get audioUrl => hadithAudioUrl(book, number);
}

/// Plays hadith one after another: the recording first, then the
/// translation with the device voice; a hadith without a recording is read
/// entirely by the device voice. One reader is shared by every screen so
/// a new tap stops whatever was playing.
class HadithReader {
  HadithReader._();
  static final instance = HadithReader._();

  /// Id of what is being read (card or page), or null.
  static final playing = ValueNotifier<String?>(null);

  AyahPlayer? _player;
  int _gen = 0;
  Completer<bool>? _track;

  AyahPlayer get _p => _player ??= createAyahPlayer()
    ..completed.listen((_) => _endTrack(true))
    ..errors.listen((_) => _endTrack(false));

  void _endTrack(bool ok) {
    final t = _track;
    _track = null;
    if (t != null && !t.isCompleted) t.complete(ok);
  }

  /// Returns false when nothing at all could be played. Call it from the
  /// tap handler without awaiting anything first.
  Future<bool> read(String id, List<HadithReadItem> items) async {
    final gen = ++_gen;
    _endTrack(false);
    playing.value = id;
    var any = false;
    var first = true;
    try {
      for (final it in items) {
        if (gen != _gen) return any;
        var heard = false;
        final url = it.audioUrl;
        if (url != null) {
          var src = url;
          // Native builds play the offline copy when there is one; the web
          // build must call play() synchronously, so it never awaits here.
          if (!first || Downloads.supportsCache) {
            await Tts.stop();
            if (Downloads.supportsCache) {
              src = await Downloads.cachedFile('hadith/${it.book}', _name(url)) ?? url;
            }
            if (gen != _gen) return any;
          } else {
            unawaited(Tts.stop());
          }
          final track = _track = Completer<bool>();
          unawaited(_p.play(src).catchError((_) => _endTrack(false)));
          heard = await track.future;
          if (gen != _gen) return any;
          any |= heard;
          if (heard && src == url && Downloads.supportsCache) {
            unawaited(Downloads.cacheFile('hadith/${it.book}', _name(url), url).catchError((_) => ''));
          }
        } else {
          unawaited(_p.stop());
        }
        final parts = <(String, String)>[if (!heard && it.arabic.isNotEmpty) (it.arabic, 'ar-SA'), ...it.ttsParts];
        if (parts.isNotEmpty) {
          final ttsId = '$id#${it.number}';
          final ok = await Tts.speak(ttsId, parts);
          if (ok) {
            any = true;
            await _ttsDone(ttsId, gen);
          }
        }
        first = false;
      }
      return any;
    } finally {
      if (gen == _gen) playing.value = null;
    }
  }

  Future<void> _ttsDone(String id, int gen) {
    final c = Completer<void>();
    void check() {
      if (Tts.speaking.value != id || gen != _gen) {
        Tts.speaking.removeListener(check);
        if (!c.isCompleted) c.complete();
      }
    }

    Tts.speaking.addListener(check);
    check();
    return c.future;
  }

  Future<void> stop() async {
    _gen++;
    playing.value = null;
    _endTrack(false);
    await _player?.stop();
    await Tts.stop();
  }

  static String _name(String url) => Uri.parse(url).pathSegments.last;
}
