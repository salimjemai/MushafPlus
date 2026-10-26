import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_plus/features/search/highlight.dart';

void main() {
  const base = TextStyle();
  const hi = TextStyle(fontWeight: FontWeight.bold);

  test('Arabic query marks the matching word only', () {
    const ayah = 'قُتِلَ ٱلْإِنسَٰنُ مَآ أَكْفَرَهُۥ';
    expect(matchedArabicWords(ayah, 'Qutilal-insanu maa akfarah.', 'انسان'), {1});
    expect(matchedArabicWords(ayah, 'Qutilal-insanu maa akfarah.', 'الإنسان'), {1});
  });

  test('Latin query marks the Arabic word through its transliteration', () {
    const ayah = 'قُتِلَ ٱلْإِنسَٰنُ مَآ أَكْفَرَهُۥ';
    expect(matchedArabicWords(ayah, 'Qutilal insanu maa akfarah', 'insan'), {1});
  });

  test('Latin snippet highlights every occurrence and trims around the first', () {
    final short = latinSnippetSpans('And mercy upon them, a mercy indeed.', 'mercy', base, hi);
    expect(short.where((s) => (s as TextSpan).style == hi).length, 2);
    final long = latinSnippetSpans('${'word ' * 60}mercy${' word' * 60}', 'mercy', base, hi);
    expect((long.first as TextSpan).text, '… ');
    expect(long.any((s) => (s as TextSpan).text == 'mercy' && s.style == hi), isTrue);
  });

  test('Arabic snippet windows around the first match', () {
    final words = List.generate(40, (i) => 'كلمة$i').join(' ');
    final spans = arabicSnippetSpans(words, {30}, base, hi);
    expect((spans.first as TextSpan).text, '… ');
    expect(spans.any((s) => (s as TextSpan).text == 'كلمة30' && s.style == hi), isTrue);
  });
}
