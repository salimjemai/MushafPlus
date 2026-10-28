import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_plus/core/speech_segmenter.dart';

const sr = 16000;
const chunk = 2048; // 128 ms, as the engines deliver it

Float32List silence() => Float32List(chunk);

Float32List tone({double amplitude = 0.3, int seed = 1}) {
  final out = Float32List(chunk);
  final rnd = math.Random(seed);
  for (var i = 0; i < chunk; i++) {
    out[i] = amplitude * (rnd.nextDouble() * 2 - 1);
  }
  return out;
}

List<SegmentEvent> feed(SpeechSegmenter s, {required double seconds, required Float32List Function() make}) {
  final events = <SegmentEvent>[];
  final chunks = (seconds * sr / chunk).round();
  for (var i = 0; i < chunks; i++) {
    events.addAll(s.add(make()));
  }
  return events;
}

void main() {
  test('silence alone never produces a segment', () {
    final s = SpeechSegmenter();
    final events = feed(s, seconds: 20, make: silence);
    expect(events, isEmpty);
    expect(s.hasSpeech, isFalse);
    expect(s.level, lessThan(0));
  });

  test('speech followed by a pause becomes one final segment with pre-roll and a short tail', () {
    final s = SpeechSegmenter(partialGap: double.infinity);
    feed(s, seconds: 2, make: silence); // long silence before: only the pre-roll must survive
    final during = feed(s, seconds: 2, make: tone);
    expect(during, isEmpty);
    final after = feed(s, seconds: 1, make: silence);
    expect(after.length, 1);
    final e = after.single;
    expect(e.isFinal, isTrue);
    final seconds = e.audio.length / sr;
    // 0.4 s pre-roll + 2 s speech + about 0.25 s tail (chunk granularity).
    expect(seconds, greaterThan(2.3));
    expect(seconds, lessThan(3.1));
    expect(s.segmentId, 1);
    expect(s.hasSpeech, isFalse);
  });

  test('a burst shorter than the minimum is dropped as noise', () {
    final s = SpeechSegmenter(partialGap: double.infinity);
    feed(s, seconds: 1, make: silence);
    s.add(tone()); // 128 ms
    final after = feed(s, seconds: 1, make: silence);
    expect(after, isEmpty);
  });

  test('partial snapshots arrive while speech continues, then a final covers them', () {
    final s = SpeechSegmenter(partialGap: 1.0);
    final during = feed(s, seconds: 3.5, make: tone);
    final partials = during.where((e) => !e.isFinal).toList();
    expect(partials.length, greaterThanOrEqualTo(2));
    expect(partials.every((e) => e.segmentId == s.segmentId), isTrue);
    // Each snapshot is the whole segment so far: growing.
    for (var i = 1; i < partials.length; i++) {
      expect(partials[i].audio.length, greaterThan(partials[i - 1].audio.length));
    }
    final after = feed(s, seconds: 1, make: silence);
    expect(after.single.isFinal, isTrue);
    expect(after.single.segmentId, partials.first.segmentId);
    expect(s.segmentId, partials.first.segmentId + 1);
  });

  test('speech without a pause is cut at the quietest point once it reaches the maximum', () {
    final s = SpeechSegmenter(partialGap: double.infinity);
    final events = <SegmentEvent>[];
    // 10 s loud, a quiet-ish dip of one chunk, then loud again past 12 s.
    for (var i = 0; i < (10 * sr / chunk).round(); i++) {
      events.addAll(s.add(tone(seed: i)));
    }
    events.addAll(s.add(tone(amplitude: 0.01)));
    events.addAll(s.add(tone(amplitude: 0.01)));
    for (var i = 0; i < (3 * sr / chunk).round(); i++) {
      events.addAll(s.add(tone(seed: 100 + i)));
    }
    final finals = events.where((e) => e.isFinal).toList();
    expect(finals.length, 1);
    final seconds = finals.single.audio.length / sr;
    // The cut landed at the dip, near 10 s, not at the 12 s limit.
    expect(seconds, greaterThan(9.5));
    expect(seconds, lessThan(10.5));
    expect(s.hasSpeech, isTrue); // the rest carries on as the new segment
  });

  test('reset forgets the active segment', () {
    final s = SpeechSegmenter(partialGap: double.infinity);
    feed(s, seconds: 1, make: tone);
    s.reset();
    expect(s.hasSpeech, isFalse);
    expect(feed(s, seconds: 1, make: silence), isEmpty);
  });
}
