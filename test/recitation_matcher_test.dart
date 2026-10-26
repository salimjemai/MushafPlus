import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_plus/core/recitation_matcher.dart';

void main() {
  const fatiha = [
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
    'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
    'ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
  ];

  test('normalisation makes Uthmani and typed Arabic comparable', () {
    expect(normalizeForMatch('ٱلرَّحْمَٰنِ'), 'الرحمن');
    expect(normalizeForMatch('ٱلْعَٰلَمِينَ'), 'العلمين');
    expect(similarity('العلمين', 'العالمين'), greaterThan(0.8));
    expect(similarity('الصلوه', 'الصلاه'), greaterThan(0.8));
  });

  test('a correct recitation matches every word', () {
    final m = RecitationMatcher(RecitationMatcher.wordsOf(fatiha));
    final r = m.match('بسم الله الرحمن الرحيم الحمد لله رب العالمين الرحمن الرحيم');
    expect(r.words.every((w) => w.status == WordStatus.matched), isTrue, reason: r.words.map((w) => '${w.normalized}:${w.status.name}').join(' '));
    expect(r.complete, isTrue);
    expect(r.accuracy, 1.0);
  });

  test('a partial recitation leaves the rest pending', () {
    final m = RecitationMatcher(RecitationMatcher.wordsOf(fatiha));
    final r = m.match('بسم الله الرحمن');
    expect(r.nextIndex, 3);
    expect(r.words.take(3).every((w) => w.status == WordStatus.matched), isTrue);
    expect(r.words.skip(3).every((w) => w.status == WordStatus.pending), isTrue);
    expect(r.complete, isFalse);
  });

  test('a skipped word is flagged missed and a wrong word flagged wrong', () {
    final m = RecitationMatcher(RecitationMatcher.wordsOf(fatiha));
    // "الله" skipped; "العالمين" replaced by "العالمون" (close), then continues.
    final r = m.match('بسم الرحمن الرحيم الحمد لله رب العالمون الرحمن الرحيم');
    expect(r.words[1].status, WordStatus.missed); // الله
    expect(r.words[7].status, anyOf(WordStatus.wrong, WordStatus.matched)); // العالمين vs العالمون
    expect(r.words.last.status, WordStatus.matched);
    expect(r.accuracy, lessThan(1.0));
  });

  test('extra words are reported without derailing the alignment', () {
    final m = RecitationMatcher(RecitationMatcher.wordsOf(fatiha));
    final r = m.match('بسم الله يعني الرحمن الرحيم');
    expect(r.extras, contains('يعني'));
    expect(r.words.take(4).every((w) => w.status == WordStatus.matched), isTrue);
  });

  test('strict mode rejects a one-letter slip that lenient mode accepts', () {
    final words = RecitationMatcher.wordsOf(fatiha);
    // "العالمين" recited as "العالمون"
    final heard = 'بسم الله الرحمن الرحيم الحمد لله رب العالمون';
    final lenient = RecitationMatcher(words, strict: false).match(heard);
    final strict = RecitationMatcher(words, strict: true).match(heard);
    expect(lenient.words[7].status, WordStatus.matched);
    expect(strict.words[7].status, WordStatus.wrong);
    expect(strict.words[7].heard, 'العالمون');
    for (var i = 0; i < 7; i++) {
      expect(strict.words[i].status, WordStatus.matched, reason: 'word $i');
    }
  });

  test('empty input is all pending', () {
    final m = RecitationMatcher(RecitationMatcher.wordsOf(fatiha));
    final r = m.match('');
    expect(r.nextIndex, 0);
    expect(r.words.every((w) => w.status == WordStatus.pending), isTrue);
  });
}
