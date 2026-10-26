import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/audio_controller.dart';
import '../../data/tajweed.dart';
import '../../state/providers.dart';
import 'reader_screen.dart';
import 'tajweed_text.dart';

/// Continuous Arabic-only layout, like a printed Mushaf page. Tap an ayah to
/// open its actions.
class MushafView extends ConsumerWidget {
  const MushafView({
    super.key,
    required this.surah,
    required this.ayahs,
    required this.onAyahTap,
    this.initialAyah,
  });

  final Surah surah;
  final List<Ayah> ayahs;
  final ValueChanged<Ayah> onAyahTap;
  final int? initialAyah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        children: [
          SurahHeader(surah: surah),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: MushafText(
                ayahs: ayahs,
                onAyahTap: onAyahTap,
                initialSelected: initialAyah == null ? null : surah.startAyah + initialAyah! - 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.tapAyahHint,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// The flowing, justified Arabic text of a run of ayahs with ayah-end
/// ornaments. Highlights the ayah being recited and the tapped ayah.
class MushafText extends ConsumerStatefulWidget {
  const MushafText({
    super.key,
    required this.ayahs,
    required this.onAyahTap,
    this.onWordTap,
    this.initialSelected,
    this.style,
  });

  final List<Ayah> ayahs;
  final ValueChanged<Ayah> onAyahTap;

  /// Tap on a word (index within the ayah); when null, taps open the ayah.
  final void Function(Ayah ayah, int wordIndex)? onWordTap;

  /// Global number of the ayah to highlight initially.
  final int? initialSelected;

  /// Base text style; defaults to the reader's Arabic style from settings.
  final TextStyle? style;

  @override
  ConsumerState<MushafText> createState() => _MushafTextState();
}

class _MushafTextState extends ConsumerState<MushafText> {
  final _recognizers = <TapGestureRecognizer>[];
  int? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  /// Recognizers are pooled by position so rebuilds reuse them.
  TapGestureRecognizer _rec(int i, VoidCallback onTap) {
    while (_recognizers.length <= i) {
      _recognizers.add(TapGestureRecognizer());
    }
    return _recognizers[i]..onTap = onTap;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final base = widget.style ?? ArabicStyles.ayah(context, scale: settings.arabicScale, font: settings.arabicFont);
    final playingAyah = ref.watch(audioProvider.select((a) => a.ayah));
    final highlights = ref.watch(highlightsProvider);
    final notes = ref.watch(notesProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final taj = settings.tajweed ? ref.watch(tajweedProvider).asData?.value : null;

    TextStyle styleFor(Ayah a) {
      Color? bg;
      if (playingAyah == a.number) {
        bg = scheme.primary.withValues(alpha: 0.22);
      } else if (_selected == a.number) {
        bg = highlightColors[0].withValues(alpha: dark ? 0.35 : 0.6); // QuranFlash yellow
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

    final spans = <InlineSpan>[];
    var k = 0;
    for (final a in widget.ayahs) {
      final st = styleFor(a);
      void select() {
        setState(() => _selected = a.number);
        ref.read(lastReadProvider.notifier).set(a.number);
      }

      VoidCallback tapWord(int i) => () {
            select();
            if (widget.onWordTap != null) {
              widget.onWordTap!(a, i);
            } else {
              widget.onAyahTap(a);
            }
          };

      if (taj != null) {
        final words = taj.wordsOf(a.number);
        for (var i = 0; i < words.length; i++) {
          if (i > 0) spans.add(TextSpan(text: ' ', style: st));
          spans.addAll(tajweedWordSpans(words[i], st, dark: dark, recognizer: _rec(k++, tapWord(i))));
        }
      } else {
        final words = a.text.split(' ');
        for (var i = 0; i < words.length; i++) {
          if (i > 0) spans.add(TextSpan(text: ' ', style: st));
          spans.add(TextSpan(text: words[i], style: st, recognizer: _rec(k++, tapWord(i))));
        }
      }
      spans.add(TextSpan(
        text: ' ${ayahEndMarker(a.numberInSurah)} ',
        recognizer: _rec(k++, () {
          select();
          widget.onAyahTap(a);
        }),
        style: base.copyWith(fontFamily: ArabicStyles.nameFont, color: scheme.secondary),
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
    );
  }
}
