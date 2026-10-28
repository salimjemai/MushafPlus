import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/arabic_utils.dart';
import '../../core/theme.dart';
import 'medina_ornaments.dart';
import '../../data/models.dart';
import '../../data/mushaf_pages.dart';
import '../../data/tajweed.dart';
import '../../state/audio_controller.dart';
import '../../state/providers.dart';
import '../reader/tajweed_text.dart';

/// The text of one Mushaf page laid out line by line as in the printed
/// Madani Mushaf: every line holds exactly the words the print has on it,
/// justified to the full width (the last line of a surah is centred),
/// surah headers as ornamental bands and the basmala centred on its own line.
///
/// Fills the width it is given. With a bounded height the lines share it
/// equally; otherwise the line height follows the width, in the proportions
/// of the printed page.
class MushafPageLines extends ConsumerStatefulWidget {
  const MushafPageLines({
    super.key,
    required this.layout,
    required this.ink,
    required this.frame,
    required this.onAyahTap,
    this.onWordTap,
  });

  final PageLayout layout;
  final Color ink;
  final Color frame;
  final ValueChanged<Ayah> onAyahTap;

  /// Tap on a word (index among the visual words of the ayah, which is the
  /// word's position in the quran.com word-by-word data); when null, taps
  /// open the ayah.
  final void Function(Ayah ayah, int wordIndex)? onWordTap;

  /// Height of a line relative to the page width when the height is free.
  static const lineHeightFactor = 0.108;

  /// Glyph size relative to the line height.
  static const fontFactor = 0.52;

  @override
  ConsumerState<MushafPageLines> createState() => _MushafPageLinesState();
}

/// A word or an ayah-end marker on a line.
class _Token {
  const _Token(this.ayah, this.index, this.word);
  final Ayah ayah;

  /// Visual word index, or the number of words for the end marker.
  final int index;

  /// Null for the end marker.
  final VisualWord? word;

  bool get isEnd => word == null;
}

class _MushafPageLinesState extends ConsumerState<MushafPageLines> {
  int? _selected;
  double? _measuredWidth;
  double? _measuredFont;
  double _scale = 1;

  /// The tokens of each line (null for header and basmala lines).
  late List<List<_Token>?> _lines = _expand();

  @override
  void didUpdateWidget(MushafPageLines old) {
    super.didUpdateWidget(old);
    if (old.layout != widget.layout) {
      _lines = _expand();
      _measuredWidth = null;
    }
  }

  List<List<_Token>?> _expand() {
    final repo = ref.quran;
    final pages = ref.read(mushafPagesProvider).requireValue;
    final layout = widget.layout;
    final out = <List<_Token>?>[];
    for (var i = 0; i < layout.lines.length; i++) {
      final line = layout.lines[i];
      if (line is! TextLine) {
        out.add(null);
        continue;
      }
      final stop = layout.nextTextStart(i);
      final tokens = <_Token>[];
      var n = line.start.ayah;
      var w = line.start.word;
      while (true) {
        final ayah = repo.ayah(n);
        final words = pages.visualWordsOf(ayah);
        final token = PageToken(n, w);
        if (token == stop) break;
        tokens.add(_Token(ayah, w, w < words.length ? words[w] : null));
        if (token == layout.end) break;
        if (w < words.length) {
          w++;
        } else {
          n++;
          w = 0;
          if (n > repo.ayahs.length) break;
        }
      }
      out.add(tokens);
    }
    return out;
  }

  final _tajweed = <int, List<TajweedWord>?>{};

  /// The tajweed words of [a] grouped like its visual words, or null when
  /// the two cannot be aligned (the ayah is then drawn without colours).
  List<TajweedWord>? _tajweedWords(TajweedRepository taj, Ayah a) => _tajweed.putIfAbsent(a.number, () {
        final visual = ref.read(mushafPagesProvider).requireValue.visualWordsOf(a);
        var words = taj.wordsOf(a.number);
        final merged = <TajweedWord>[];
        var prefix = <TajweedSegment>[];
        for (final w in words) {
          final text = w.text;
          if (text == '\u06DE') {
            prefix = [...prefix, ...w.segments, const TajweedSegment(' ', null)];
          } else if (merged.isNotEmpty &&
              (_after.hasMatch(text) || merged.last.text == '\u0625\u0650\u0644\u0652')) {
            final last = merged.removeLast();
            merged.add(TajweedWord([...last.segments, const TajweedSegment(' ', null), ...w.segments]));
          } else {
            merged.add(prefix.isEmpty ? w : TajweedWord([...prefix, ...w.segments]));
            prefix = [];
          }
        }
        words = merged;
        if (a.numberInSurah == 1 && a.surah != 1 && words.length == visual.length + 4) {
          words = words.sublist(4); // the basmala written inside the ayah
        }
        return words.length == visual.length ? words : null;
      });

  static final _after = RegExp(r'^[\u06D6-\u06DC\u06E9]$');

  /// Whether the line at [i] closes a surah (centred when short).
  bool _closesSurah(int i) {
    final tokens = _lines[i];
    if (tokens == null || tokens.isEmpty) return false;
    final last = tokens.last;
    if (!last.isEnd) return false;
    final surah = ref.quran.surah(last.ayah.surah);
    return last.ayah.numberInSurah == surah.numberOfAyahs;
  }

  TextStyle _wordStyle(double fontSize) => TextStyle(
        fontFamily: ArabicStyles.mushafFont,
        fontSize: fontSize,
        height: 1.0,
        color: widget.ink,
      );

  TextStyle _markerStyle(double fontSize, ColorScheme scheme) => TextStyle(
        fontFamily: ArabicStyles.nameFont,
        fontSize: fontSize * 0.95,
        height: 1.0,
        color: MedinaPalette.of(scheme.brightness == Brightness.dark).green,
      );

  /// Shrinks the glyphs when the widest line would not fit [width].
  void _measure(double width, double fontSize, ColorScheme scheme) {
    if (_measuredWidth == width && _measuredFont == fontSize) return;
    _measuredWidth = width;
    _measuredFont = fontSize;
    var widest = 0.0;
    final word = _wordStyle(fontSize);
    final marker = _markerStyle(fontSize, scheme);
    for (final tokens in _lines) {
      if (tokens == null) continue;
      final painter = TextPainter(
        textDirection: TextDirection.rtl,
        text: TextSpan(children: [
          for (var k = 0; k < tokens.length; k++) ...[
            if (k > 0) TextSpan(text: ' ', style: word),
            if (tokens[k].isEnd)
              TextSpan(text: ayahEndMarker(tokens[k].ayah.numberInSurah), style: marker)
            else
              TextSpan(text: tokens[k].word!.text, style: word),
          ],
        ]),
      )..layout();
      if (painter.width > widest) widest = painter.width;
      painter.dispose();
    }
    _scale = widest > width ? width / widest : 1;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final taj = settings.tajweed ? ref.watch(tajweedProvider).asData?.value : null;
    final playingAyah = ref.watch(audioProvider.select((a) => a.ayah));
    final highlights = ref.watch(highlightsProvider);
    final notes = ref.watch(notesProvider);
    final repo = ref.quran;
    final layout = widget.layout;

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final lineHeight = constraints.hasBoundedHeight
          ? constraints.maxHeight / layout.slots
          : width * MushafPageLines.lineHeightFactor;
      final baseFont = lineHeight * MushafPageLines.fontFactor;
      _measure(width, baseFont, scheme);
      final fontSize = baseFont * _scale;
      final word = _wordStyle(fontSize);
      final marker = _markerStyle(fontSize, scheme);

      TextStyle styleFor(Ayah a, TextStyle base) {
        Color? bg;
        if (playingAyah == a.number) {
          bg = scheme.primary.withValues(alpha: 0.22);
        } else if (_selected == a.number) {
          bg = highlightColors[0].withValues(alpha: dark ? 0.35 : 0.6);
        } else if (highlights.containsKey(a.number)) {
          bg = highlightColors[highlights[a.number]!].withValues(alpha: dark ? 0.3 : 0.5);
        }
        final noted = notes.containsKey(a.number);
        return base.copyWith(
          backgroundColor: bg,
          decoration: noted ? TextDecoration.underline : null,
          decorationStyle: noted ? TextDecorationStyle.dotted : null,
          decorationColor: noted ? scheme.secondary : null,
        );
      }

      void select(Ayah a) {
        setState(() => _selected = a.number);
        ref.read(lastReadProvider.notifier).set(a.number);
      }

      Widget tokenWidget(_Token t) {
        final a = t.ayah;
        if (t.isEnd) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              select(a);
              widget.onAyahTap(a);
            },
            child: Text(ayahEndMarker(a.numberInSurah),
                style: styleFor(a, marker), textDirection: TextDirection.rtl),
          );
        }
        final st = styleFor(a, word);
        final v = t.word!;
        final tw = taj == null ? null : _tajweedWords(taj, a);
        final spans = tw == null
            ? [TextSpan(text: v.text, style: st)]
            : tajweedWordSpans(tw[t.index], st, dark: dark);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            select(a);
            if (widget.onWordTap != null) {
              widget.onWordTap!(a, t.index);
            } else {
              widget.onAyahTap(a);
            }
          },
          child: Text.rich(TextSpan(children: spans), textDirection: TextDirection.rtl, style: st),
        );
      }

      Widget lineWidget(int i) {
        final line = layout.lines[i];
        switch (line) {
          case HeaderLine(:final surah):
            return SurahBanner(
              surah: repo.surah(surah),
              frame: widget.frame,
              ink: widget.ink,
              height: lineHeight,
            );
          case BasmalaLine():
            return Center(
              child: Text(bismillah, style: word, textDirection: TextDirection.rtl),
            );
          case TextLine():
            final tokens = _lines[i]!;
            final centred = _closesSurah(i) || tokens.length == 1;
            final children = [for (final t in tokens) tokenWidget(t)];
            return Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: centred ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                for (var k = 0; k < children.length; k++) ...[
                  if (k > 0 && centred) SizedBox(width: fontSize * 0.35),
                  children[k],
                ],
              ],
            );
        }
      }

      return SizedBox(
        height: lineHeight * layout.slots,
        child: Column(
          children: [
            for (var i = 0; i < layout.lines.length; i++)
              SizedBox(height: lineHeight, child: Center(child: lineWidget(i))),
          ],
        ),
      );
    });
  }
}

/// The ornamental band carrying a surah's name, as printed above its first
/// ayah. [height] sizes it to a Mushaf line; without it the band is the
/// reader's default size and, when [showBasmala] is set, the basmala follows.
class SurahBanner extends StatelessWidget {
  const SurahBanner({
    super.key,
    required this.surah,
    required this.frame,
    required this.ink,
    this.height,
    this.showBasmala = false,
  });
  final Surah surah;
  final Color frame;
  final Color ink;
  final double? height;
  final bool showBasmala;

  @override
  Widget build(BuildContext context) {
    final h = height ?? 54.0;
    final palette = MedinaPalette.of(Theme.of(context).brightness == Brightness.dark);
    final band = SizedBox(
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: MedinaBandPainter(palette: palette))),
          Container(
            padding: EdgeInsets.symmetric(horizontal: h * 0.5, vertical: h * 0.06),
            decoration: BoxDecoration(
              color: palette.paper,
              borderRadius: BorderRadius.circular(h * 0.45),
              border: Border.all(color: palette.green, width: h > 40 ? 1.4 : 1),
            ),
            child: Text(surah.name,
                style: TextStyle(
                    fontFamily: ArabicStyles.nameFont,
                    fontSize: h * 0.44,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: palette.greenDark)),
          ),
        ],
      ),
    );
    if (height != null) return band;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          band,
          if (showBasmala && surah.hasBismillahHeader)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(bismillah,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontFamily: ArabicStyles.quranFont,
                      fontSize: 24,
                      height: 1.8,
                      color: ink)),
            ),
        ],
      ),
    );
  }
}

/// Lattice pattern behind a surah banner.
class BandPatternPainter extends CustomPainter {
  const BandPatternPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    const step = 16.0;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), p);
      canvas.drawLine(Offset(x + size.height, 0), Offset(x, size.height), p);
    }
    final dot = Paint()..color = color;
    for (var x = step / 2; x < size.width; x += step) {
      canvas.drawCircle(Offset(x, size.height / 2), 1.3, dot);
    }
  }

  @override
  bool shouldRepaint(covariant BandPatternPainter old) => old.color != color;
}
