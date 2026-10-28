import 'dart:math' as math;

import 'arabic_utils.dart';

/// How each expected word of the passage fared against what was heard.
///
/// [vowel] is only ever produced when the recogniser returns vocalised text
/// (harakat): the letters were right but a vowel mark or shadda differed.
enum WordStatus { pending, matched, wrong, missed, vowel }

/// Whether a [VowelError] is about the vowel mark of a letter or its shadda.
enum VowelErrorKind { vowel, shadda }

/// One vowel (haraka) difference on a letter whose skeleton matched.
class VowelError {
  const VowelError({
    required this.letterIndex,
    required this.letter,
    required this.expectedMark,
    required this.heardMark,
    this.kind = VowelErrorKind.vowel,
  });

  /// Index of the letter within the normalised expected word.
  final int letterIndex;
  final String letter;

  /// The mark characters (one of [Harakat.marks]) or null for "no mark".
  final String? expectedMark;
  final String? heardMark;
  final VowelErrorKind kind;

  /// Stable identifiers ("fatha", "damma", "sukun", "shadda", "no shadda",
  /// "none") that the UI translates.
  String get expectedName => Harakat.markName(expectedMark, kind);
  String get heardName => Harakat.markName(heardMark, kind);

  @override
  String toString() => '$letter: expected $expectedName, heard $heardName';
}

class WordMatch {
  const WordMatch({
    required this.original,
    required this.normalized,
    required this.status,
    this.heard,
    this.vowelErrors = const [],
  });
  final String original; // Uthmani text as printed
  final String normalized;
  final WordStatus status;

  /// What the recogniser produced for a wrong word, or the vocalised word it
  /// heard for a vowel slip.
  final String? heard;

  /// The vowel differences behind a [WordStatus.vowel] word.
  final List<VowelError> vowelErrors;

  WordMatch copyWith({WordStatus? status, String? heard, List<VowelError>? vowelErrors}) => WordMatch(
        original: original,
        normalized: normalized,
        status: status ?? this.status,
        heard: heard ?? this.heard,
        vowelErrors: vowelErrors ?? this.vowelErrors,
      );
}

class MatchResult {
  const MatchResult({required this.words, required this.nextIndex, required this.extras});

  final List<WordMatch> words;

  /// Index of the first expected word not yet reached (the cursor).
  final int nextIndex;

  /// Heard words that matched nothing (insertions).
  final List<String> extras;

  int get matched => words.where((w) => w.status == WordStatus.matched).length;
  int get wrong => words.where((w) => w.status == WordStatus.wrong).length;
  int get missed => words.where((w) => w.status == WordStatus.missed).length;

  /// Words whose letters were right but a vowel mark was not.
  int get vowel => words.where((w) => w.status == WordStatus.vowel).length;
  int get reached => nextIndex;
  bool get complete => nextIndex >= words.length;

  /// Accuracy over the words reached so far (0..1). Vowel slips count as not
  /// matched.
  double get accuracy => reached == 0 ? 0 : matched / reached;
}

/// Normalises Arabic for comparing recognised speech with the Uthmani text:
/// strips tashkeel and Quranic marks, unifies hamza/alef/yeh/teh-marbuta
/// forms and drops tatweel and punctuation.
String normalizeForMatch(String s) {
  var out = normalizeArabic(s);
  out = out
      .replaceAll('ؤ', 'و') // ؤ -> و
      .replaceAll('ئ', 'ي') // ئ -> ي
      .replaceAll('ء', '') // standalone hamza
      .replaceAll(RegExp('[^ء-ي ]'), ' ') // keep Arabic letters only
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return out;
}

List<String> tokenize(String s) => normalizeForMatch(s).split(' ').where((w) => w.isNotEmpty).toList();

/// Normalised Levenshtein similarity in 0..1.
double similarity(String a, String b) {
  if (a == b) return 1;
  if (a.isEmpty || b.isEmpty) return 0;
  final n = a.length, m = b.length;
  var prev = List<int>.generate(m + 1, (j) => j);
  var cur = List<int>.filled(m + 1, 0);
  for (var i = 1; i <= n; i++) {
    cur[0] = i;
    for (var j = 1; j <= m; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      cur[j] = math.min(math.min(cur[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
    }
    final t = prev;
    prev = cur;
    cur = t;
  }
  return 1 - prev[m] / math.max(n, m);
}

// ---------------------------------------------------------------------------
// Harakat-aware comparison (ported from tool/asr_prototype/harakat.js).
//
// A "unit" is one base letter plus the combining marks that follow it. Words
// are aligned unit by unit on their base letters; for each aligned pair with
// the same base letter the vowel marks are compared. That separates letter
// (skeleton) errors, vowel (haraka) errors and "unvocalised" (the recogniser
// gave no marks, so no vowel verdict is possible).
// ---------------------------------------------------------------------------

/// One base letter with the marks written on it.
class HarakatUnit {
  HarakatUnit(this.base)
      : marks = <String>{},
        _raw = StringBuffer(base);
  final String base;
  final Set<String> marks;
  final StringBuffer _raw;
  String get raw => _raw.toString();
}

/// Outcome of [Harakat.compareWord].
enum WordComparison { ok, vowel, letter, unvocalised }

class WordComparisonResult {
  const WordComparisonResult({required this.status, required this.letterErrors, required this.vowelErrors});
  final WordComparison status;
  final int letterErrors;
  final List<VowelError> vowelErrors;
}

abstract final class Harakat {
  static const fathatan = 'ً';
  static const dammatan = 'ٌ';
  static const kasratan = 'ٍ';
  static const fatha = 'َ';
  static const damma = 'ُ';
  static const kasra = 'ِ';
  static const shadda = 'ّ';
  static const sukun = 'ْ';
  static const daggerAlef = 'ٰ';

  static const marks = [fathatan, dammatan, kasratan, fatha, damma, kasra, shadda, sukun, daggerAlef];
  static const vowels = {fathatan, dammatan, kasratan, fatha, damma, kasra, sukun};

  /// Uthmani annotation (pause signs, small letters, silent-letter zeros,
  /// iqlab meem, madda, subscript alef, high hamza) is dropped: recognisers
  /// never emit it and it carries no vowel information graded yet.
  static final _drop = RegExp(r'[ؐ-ؚٓ-ٟۖ-ۭـٴ]');
  static final _keep = RegExp(r'[^ء-يً-ْٰ ]');

  /// Like [normalizeForMatch] but keeps the vowel marks, shadda and dagger
  /// alef, so that `skeleton(normalizeVocalised(w)) == normalizeForMatch(w)`.
  static String normalizeVocalised(String s) {
    return s
        .replaceAll('ۡ', sukun) // Uthmani small high dotless head of khah = sukun
        .replaceAll(_drop, '')
        .replaceAll(RegExp('[ٱآأإ]'), 'ا') // alef wasla and hamza seats -> alef, as the app does
        .replaceAll('ى', 'ي')
        .replaceAll('ی', 'ي') // Persian yeh
        .replaceAll('ة', 'ه')
        .replaceAll('ک', 'ك') // Persian kaf
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ء', '') // standalone hamza
        .replaceAll(_keep, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool isMark(String c) {
    final u = c.codeUnitAt(0);
    return (u >= 0x064B && u <= 0x0652) || u == 0x0670;
  }

  /// Splits a normalised word into units. Leading marks attach to an empty base.
  static List<HarakatUnit> units(String word) {
    final out = <HarakatUnit>[];
    for (final r in word.runes) {
      final c = String.fromCharCode(r);
      if (isMark(c)) {
        if (out.isEmpty) out.add(HarakatUnit(''));
        out.last.marks.add(c);
        out.last._raw.write(c);
      } else {
        out.add(HarakatUnit(c));
      }
    }
    return out;
  }

  static String skeleton(String word) => units(word).map((u) => u.base).join();

  /// Vowel mark of a unit (one of [vowels]) or null. Tanween is its own vowel.
  static String? vowelOf(HarakatUnit u) {
    for (final m in u.marks) {
      if (vowels.contains(m)) return m;
    }
    return null;
  }

  static bool hasShadda(HarakatUnit u) => u.marks.contains(shadda);

  static bool isVocalised(String word) => units(word).any((u) => u.marks.isNotEmpty);

  static const _names = {
    fathatan: 'fathatan',
    dammatan: 'dammatan',
    kasratan: 'kasratan',
    fatha: 'fatha',
    damma: 'damma',
    kasra: 'kasra',
    sukun: 'sukun',
    shadda: 'shadda',
  };

  static String markName(String? m, [VowelErrorKind kind = VowelErrorKind.vowel]) {
    if (m == null) return kind == VowelErrorKind.shadda ? 'no shadda' : 'none';
    return _names[m] ?? m;
  }

  /// Levenshtein alignment of two unit lists on their base letters. Alef
  /// insert/delete is cheap (Uthmani ٱلْعَٰلَمِينَ vs العالمين). Each pair is
  /// (expected index or null, heard index or null).
  static List<(int?, int?)> alignUnits(List<HarakatUnit> a, List<HarakatUnit> b) {
    final n = a.length, m = b.length;
    double gap(HarakatUnit u) => u.base == 'ا' ? 0.3 : 1;
    final d = List.generate(n + 1, (_) => List<double>.filled(m + 1, 0));
    final p = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0)); // 0 diag, 1 up (del a), 2 left (ins b)
    for (var i = 1; i <= n; i++) {
      d[i][0] = d[i - 1][0] + gap(a[i - 1]);
      p[i][0] = 1;
    }
    for (var j = 1; j <= m; j++) {
      d[0][j] = d[0][j - 1] + gap(b[j - 1]);
      p[0][j] = 2;
    }
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= m; j++) {
        final sub = d[i - 1][j - 1] + (a[i - 1].base == b[j - 1].base ? 0 : 1);
        final del = d[i - 1][j] + gap(a[i - 1]);
        final ins = d[i][j - 1] + gap(b[j - 1]);
        if (sub <= del && sub <= ins) {
          d[i][j] = sub;
          p[i][j] = 0;
        } else if (del <= ins) {
          d[i][j] = del;
          p[i][j] = 1;
        } else {
          d[i][j] = ins;
          p[i][j] = 2;
        }
      }
    }
    final pairs = <(int?, int?)>[];
    var i = n, j = m;
    while (i > 0 || j > 0) {
      final mv = i == 0 ? 2 : (j == 0 ? 1 : p[i][j]);
      if (mv == 0) {
        pairs.add((i - 1, j - 1));
        i--;
        j--;
      } else if (mv == 1) {
        pairs.add((i - 1, null));
        i--;
      } else {
        pairs.add((null, j - 1));
        j--;
      }
    }
    return pairs.reversed.toList();
  }

  /// Compares one expected (Uthmani) word with one heard (vocalised) word.
  /// With [finalWord] (waqf) a dropped or sukun final vowel is not an error,
  /// nor is fathatan heard as fatha.
  static WordComparisonResult compareWord(String expectedRaw, String heardRaw, {bool finalWord = false}) {
    final exp = units(normalizeVocalised(expectedRaw));
    final hrd = units(normalizeVocalised(heardRaw));
    final heardVocalised = hrd.any((u) => u.marks.isNotEmpty);
    final pairs = alignUnits(exp, hrd);
    var letterErrors = 0;
    final vowelErrors = <VowelError>[];
    var lastExpIndex = exp.length - 1;
    // Expected trailing alef after fathatan (e.g. غَفُورًا) has no vowel; the unit before it is final.
    while (lastExpIndex > 0 && exp[lastExpIndex].base == 'ا' && exp[lastExpIndex].marks.isEmpty) {
      lastExpIndex--;
    }
    for (final (i, j) in pairs) {
      if (i == null) {
        if (hrd[j!].base != 'ا') letterErrors++;
        continue;
      }
      if (j == null) {
        if (exp[i].base != 'ا') letterErrors++;
        continue;
      }
      final e = exp[i], h = hrd[j];
      if (e.base != h.base) {
        letterErrors++;
        continue;
      }
      if (!heardVocalised) continue;
      final ev = vowelOf(e), hv = vowelOf(h);
      final es = hasShadda(e), hs = hasShadda(h);
      // "same" means the vowels agree, which is the only case where a shadda
      // difference is judged below. The other non-error cases (waqf, unmarked)
      // are tolerated without being "same".
      var same = ev == hv;
      if (!same) {
        final isFinal = finalWord && i == lastExpIndex;
        if (hv == null || hv == sukun) {
          // The recogniser gave no vowel (or sukun) here. At the end of a
          // stopped-on word that is waqf, not a mistake; elsewhere an expected
          // sukun that is simply omitted is the same thing, and a missing mark
          // is "unmarked" rather than wrong.
          same = !isFinal && ev == sukun;
        } else if (ev == null) {
          // Expected no mark (e.g. a long-vowel letter) but heard one: tolerate.
        } else if (isFinal && ev == fathatan && hv == fatha) {
          // Tanween fath stopped on becomes alif of madd: waqf.
        } else {
          vowelErrors.add(VowelError(letterIndex: i, letter: e.base, expectedMark: ev, heardMark: hv));
        }
      }
      if (same && es != hs && hv != null) {
        // Shadda present/absent with vowels otherwise equal: gemination error.
        vowelErrors.add(VowelError(
          letterIndex: i,
          letter: e.base,
          expectedMark: es ? shadda : null,
          heardMark: hs ? shadda : null,
          kind: VowelErrorKind.shadda,
        ));
      }
    }
    var status = WordComparison.ok;
    if (letterErrors > 0) {
      status = WordComparison.letter;
    } else if (vowelErrors.isNotEmpty) {
      status = WordComparison.vowel;
    } else if (!heardVocalised && hrd.isNotEmpty) {
      status = WordComparison.unvocalised;
    }
    return WordComparisonResult(status: status, letterErrors: letterErrors, vowelErrors: vowelErrors);
  }
}

/// Aligns recognised speech against an expected passage.
class RecitationMatcher {
  RecitationMatcher(List<String> expectedOriginalWords, {this.strict = true, Set<int> stops = const {}})
      : _original = expectedOriginalWords,
        _expected = expectedOriginalWords.map((w) => tokenize(w).join()).toList(),
        _stops = stops;

  final List<String> _original;
  final List<String> _expected;

  /// Indices of words a reciter naturally stops on (ayah ends, pause signs),
  /// where a dropped final vowel is waqf rather than a vowel slip.
  final Set<int> _stops;

  /// Strict: a word counts as correct only when its letters match exactly
  /// (after the orthographic normalisation above); any letter slip is
  /// "wrong". Lenient tolerates small recogniser spelling variations.
  final bool strict;

  static const lenientMatchThreshold = 0.72;
  static const wrongThreshold = 0.4;

  /// Whether a heard word counts as the expected word. Strict mode demands the
  /// same letters, except that alif length differences are ignored: the
  /// Uthmani rasm writes ٱلْعَٰلَمِينَ and ذَٰلِكَ while recognisers spell
  /// العالمين and ذلك, and vowel length is not something the transcript can
  /// tell us about.
  bool isMatch(String expected, String heard, double sim) {
    if (!strict) return sim >= lenientMatchThreshold;
    if (expected == heard) return true;
    return expected.replaceAll('ا', '') == heard.replaceAll('ا', '');
  }

  int get length => _expected.length;

  List<String> get originalWords => _original;

  Set<int> get stops => _stops;

  static final _pauseSign = RegExp(r'^[ۖ-ۛ]+$');

  /// Builds the passage word list from Uthmani ayah texts, dropping empty tokens.
  static List<String> wordsOf(Iterable<String> ayahTexts) =>
      [for (final t in ayahTexts) ...t.split(' ').where((w) => tokenize(w).isNotEmpty)];

  /// Indices (into [wordsOf]) of the last word of each ayah and of words
  /// followed by a pause sign (ۖ ۗ ۘ ۙ ۚ ۛ).
  static Set<int> stopsOf(Iterable<String> ayahTexts) {
    final stops = <int>{};
    var index = -1;
    for (final t in ayahTexts) {
      for (final w in t.split(' ')) {
        if (tokenize(w).isNotEmpty) {
          index++;
        } else if (_pauseSign.hasMatch(w) && index >= 0) {
          stops.add(index);
        }
      }
      if (index >= 0) stops.add(index);
    }
    return stops;
  }

  MatchResult match(String heardText) {
    final heard = tokenize(heardText);
    final n = _expected.length, m = heard.length;
    if (m == 0) {
      return MatchResult(
        words: [for (var i = 0; i < n; i++) WordMatch(original: _original[i], normalized: _expected[i], status: WordStatus.pending)],
        nextIndex: 0,
        extras: const [],
      );
    }

    // Vocalised heard words for the grading pass, used only when they line up
    // one-to-one with the skeleton tokens the alignment works on and at least
    // one carries marks. Unvocalised input (today's recognisers) skips grading.
    List<String>? heardVoc;
    final voc = Harakat.normalizeVocalised(heardText).split(' ').where((w) => w.isNotEmpty).toList();
    if (voc.length == m && voc.any(Harakat.isVocalised)) {
      var aligned = true;
      for (var j = 0; j < m && aligned; j++) {
        aligned = Harakat.skeleton(voc[j]) == heard[j];
      }
      if (aligned) heardVoc = voc;
    }

    // Global alignment (Needleman-Wunsch) between expected[0..n) and heard[0..m).
    // Scores: good match +3, partial (wrong) +1, skip expected -1, extra heard -1.
    final score = List.generate(n + 1, (_) => List<double>.filled(m + 1, 0));
    final move = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0)); // 0 diag,1 up(skip expected),2 left(extra)
    for (var i = 1; i <= n; i++) {
      score[i][0] = -i.toDouble();
      move[i][0] = 1;
    }
    for (var j = 1; j <= m; j++) {
      score[0][j] = -j.toDouble();
      move[0][j] = 2;
    }
    final sims = List.generate(n, (i) => List<double>.filled(m, 0));
    final good = List.generate(n, (i) => List<bool>.filled(m, false));
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= m; j++) {
        final sim = similarity(_expected[i - 1], heard[j - 1]);
        sims[i - 1][j - 1] = sim;
        final ok = isMatch(_expected[i - 1], heard[j - 1], sim);
        good[i - 1][j - 1] = ok;
        final diagGain = ok ? 3.0 : (sim >= wrongThreshold ? 1.0 : -2.0);
        final diag = score[i - 1][j - 1] + diagGain;
        final up = score[i - 1][j] - 1;
        final left = score[i][j - 1] - 1;
        if (diag >= up && diag >= left) {
          score[i][j] = diag;
          move[i][j] = 0;
        } else if (up >= left) {
          score[i][j] = up;
          move[i][j] = 1;
        } else {
          score[i][j] = left;
          move[i][j] = 2;
        }
      }
    }

    // Traceback. Expected words beyond the last heard word are "pending", not missed:
    // find the best end column m against any row i (the recitation may be mid-passage).
    var bestI = 0;
    var best = double.negativeInfinity;
    for (var i = 0; i <= n; i++) {
      // Prefer alignments that end exactly at the last heard word and penalise
      // nothing for the unspoken tail.
      final s = score[i][m];
      if (s > best || (s == best && i > bestI)) {
        best = s;
        bestI = i;
      }
    }
    final statuses = List<WordStatus>.filled(n, WordStatus.pending);
    final heardFor = List<String?>.filled(n, null);
    final vowelFor = List<List<VowelError>>.filled(n, const []);
    final extras = <String>[];
    var i = bestI, j = m;
    while (i > 0 || j > 0) {
      final mv = (i == 0) ? 2 : (j == 0 ? 1 : move[i][j]);
      if (mv == 0) {
        final sim = sims[i - 1][j - 1];
        if (good[i - 1][j - 1]) {
          statuses[i - 1] = WordStatus.matched;
          if (heardVoc != null) {
            // The letters match; grade the vowels. A stopped-on word (ayah end,
            // pause sign, passage end or the last word heard so far) may drop
            // its final vowel.
            final finalWord = _stops.contains(i - 1) || i == n || j == m;
            final c = Harakat.compareWord(_original[i - 1], heardVoc[j - 1], finalWord: finalWord);
            if (c.status == WordComparison.vowel) {
              statuses[i - 1] = WordStatus.vowel;
              heardFor[i - 1] = heardVoc[j - 1];
              vowelFor[i - 1] = c.vowelErrors;
            }
          }
        } else if (sim >= wrongThreshold) {
          statuses[i - 1] = WordStatus.wrong;
          heardFor[i - 1] = heard[j - 1];
        } else {
          statuses[i - 1] = WordStatus.missed;
          extras.add(heard[j - 1]);
        }
        i--;
        j--;
      } else if (mv == 1) {
        statuses[i - 1] = WordStatus.missed;
        i--;
      } else {
        extras.add(heard[j - 1]);
        j--;
      }
    }

    // The cursor only moves past words the reciter demonstrably reached: it
    // sits after the last word heard correctly (letters right, vowels right
    // or slipped), plus at most one wrong word said right there. Anything
    // the alignment placed further on without such an anchor is unproven:
    // a half-similar word the recogniser produced from noise or a quiet
    // start ("والمومنين" for a soft بسم الله الرحمن) used to mark the words
    // before it as missed and drag the cursor ahead, so that the real
    // recitation that followed was compared with the wrong place. Those
    // words go back to pending and what was heard counts as an extra.
    var lastGood = -1;
    for (var k = bestI - 1; k >= 0; k--) {
      if (statuses[k] == WordStatus.matched || statuses[k] == WordStatus.vowel) {
        lastGood = k;
        break;
      }
    }
    var next = lastGood + 1;
    if (next < bestI && statuses[next] == WordStatus.wrong) next++;
    for (var k = next; k < bestI; k++) {
      if (statuses[k] == WordStatus.wrong && heardFor[k] != null) extras.add(heardFor[k]!);
      statuses[k] = WordStatus.pending;
      heardFor[k] = null;
      vowelFor[k] = const [];
    }

    return MatchResult(
      words: [
        for (var k = 0; k < n; k++)
          WordMatch(
            original: _original[k],
            normalized: _expected[k],
            status: statuses[k],
            heard: heardFor[k],
            vowelErrors: vowelFor[k],
          ),
      ],
      nextIndex: next,
      extras: extras.reversed.toList(),
    );
  }
}
