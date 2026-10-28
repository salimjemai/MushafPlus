import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import 'models.dart';

/// The line layout of the printed Madani Mushaf: which words sit on which of
/// the 15 lines of each of the 604 pages (8 lines on the two opening pages),
/// generated once by `tool/gen_pages.mjs` from the quran.com page data into
/// `assets/data/pages.json`. Only positions are stored; the words themselves
/// are the bundled Tanzil text.
///
/// Positions count *visual* words: Tanzil writes pause marks (ۖ ۗ ۚ …) and
/// the sajdah sign as separate space-delimited tokens and the rub' al-hizb
/// star before the ayah, while the Mushaf prints them attached to a word.
/// [visualWordsOf] merges them the same way as the generator. The index equal
/// to the number of visual words stands for the ayah-end marker.
class MushafPages {
  MushafPages(this._pages, {required String basmala})
      : _basmala = RegExp(
            '^${basmala.replaceFirst(RegExp('^ب[ِّ]+'), 'ب[ِّ]{1,2}')} ');

  final List<PageLayout?> _pages;
  final RegExp _basmala;
  final _words = <int, List<VisualWord>>{};

  /// Pages with a known layout.
  int get count => _pages.where((p) => p != null).length;

  /// The layout of [page] (1..604), or null when the asset has none.
  PageLayout? page(int page) => page < 1 || page > _pages.length ? null : _pages[page - 1];

  static Future<MushafPages> load({required String basmala}) async {
    final raw = await rootBundle.loadString('assets/data/pages.json');
    return MushafPages.parse(raw, basmala: basmala);
  }

  /// Parses the generator's output; [basmala] is the text of ayah 1:1, which
  /// the generator used to recognise the basmala written inside first ayahs.
  static MushafPages parse(String json, {required String basmala}) {
    final list = jsonDecode(json) as List;
    final pages = <PageLayout?>[];
    for (var i = 0; i < list.length; i++) {
      final p = list[i];
      if (p is! Map) {
        pages.add(null);
        continue;
      }
      final lines = <PageLine>[];
      for (final l in p['l'] as List) {
        final a = l as List;
        if (a[0] == 'h') {
          lines.add(HeaderLine(a[1] as int));
        } else if (a[0] == 'b') {
          lines.add(const BasmalaLine());
        } else {
          lines.add(TextLine(PageToken(a[0] as int, a[1] as int)));
        }
      }
      final e = p['e'] as List;
      pages.add(PageLayout(i + 1, lines, PageToken(e[0] as int, e[1] as int)));
    }
    return MushafPages(pages, basmala: basmala);
  }

  /// The words of [ayah] as the Mushaf prints them, each knowing which
  /// Tanzil tokens (space-delimited pieces of [Ayah.text]) it covers.
  List<VisualWord> visualWordsOf(Ayah ayah) => _words.putIfAbsent(ayah.number, () {
        var text = ayah.text;
        var offset = 0;
        if (ayah.numberInSurah == 1 && ayah.surah != 1) {
          // Tanzil writes the basmala inside the first ayah of a few surahs
          // (95, 97); the Mushaf prints it on its own line.
          final m = _basmala.firstMatch(text);
          if (m != null) {
            text = text.substring(m.end);
            offset = m.group(0)!.trim().split(' ').length;
          }
        }
        final tokens = text.split(' ');
        final out = <VisualWord>[];
        var prefix = '';
        var prefixStart = -1;
        for (var i = 0; i < tokens.length; i++) {
          final t = tokens[i];
          final k = i + offset;
          if (t == '۞') {
            // rub' al-hizb star: printed before the next word
            prefix += '$t ';
            if (prefixStart < 0) prefixStart = k;
          } else if (out.isNotEmpty && (_after.hasMatch(t) || out.last.text == 'إِلْ')) {
            // pause marks and the sajdah sign stay with the word before;
            // 37:130 prints إِلْ يَاسِينَ as one word
            final last = out.removeLast();
            out.add(VisualWord('${last.text} $t', last.firstToken, k));
          } else {
            out.add(VisualWord(prefix + t, prefixStart < 0 ? k : prefixStart, k));
            prefix = '';
            prefixStart = -1;
          }
        }
        return out;
      });

  static final _after = RegExp(r'^[ۖ-ۜ۩]$');
}

/// A word of an ayah on the page, made of Tanzil tokens [firstToken]
/// to [lastToken] (inclusive) of [Ayah.text].
class VisualWord {
  const VisualWord(this.text, this.firstToken, this.lastToken);
  final String text;
  final int firstToken;
  final int lastToken;
}

/// A position in the Quran: a visual word of an ayah (global number), or
/// its end marker when [word] equals the number of visual words.
class PageToken {
  const PageToken(this.ayah, this.word);
  final int ayah;
  final int word;

  @override
  bool operator ==(Object other) => other is PageToken && other.ayah == ayah && other.word == word;

  @override
  int get hashCode => Object.hash(ayah, word);

  @override
  String toString() => '$ayah:$word';
}

sealed class PageLine {
  const PageLine();
}

/// The ornamental band with the surah name.
class HeaderLine extends PageLine {
  const HeaderLine(this.surah);
  final int surah;
}

/// The basmala centred on its own line.
class BasmalaLine extends PageLine {
  const BasmalaLine();
}

/// A line of words, from [start] up to the start of the next text line (or
/// the page's last token).
class TextLine extends PageLine {
  const TextLine(this.start);
  final PageToken start;
}

/// One page: its lines in order (fewer than the page's slots when the last
/// line is blank) and the last word printed on it.
class PageLayout {
  const PageLayout(this.page, this.lines, this.end);
  final int page;
  final List<PageLine> lines;
  final PageToken end;

  /// Lines on the page: 8 inside the illuminated frame of the two opening
  /// pages, 15 elsewhere.
  int get slots => page <= 2 ? 8 : 15;

  /// The start of the text line after index [i], or null when there is none.
  PageToken? nextTextStart(int i) {
    for (var k = i + 1; k < lines.length; k++) {
      final l = lines[k];
      if (l is TextLine) return l.start;
    }
    return null;
  }
}

final mushafPagesProvider = FutureProvider<MushafPages>((ref) async {
  final repo = await ref.watch(repositoryProvider.future);
  return MushafPages.load(basmala: repo.ayah(1).text);
});
