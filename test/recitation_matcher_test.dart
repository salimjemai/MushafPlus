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
    expect(r.words.every((w) => w.status == WordStatus.matched), isTrue,
        reason: r.words.map((w) => '${w.normalized}:${w.status.name}').join(' '));
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

  // ---- harakat grading (ported from tool/asr_prototype/harakat.test.mjs) ----

  group('harakat', () {
    test('vocalised normalisation keeps the skeleton the alignment uses', () {
      for (final ayah in fatihaFull) {
        for (final w in ayah.split(' ')) {
          final voc = Harakat.normalizeVocalised(w);
          expect(Harakat.skeleton(voc), normalizeForMatch(w), reason: w);
        }
      }
      expect(Harakat.normalizeVocalised('ٱلرَّحْمَٰنِ'), 'الرَّحْمَٰنِ');
      expect(Harakat.isVocalised(Harakat.normalizeVocalised('الحمد لله')), isFalse);
      expect(Harakat.isVocalised(Harakat.normalizeVocalised('الْحَمْدُ')), isTrue);
    });

    test('Uthmani and simple vocalised spellings of the same word compare clean', () {
      expect(Harakat.compareWord('ٱلْعَٰلَمِينَ', 'الْعَالَمِينَ').status, WordComparison.ok);
      expect(Harakat.compareWord('ٱلرَّحْمَٰنِ', 'الرَّحْمَٰنِ').status, WordComparison.ok);
      expect(Harakat.compareWord('ٱلرَّحْمَٰنِ', 'الرَّحْمَنِ').status, WordComparison.ok);
      expect(Harakat.compareWord('ٱلضَّآلِّينَ', 'الضَّالِّينَ').status, WordComparison.ok);
      expect(Harakat.compareWord('إِيَّاكَ', 'إِيَّاكَ').status, WordComparison.ok);
    });

    test('a vowel slip on the same skeleton names the letter and marks', () {
      var r = Harakat.compareWord('ٱلْحَمْدُ', 'الْحَمْدَ');
      expect(r.status, WordComparison.vowel);
      expect(r.vowelErrors.map((v) => [v.letter, v.expectedName, v.heardName]), [
        ['د', 'damma', 'fatha'],
      ]);
      expect(r.vowelErrors.single.expectedMark, Harakat.damma);
      expect(r.vowelErrors.single.heardMark, Harakat.fatha);
      r = Harakat.compareWord('رَبِّ', 'رَبُّ');
      expect(r.status, WordComparison.vowel);
      expect(r.vowelErrors.first.heardName, 'damma');
    });

    test('a missing shadda is a vowel-class error; a letter change is a letter error', () {
      final r = Harakat.compareWord('رَبِّ', 'رَبِ');
      expect(r.status, WordComparison.vowel);
      expect(r.vowelErrors.single.kind, VowelErrorKind.shadda);
      expect(r.vowelErrors.single.expectedName, 'shadda');
      expect(r.vowelErrors.single.heardName, 'no shadda');
      expect(Harakat.compareWord('نَعْبُدُ', 'نَعْبُتُ').status, WordComparison.letter);
    });

    test('unvocalised output gives no verdict rather than a false error', () {
      expect(Harakat.compareWord('ٱلْحَمْدُ', 'الحمد').status, WordComparison.unvocalised);
    });

    test('waqf: a stopped-on final word may drop its last vowel', () {
      expect(Harakat.compareWord('ٱلرَّحِيمِ', 'الرَّحِيمْ', finalWord: true).status, WordComparison.ok);
      expect(Harakat.compareWord('ٱلرَّحِيمِ', 'الرَّحِيم', finalWord: true).status, WordComparison.ok);
      expect(Harakat.compareWord('ٱلرَّحِيمِ', 'الرَّحِيمُ', finalWord: true).status, WordComparison.vowel);
      // Tanween fath stopped on becomes alif of madd.
      expect(Harakat.compareWord('غَفُورًا', 'غَفُورَا', finalWord: true).status, WordComparison.ok);
      expect(Harakat.compareWord('غَفُورًا', 'غَفُورَا').status, WordComparison.vowel);
    });

    test('every synthetic passage flags exactly its mutated word', () {
      for (final t in testSet.entries) {
        final ayah = fatihaFull[t.value.ayah - 1];
        final m = RecitationMatcher(RecitationMatcher.wordsOf([ayah]), stops: RecitationMatcher.stopsOf([ayah]));
        final r = m.match(t.value.spoken);
        final dump = r.words.map((w) => '${w.original}:${w.status.name}${w.vowelErrors}').join(' ');
        final flagged = [
          for (var i = 0; i < r.words.length; i++)
            if (r.words[i].status == WordStatus.vowel) i
        ];
        expect(r.words.where((w) => w.status == WordStatus.wrong || w.status == WordStatus.missed), isEmpty, reason: '${t.key}: $dump');
        expect(r.complete, isTrue, reason: '${t.key}: $dump');
        final mutated = t.value.mutated;
        if (mutated == null) {
          expect(flagged, isEmpty, reason: '${t.key}: $dump');
        } else if (t.key == 'bad_5b') {
          expect(flagged, [0, 2], reason: '${t.key}: $dump');
        } else {
          expect(flagged, [mutated], reason: '${t.key}: $dump');
          expect(r.words[mutated].heard, isNotNull);
          expect(r.vowel, 1);
          expect(r.accuracy, lessThan(1.0));
        }
      }
    });

    test('vowel slips keep the cursor moving and are reported separately from letter errors', () {
      final words = RecitationMatcher.wordsOf(fatiha);
      final m = RecitationMatcher(words, stops: RecitationMatcher.stopsOf(fatiha));
      // الحمدَ (vowel slip) and نعبت-style letter error on رب (ربت).
      final r = m.match('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ الْحَمْدَ لِلَّهِ رَبْتِ الْعَالَمِينَ');
      expect(r.words[4].status, WordStatus.vowel);
      expect(r.words[4].vowelErrors.single.letter, 'د');
      expect(r.words[6].status, WordStatus.wrong);
      expect(r.nextIndex, 8);
      expect(r.vowel, 1);
      expect(r.wrong, 1);
      expect(r.matched, 6);
    });

    test('a vocalised correct recitation is all matched, with waqf at ayah ends', () {
      final m = RecitationMatcher(RecitationMatcher.wordsOf(fatihaFull), stops: RecitationMatcher.stopsOf(fatihaFull));
      final r = m.match(testSet.values.where((t) => t.mutated == null).map((t) => t.spoken).join(' '));
      expect(r.words.every((w) => w.status == WordStatus.matched), isTrue,
          reason:
              r.words.where((w) => w.status != WordStatus.matched).map((w) => '${w.original}:${w.status.name}${w.vowelErrors}').join(' '));
      expect(r.complete, isTrue);
    });

    test('stops are the ayah ends and words before pause signs', () {
      expect(RecitationMatcher.stopsOf(fatiha), {3, 7, 9});
      expect(RecitationMatcher.stopsOf(['قَالَ ۖ قَالُوا', 'نَعَمْ']), {0, 1, 2});
    });

    test('mixed input where only some words carry marks still grades the marked ones', () {
      final m = RecitationMatcher(RecitationMatcher.wordsOf(fatiha));
      final r = m.match('بسم الله الرحمن الرحيم الْحَمْدَ لله');
      expect(r.words[4].status, WordStatus.vowel);
      expect(r.words[5].status, WordStatus.matched);
    });
  });
}

/// Al-Fatiha in the app's Uthmani text.
const fatihaFull = [
  'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
  'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
  'ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
  'مَٰلِكِ يَوْمِ ٱلدِّينِ',
  'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
  'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
  'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ',
];

/// The prototype's synthetic test set: each ayah read correctly and with one
/// deliberate vowel mistake (0-based word index, or null when correct).
const testSet = <String, ({int ayah, String spoken, int? mutated})>{
  'ok_1': (ayah: 1, spoken: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', mutated: null),
  'ok_2': (ayah: 2, spoken: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', mutated: null),
  'ok_3': (ayah: 3, spoken: 'الرَّحْمَٰنِ الرَّحِيمِ', mutated: null),
  'ok_4': (ayah: 4, spoken: 'مَالِكِ يَوْمِ الدِّينِ', mutated: null),
  'ok_5': (ayah: 5, spoken: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', mutated: null),
  'ok_6': (ayah: 6, spoken: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', mutated: null),
  'ok_7': (ayah: 7, spoken: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', mutated: null),
  'bad_2a': (ayah: 2, spoken: 'الْحَمْدَ لِلَّهِ رَبِّ الْعَالَمِينَ', mutated: 0),
  'bad_2b': (ayah: 2, spoken: 'الْحَمْدُ لِلَّهِ رَبُّ الْعَالَمِينَ', mutated: 2),
  'bad_4a': (ayah: 4, spoken: 'مَالِكُ يَوْمِ الدِّينِ', mutated: 0),
  'bad_4b': (ayah: 4, spoken: 'مَالِكِ يَوْمَ الدِّينِ', mutated: 1),
  'bad_5a': (ayah: 5, spoken: 'إِيَّاكَ نَعْبُدَ وَإِيَّاكَ نَسْتَعِينُ', mutated: 1),
  'bad_5b': (ayah: 5, spoken: 'إِيَّاكِ نَعْبُدُ وَإِيَّاكِ نَسْتَعِينُ', mutated: 0),
  'bad_6a': (ayah: 6, spoken: 'اهْدِنَا الصِّرَاطُ الْمُسْتَقِيمَ', mutated: 1),
  'bad_7a': (ayah: 7, spoken: 'صِرَاطَ الَّذِينَ أَنْعَمْتُ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', mutated: 2),
  'bad_7b': (ayah: 7, spoken: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرَ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', mutated: 4),
};
