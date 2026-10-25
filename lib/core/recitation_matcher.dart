import 'dart:math' as math;

import 'arabic_utils.dart';

/// How each expected word of the passage fared against what was heard.
enum WordStatus { pending, matched, wrong, missed }

class WordMatch {
  const WordMatch({required this.original, required this.normalized, required this.status, this.heard});
  final String original; // Uthmani text as printed
  final String normalized;
  final WordStatus status;

  /// What the recogniser produced for a wrong word.
  final String? heard;

  WordMatch copyWith({WordStatus? status, String? heard}) =>
      WordMatch(original: original, normalized: normalized, status: status ?? this.status, heard: heard ?? this.heard);
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
  int get reached => nextIndex;
  bool get complete => nextIndex >= words.length;

  /// Accuracy over the words reached so far (0..1).
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

/// Aligns recognised speech against an expected passage.
class RecitationMatcher {
  RecitationMatcher(List<String> expectedOriginalWords)
      : _original = expectedOriginalWords,
        _expected = expectedOriginalWords.map((w) => tokenize(w).join()).toList();

  final List<String> _original;
  final List<String> _expected;

  static const matchThreshold = 0.72;
  static const wrongThreshold = 0.4;

  int get length => _expected.length;

  /// Builds the passage word list from Uthmani ayah texts, dropping empty tokens.
  static List<String> wordsOf(Iterable<String> ayahTexts) =>
      [for (final t in ayahTexts) ...t.split(' ').where((w) => tokenize(w).isNotEmpty)];

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
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= m; j++) {
        final sim = similarity(_expected[i - 1], heard[j - 1]);
        sims[i - 1][j - 1] = sim;
        final diagGain = sim >= matchThreshold ? 3.0 : (sim >= wrongThreshold ? 1.0 : -2.0);
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
    final extras = <String>[];
    var i = bestI, j = m;
    while (i > 0 || j > 0) {
      final mv = (i == 0) ? 2 : (j == 0 ? 1 : move[i][j]);
      if (mv == 0) {
        final sim = sims[i - 1][j - 1];
        if (sim >= matchThreshold) {
          statuses[i - 1] = WordStatus.matched;
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

    // Trailing missed words right before the cursor are more likely "not yet
    // said" than skipped: treat a run of missed words at the end as pending.
    var next = bestI;
    while (next > 0 && statuses[next - 1] == WordStatus.missed) {
      statuses[next - 1] = WordStatus.pending;
      next--;
    }

    return MatchResult(
      words: [
        for (var k = 0; k < n; k++)
          WordMatch(original: _original[k], normalized: _expected[k], status: statuses[k], heard: heardFor[k]),
      ],
      nextIndex: next,
      extras: extras.reversed.toList(),
    );
  }
}
