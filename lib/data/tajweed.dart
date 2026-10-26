import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tajweed rule families, in the order the legend shows them.
enum TajweedGroup { madd, nunTanwin, meemSakinah, ghunnah, qalqalah, lam, silent, idghamAdjacent }

/// The seventeen rule classes of the alquran.cloud / quran.com tajweed text
/// (riwayat Hafs). [code] is the letter in the bundled markup, [className]
/// the quran.com `<tajweed class>` name, [color] the classic KFGQPC-derived
/// colour. [tuhfa] / [jazariyyah] cite the lines of Tuhfat al-Atfal and
/// al-Muqaddimah al-Jazariyyah that state the rule.
enum TajweedRule {
  hamzatWasl('h', 'ham_wasl', 0xFFAAAAAA, TajweedGroup.silent, arabic: 'همزة الوصل', jazariyyah: '100–102'),
  silent('s', 'slnt', 0xFFAAAAAA, TajweedGroup.silent, arabic: 'حرف صامت', jazariyyah: '7–8'),
  laamShamsiyyah('l', 'laam_shamsiyah', 0xFFAAAAAA, TajweedGroup.lam, arabic: 'اللام الشمسية', tuhfa: '26–28'),
  maddNormal('n', 'madda_normal', 0xFF537FFF, TajweedGroup.madd, arabic: 'المد الطبيعي', tuhfa: '35–40', counts: '2'),
  maddPermissible('p', 'madda_permissible', 0xFF4050FF, TajweedGroup.madd, arabic: 'المد الجائز', tuhfa: '42–45', counts: '2, 4, 6'),
  maddNecessary('m', 'madda_necessary', 0xFF000EBC, TajweedGroup.madd, arabic: 'المد اللازم', tuhfa: '47–54', counts: '6'),
  qalqalah('q', 'qalaqah', 0xFFDD0008, TajweedGroup.qalqalah, arabic: 'القلقلة', jazariyyah: '23, 38', letters: 'ق ط ب ج د'),
  maddObligatory('o', 'madda_obligatory', 0xFF2144C1, TajweedGroup.madd, arabic: 'المد الواجب المتصل', tuhfa: '42–43', counts: '4–5'),
  ikhfaShafawi('c', 'ikhafa_shafawi', 0xFFD500B7, TajweedGroup.meemSakinah, arabic: 'الإخفاء الشفوي', tuhfa: '19–20', letters: 'ب'),
  ikhfa('f', 'ikhafa', 0xFF9400A8, TajweedGroup.nunTanwin, arabic: 'الإخفاء الحقيقي', tuhfa: '14–16', letters: 'ت ث ج د ذ ز س ش ص ض ط ظ ف ق ك'),
  idghamShafawi('w', 'idgham_shafawi', 0xFF58B800, TajweedGroup.meemSakinah, arabic: 'الإدغام الشفوي', tuhfa: '21', letters: 'م'),
  iqlab('i', 'iqlab', 0xFF26BFFD, TajweedGroup.nunTanwin, arabic: 'الإقلاب', tuhfa: '13', letters: 'ب'),
  idghamGhunnah('a', 'idgham_ghunnah', 0xFF169777, TajweedGroup.nunTanwin, arabic: 'الإدغام بغنة', tuhfa: '9–11', letters: 'ي ن م و'),
  idghamNoGhunnah('u', 'idgham_wo_ghunnah', 0xFF169200, TajweedGroup.nunTanwin, arabic: 'الإدغام بلا غنة', tuhfa: '12', letters: 'ل ر'),
  idghamMutajanisayn('d', 'idgham_mutajanisayn', 0xFFA1A1A1, TajweedGroup.idghamAdjacent, arabic: 'إدغام المتجانسين', tuhfa: '32–33'),
  idghamMutaqaribayn('b', 'idgham_mutaqaribayn', 0xFFA1A1A1, TajweedGroup.idghamAdjacent, arabic: 'إدغام المتقاربين', tuhfa: '31, 33'),
  ghunnah('g', 'ghunnah', 0xFFFF7E1E, TajweedGroup.ghunnah, arabic: 'الغنة', tuhfa: '17', counts: '2');

  const TajweedRule(this.code, this.className, this.colorValue, this.group,
      {required this.arabic, this.tuhfa, this.jazariyyah, this.letters, this.counts});

  final String code;
  final String className;
  final int colorValue;
  final TajweedGroup group;
  final String arabic;

  /// Lines of Tuhfat al-Atfal that state the rule.
  final String? tuhfa;

  /// Lines of al-Muqaddimah al-Jazariyyah that state the rule.
  final String? jazariyyah;

  /// The letters that trigger the rule, when it is letter-driven.
  final String? letters;

  /// Prolongation length in vowel counts (harakat), for madd and ghunnah.
  final String? counts;

  Color get color => Color(colorValue);

  static final _byCode = {for (final r in TajweedRule.values) r.code: r};
  static TajweedRule? fromCode(String code) => _byCode[code];
}

/// A run of letters that share one rule (or none).
class TajweedSegment {
  const TajweedSegment(this.text, this.rule);
  final String text;
  final TajweedRule? rule;
}

/// One word of an ayah split into rule segments.
class TajweedWord {
  const TajweedWord(this.segments);
  final List<TajweedSegment> segments;

  String get text => segments.map((s) => s.text).join();
  Set<TajweedRule> get rules => {for (final s in segments) if (s.rule != null) s.rule!};
}

/// Parses "[c[text]" markup into segments. Nested marks do not occur in the
/// source; a mark may span a space.
List<TajweedSegment> parseTajweed(String marked) {
  final out = <TajweedSegment>[];
  final buf = StringBuffer();
  TajweedRule? current;
  void flush() {
    if (buf.isEmpty) return;
    out.add(TajweedSegment(buf.toString(), current));
    buf.clear();
  }

  var i = 0;
  while (i < marked.length) {
    final ch = marked[i];
    if (ch == '[' && i + 2 < marked.length && marked[i + 2] == '[') {
      final rule = TajweedRule.fromCode(marked[i + 1]);
      if (rule != null) {
        flush();
        current = rule;
        i += 3;
        continue;
      }
    }
    if (ch == ']' && current != null) {
      flush();
      current = null;
      i++;
      continue;
    }
    buf.write(ch);
    i++;
  }
  flush();
  return out;
}

/// Splits the segments of an ayah into words at spaces, so every word knows
/// its own coloured pieces. Zero-width joiners around pause marks are kept
/// with the preceding word.
List<TajweedWord> parseTajweedWords(String marked) {
  final words = <TajweedWord>[];
  var current = <TajweedSegment>[];
  for (final seg in parseTajweed(marked)) {
    final parts = seg.text.split(' ');
    for (var k = 0; k < parts.length; k++) {
      if (k > 0) {
        if (current.isNotEmpty) words.add(TajweedWord(current));
        current = <TajweedSegment>[];
      }
      if (parts[k].isNotEmpty) current.add(TajweedSegment(parts[k], seg.rule));
    }
  }
  if (current.isNotEmpty) words.add(TajweedWord(current));
  return words;
}

/// Plain text of a marked ayah.
String stripTajweed(String marked) => parseTajweed(marked).map((s) => s.text).join();

/// The bundled tajweed text (6236 ayahs, global order), parsed on demand.
class TajweedRepository {
  TajweedRepository(this._raw);
  final List<String> _raw;
  final _cache = <int, List<TajweedWord>>{};

  static Future<TajweedRepository> load() async {
    final raw = await rootBundle.loadString('assets/data/tajweed.json');
    return TajweedRepository((jsonDecode(raw) as List).cast<String>());
  }

  String markedText(int globalAyah) => _raw[globalAyah - 1];

  List<TajweedWord> wordsOf(int globalAyah) => _cache.putIfAbsent(globalAyah, () => parseTajweedWords(_raw[globalAyah - 1]));

  /// First word of the Quran that carries [rule], with its ayah number;
  /// used as the example in the guide.
  (int ayah, TajweedWord word)? exampleOf(TajweedRule rule, {int startAyah = 1}) {
    final needle = '[${rule.code}[';
    for (var n = startAyah; n <= _raw.length; n++) {
      if (!_raw[n - 1].contains(needle)) continue;
      for (final w in wordsOf(n)) {
        if (w.rules.contains(rule)) return (n, w);
      }
    }
    return null;
  }
}

final tajweedProvider = FutureProvider<TajweedRepository>((ref) => TajweedRepository.load());
