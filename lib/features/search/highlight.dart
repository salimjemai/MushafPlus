import 'package:flutter/material.dart';

import '../../core/arabic_utils.dart';

/// Which words of an Arabic ayah match the query. Arabic queries match by
/// the diacritic- and alif-insensitive search key; Latin queries match the
/// word's transliteration (when the transliteration has one token per word).
Set<int> matchedArabicWords(String ayahText, String transliteration, String query) {
  final words = ayahText.split(' ');
  final out = <int>{};
  final q = query.trim();
  if (q.length < 2) return out;
  if (containsArabic(q)) {
    final tokens = q.split(RegExp(r'\s+')).map(arabicSearchKey).where((t) => t.length >= 2).toList();
    if (tokens.isEmpty) return out;
    for (var i = 0; i < words.length; i++) {
      final k = arabicSearchKey(words[i]);
      if (k.isEmpty) continue;
      if (tokens.any((t) => k.contains(t) || (t.length >= 4 && t.contains(k) && k.length >= 3))) out.add(i);
    }
    return out;
  }
  final tokens = q.split(RegExp(r'\s+')).map(transliterationSearchKey).where((t) => t.length >= 2).toList();
  final tr = transliteration.split(' ');
  // the transliteration mirrors the Arabic words one for one in most ayahs
  final arabicWords = words.where((w) => containsArabic(w)).length;
  if (tokens.isEmpty || tr.length != arabicWords) return out;
  var ai = 0;
  for (var i = 0; i < words.length; i++) {
    if (!containsArabic(words[i])) continue;
    final k = transliterationSearchKey(tr[ai++]);
    if (tokens.any((t) => k.contains(t))) out.add(i);
  }
  return out;
}

/// The ayah's words as spans, matched words highlighted, trimmed to a
/// window around the first match when the ayah is long.
List<InlineSpan> arabicSnippetSpans(String ayahText, Set<int> matched, TextStyle base, TextStyle highlight, {int window = 14}) {
  final words = ayahText.split(' ');
  var start = 0;
  var end = words.length;
  if (matched.isNotEmpty && words.length > window + 4) {
    final first = matched.reduce((a, b) => a < b ? a : b);
    start = (first - window ~/ 3).clamp(0, words.length);
    end = (start + window).clamp(0, words.length);
    start = (end - window).clamp(0, start);
  }
  final spans = <InlineSpan>[];
  if (start > 0) spans.add(TextSpan(text: '… ', style: base));
  for (var i = start; i < end; i++) {
    if (i > start) spans.add(TextSpan(text: ' ', style: base));
    spans.add(TextSpan(text: words[i], style: matched.contains(i) ? highlight : base));
  }
  if (end < words.length) spans.add(TextSpan(text: ' …', style: base));
  return spans;
}

/// Latin text with case-insensitive occurrences of the query's words
/// highlighted, trimmed to a window around the first occurrence.
List<InlineSpan> latinSnippetSpans(String text, String query, TextStyle base, TextStyle highlight, {int radius = 90}) {
  final q = query.trim();
  final tokens = q.split(RegExp(r'\s+')).where((t) => t.length >= 2).toList();
  final lower = text.toLowerCase();
  final ranges = <(int, int)>[];
  // whole-phrase first, then single words
  for (final t in [if (tokens.length > 1) q, ...tokens]) {
    final lt = t.toLowerCase();
    var from = 0;
    while (true) {
      final i = lower.indexOf(lt, from);
      if (i < 0) break;
      ranges.add((i, i + lt.length));
      from = i + lt.length;
    }
  }
  if (ranges.isEmpty) return [TextSpan(text: text, style: base)];
  ranges.sort((a, b) => a.$1.compareTo(b.$1));
  // merge overlaps
  final merged = <(int, int)>[];
  for (final r in ranges) {
    if (merged.isNotEmpty && r.$1 <= merged.last.$2) {
      merged[merged.length - 1] = (merged.last.$1, r.$2 > merged.last.$2 ? r.$2 : merged.last.$2);
    } else {
      merged.add(r);
    }
  }
  var start = 0;
  var end = text.length;
  if (text.length > radius * 2 + 20) {
    start = (merged.first.$1 - radius).clamp(0, text.length);
    end = (merged.first.$1 + radius).clamp(0, text.length);
    // cut at word boundaries
    if (start > 0) {
      final sp = text.indexOf(' ', start);
      if (sp >= 0 && sp < merged.first.$1) start = sp + 1;
    }
    if (end < text.length) {
      final sp = text.lastIndexOf(' ', end);
      if (sp > merged.first.$2) end = sp;
    }
  }
  final spans = <InlineSpan>[];
  if (start > 0) spans.add(TextSpan(text: '… ', style: base));
  var cursor = start;
  for (final (a, b) in merged) {
    if (b <= start || a >= end) continue;
    final ca = a < start ? start : a;
    final cb = b > end ? end : b;
    if (ca > cursor) spans.add(TextSpan(text: text.substring(cursor, ca), style: base));
    spans.add(TextSpan(text: text.substring(ca, cb), style: highlight));
    cursor = cb;
  }
  if (cursor < end) spans.add(TextSpan(text: text.substring(cursor, end), style: base));
  if (end < text.length) spans.add(TextSpan(text: ' …', style: base));
  return spans;
}
