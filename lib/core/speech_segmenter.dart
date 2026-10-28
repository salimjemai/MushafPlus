import 'dart:math' as math;
import 'dart:typed_data';

/// What [SpeechSegmenter.add] produced from a chunk of microphone audio: a
/// finished segment to transcribe as final text ([isFinal]), or a snapshot of
/// the segment still growing ([segmentId] tells a stale snapshot from a live
/// one once the segment has been finalised).
class SegmentEvent {
  const SegmentEvent({required this.isFinal, required this.segmentId, required this.audio});
  final bool isFinal;
  final int segmentId;
  final Float32List audio;
}

/// Cuts a stream of 16 kHz mono audio into segments for a non-streaming
/// recogniser, the way the web voice model does it: speech ends at a pause
/// of [silenceSeconds] (or at the quietest point of the last
/// [splitSearchSeconds] once a segment reaches [maxSegmentSeconds]); a short
/// pre-roll of [preRollSeconds] is kept before the first voiced chunk and
/// bursts shorter than [minSpeechSeconds] are dropped as noise. While a
/// segment keeps growing a partial snapshot is produced every [partialGap]
/// seconds ([double.infinity] turns partials off on slow devices).
///
/// Pure Dart (no platform code), so the native engine and its tests share it.
class SpeechSegmenter {
  SpeechSegmenter({
    this.sampleRate = 16000,
    this.silenceSeconds = 0.6,
    this.maxSegmentSeconds = 12.0,
    this.splitSearchSeconds = 4.0,
    this.preRollSeconds = 0.4,
    this.minSpeechSeconds = 0.3,
    this.partialGap = 3.0,
  });

  final int sampleRate;
  final double silenceSeconds;
  final double maxSegmentSeconds;
  final double splitSearchSeconds;
  final double preRollSeconds;
  final double minSpeechSeconds;

  /// Seconds between partial snapshots of the active segment.
  double partialGap;

  final _chunks = <Float32List>[];
  final _chunkRms = <double>[];
  int _segLen = 0;
  bool _segHasSpeech = false;
  int _total = 0; // samples seen
  int _firstVoice = 0; // _total before the first voiced chunk of the segment
  int _lastVoice = 0; // _total at the last voiced chunk
  int _lastSent = 0; // _total when the active segment was last snapshotted
  int _segmentId = 0;
  double _noise = 0.002;

  /// Microphone level of the last chunk for a meter, roughly -2 (silence)
  /// to 10 (loud).
  double level = -2;

  /// Id of the segment currently growing.
  int get segmentId => _segmentId;

  /// Whether the active segment has had speech in it.
  bool get hasSpeech => _segHasSpeech;

  List<SegmentEvent> add(Float32List samples) {
    final out = <SegmentEvent>[];
    var sum = 0.0;
    for (final v in samples) {
      sum += v * v;
    }
    final rms = math.sqrt(sum / math.max(1, samples.length));
    level = (20 * _log10(rms + 1e-6) + 50).clamp(-2, 10).toDouble();

    // Adaptive noise floor: snaps down to quiet chunks, creeps up slowly.
    _noise = rms < _noise ? rms : math.min(_noise * 1.01 + 1e-5, 0.02);
    final voiced = rms > math.max(0.004, _noise * 3);

    _total += samples.length;
    _chunks.add(samples);
    _chunkRms.add(rms);
    _segLen += samples.length;
    if (voiced) {
      if (!_segHasSpeech) _firstVoice = _total - samples.length;
      _segHasSpeech = true;
      _lastVoice = _total;
    }

    if (!_segHasSpeech) {
      // Keep only a short pre-roll of silence before speech starts.
      final keep = (preRollSeconds * sampleRate).round();
      while (_chunks.length > 1 && _segLen - _chunks.first.length >= keep) {
        _segLen -= _chunks.removeAt(0).length;
        _chunkRms.removeAt(0);
      }
      _lastSent = _total;
      return out;
    }

    final sinceVoice = (_total - _lastVoice) / sampleRate;
    if (sinceVoice >= silenceSeconds) {
      _finishSegment(out);
      return out;
    }
    if (_segLen >= maxSegmentSeconds * sampleRate) {
      _splitSegment(out);
      return out;
    }
    if ((_total - _lastSent) / sampleRate >= partialGap) {
      _lastSent = _total;
      out.add(SegmentEvent(isFinal: false, segmentId: _segmentId, audio: _concat(_chunks, 0, _chunks.length)));
    }
    return out;
  }

  /// Forgets the active segment (a new session starts).
  void reset() {
    _resetSegment();
    _total = 0;
    _firstVoice = 0;
    _lastVoice = 0;
    _lastSent = 0;
  }

  /// The pause ended the segment: emit it as final audio.
  void _finishSegment(List<SegmentEvent> out) {
    // Voiced span only: the pre-roll before it is silence.
    final speech = _lastVoice - _firstVoice;
    if (speech >= minSpeechSeconds * sampleRate) {
      // Trim the trailing silence to a short tail.
      final tail = (0.25 * sampleRate).round();
      var end = _chunks.length;
      var trailing = _total - _lastVoice;
      while (end > 1 && trailing - _chunks[end - 1].length >= tail) {
        trailing -= _chunks[end - 1].length;
        end--;
      }
      out.add(SegmentEvent(isFinal: true, segmentId: _segmentId, audio: _concat(_chunks, 0, end)));
    }
    _resetSegment();
  }

  /// No pause for [maxSegmentSeconds]: cut at the quietest chunk of the last
  /// [splitSearchSeconds], preferring a real dip (well below the segment's
  /// average level) so the cut lands between words rather than in the middle
  /// of a long vowel; finalise what came before and keep the rest.
  void _splitSegment(List<SegmentEvent> out) {
    final window = (splitSearchSeconds * sampleRate).round();
    final mean = _chunkRms.fold(0.0, (a, b) => a + b) / _chunkRms.length;
    var cut = _chunks.length - 1;
    var seen = 0;
    var best = double.infinity;
    for (var k = _chunks.length - 1; k > 0 && seen < window; k--) {
      seen += _chunks[k].length;
      // A chunk and its predecessor both quiet: a pause, not a zero crossing.
      final level = math.max(_chunkRms[k], _chunkRms[k - 1]);
      if (level < best) {
        best = level;
        cut = k;
      }
      if (level < mean * 0.25) break; // good enough; stay as late as possible
    }
    out.add(SegmentEvent(isFinal: true, segmentId: _segmentId, audio: _concat(_chunks, 0, cut)));
    final rest = _chunks.sublist(cut);
    final restRms = _chunkRms.sublist(cut);
    _resetSegment();
    _chunks.addAll(rest);
    _chunkRms.addAll(restRms);
    _segLen = rest.fold(0, (a, c) => a + c.length);
    _segHasSpeech = true;
    _firstVoice = _total - _segLen;
  }

  void _resetSegment() {
    _chunks.clear();
    _chunkRms.clear();
    _segLen = 0;
    _segHasSpeech = false;
    _segmentId++;
    _lastSent = _total;
  }

  static Float32List _concat(List<Float32List> chunks, int from, int to) {
    var n = 0;
    for (var i = from; i < to; i++) {
      n += chunks[i].length;
    }
    final out = Float32List(n);
    var o = 0;
    for (var i = from; i < to; i++) {
      out.setAll(o, chunks[i]);
      o += chunks[i].length;
    }
    return out;
  }

  static double _log10(double x) => math.log(x) / math.ln10;
}
