import 'package:flutter_test/flutter_test.dart';
import 'package:quran_plus/data/tajweed.dart';

void main() {
  const marked = 'ذ[n[َٲ]لِكَ [h[ٱ]لْكِتَ[n[ـٰ]بُ لَا رَيْبَ‌ۛ فِيهِ‌ۛ هُ[u[دًى ل]ِّلْمُتَّق[p[ِي]نَ';

  test('segments keep every character and tag the marked runs', () {
    final segs = parseTajweed(marked);
    expect(segs.map((s) => s.text).join(), stripTajweed(marked));
    expect(stripTajweed(marked), 'ذَٲلِكَ ٱلْكِتَـٰبُ لَا رَيْبَ‌ۛ فِيهِ‌ۛ هُدًى لِّلْمُتَّقِينَ');
    expect(segs.where((s) => s.rule == TajweedRule.maddNormal).length, 2);
    expect(segs.where((s) => s.rule == TajweedRule.hamzatWasl).single.text, 'ٱ');
  });

  test('a mark spanning a space is split across both words', () {
    final words = parseTajweedWords(marked);
    expect(words.map((w) => w.text).toList(), ['ذَٲلِكَ', 'ٱلْكِتَـٰبُ', 'لَا', 'رَيْبَ‌ۛ', 'فِيهِ‌ۛ', 'هُدًى', 'لِّلْمُتَّقِينَ']);
    expect(words[5].rules, {TajweedRule.idghamNoGhunnah});
    expect(words[6].rules, {TajweedRule.idghamNoGhunnah, TajweedRule.maddPermissible});
    expect(words[2].rules, isEmpty);
  });

  test('every markup code maps to a rule', () {
    for (final c in 'hslnpmqocfwiaudbg'.split('')) {
      expect(TajweedRule.fromCode(c), isNotNull, reason: c);
    }
    expect(TajweedRule.values.length, 17);
  });
}
