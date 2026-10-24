import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/audio_controller.dart';
import '../../state/providers.dart';
import '../../widgets/surah_number_badge.dart';
import 'ayah_actions.dart';
import 'tafsir_sheet.dart';
import 'word_by_word_view.dart';

/// One selected translation edition and its (async) text for the current surah.
class TranslationSource {
  const TranslationSource({required this.id, required this.edition, required this.value});
  final String id;
  final Edition? edition;
  final AsyncValue<List<String>> value;
}

class AyahCard extends ConsumerWidget {
  const AyahCard({
    super.key,
    required this.ayah,
    required this.transliteration,
    required this.translations,
    this.words,
    this.highlighted = false,
  });

  final Ayah ayah;
  final String transliteration;
  final List<TranslationSource> translations;
  final AsyncValue<List<List<QuranWord>>>? words;
  final bool highlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final settings = ref.watch(settingsProvider);
    final bookmarked =
        ref.watch(bookmarksProvider.select((list) => list.any((b) => b.ayahNumber == ayah.number)));
    final audio = ref.watch(audioProvider.select(
      (a) => (current: a.ayah == ayah.number, playing: a.ayah == ayah.number && a.playing, loading: a.ayah == ayah.number && a.loading),
    ));
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: highlighted
            ? [BoxShadow(color: scheme.secondary.withValues(alpha: 0.45), blurRadius: 18, spreadRadius: 1)]
            : null,
      ),
      child: Card(
        color: audio.current ? scheme.primary.withValues(alpha: 0.08) : null,
        shape: audio.current
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: scheme.primary, width: 1.5),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- toolbar -------------------------------------------------
              Row(
                children: [
                  SurahNumberBadge(number: ayah.numberInSurah, size: 36),
                  const SizedBox(width: 8),
                  if (ayah.sajda)
                    Tooltip(
                      message: l.sajdahAyah,
                      child: Icon(Icons.self_improvement, size: 18, color: scheme.secondary),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: audio.playing ? l.pause : l.playFromThisAyah,
                    visualDensity: VisualDensity.compact,
                    icon: audio.loading
                        ? const SizedBox(
                            width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(
                            audio.playing ? Icons.pause_circle : Icons.play_circle_outline,
                            size: 22,
                            color: audio.current ? scheme.primary : null,
                          ),
                    onPressed: () {
                      final ctrl = ref.read(audioProvider.notifier);
                      if (audio.current) {
                        ctrl.toggle();
                      } else {
                        ctrl.playAyah(ayah.number);
                      }
                    },
                  ),
                  IconButton(
                    tooltip: l.wordByWord,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.segment, size: 20),
                    onPressed: () => showWordByWordSheet(context, ayah),
                  ),
                  IconButton(
                    tooltip: l.tafsir,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.auto_stories_outlined, size: 20),
                    onPressed: () => showTafsirSheet(context, ayah),
                  ),
                  IconButton(
                    tooltip: bookmarked ? l.removeBookmark : l.bookmark,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 20,
                      color: bookmarked ? scheme.secondary : null,
                    ),
                    onPressed: () => ref.read(bookmarksProvider.notifier).toggle(ayah.number),
                  ),
                  IconButton(
                    tooltip: l.more,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.more_horiz, size: 20),
                    onPressed: () => showAyahActions(context, ref, ayah),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ---- Arabic ----------------------------------------------------
              _ArabicBlock(ayah: ayah, words: words, settings: settings),

              // ---- transliteration ------------------------------------------
              if (settings.showTransliteration) ...[
                const SizedBox(height: 10),
                Text(
                  transliteration,
                  style: TextStyle(
                    fontSize: 14.5 * settings.translationScale,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: scheme.primary,
                  ),
                ),
              ],

              // ---- translations ---------------------------------------------
              for (final t in translations) ...[
                const SizedBox(height: 12),
                _TranslationBlock(
                  source: t,
                  index: ayah.numberInSurah - 1,
                  showLabel: translations.length > 1,
                  scale: settings.translationScale,
                  surah: ayah.surah,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ArabicBlock extends StatelessWidget {
  const _ArabicBlock({required this.ayah, required this.words, required this.settings});
  final Ayah ayah;
  final AsyncValue<List<List<QuranWord>>>? words;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final plain = Text(
      ayah.text,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: ArabicStyles.ayah(context, scale: settings.arabicScale, font: settings.arabicFont),
    );
    final w = words;
    if (w == null) return plain;
    return w.when(
      data: (all) {
        final idx = ayah.numberInSurah - 1;
        if (idx >= all.length) return plain;
        return WordByWordView(
          words: all[idx],
          scale: settings.arabicScale,
          font: settings.arabicFont,
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          plain,
          const SizedBox(height: 6),
          const LinearProgressIndicator(minHeight: 2),
        ],
      ),
      error: (e, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          plain,
          const SizedBox(height: 4),
          Text(
            context.l10n.wordByWordOffline('$e'),
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }
}

class _TranslationBlock extends ConsumerWidget {
  const _TranslationBlock({
    required this.source,
    required this.index,
    required this.showLabel,
    required this.scale,
    required this.surah,
  });

  final TranslationSource source;
  final int index;
  final bool showLabel;
  final double scale;
  final int surah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final rtl = source.edition?.isRtl ?? false;
    final label = source.edition?.englishName ?? source.id;

    Widget body = source.value.when(
      data: (list) => Text(
        index < list.length ? list[index] : '',
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        textAlign: rtl ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: (rtl ? 18 : 15.5) * scale,
          height: rtl ? 1.9 : 1.55,
          fontFamily: rtl ? ArabicStyles.nameFont : null,
          color: scheme.onSurface,
        ),
      ),
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Skeleton(width: double.infinity),
          const SizedBox(height: 6),
          _Skeleton(width: 220),
        ],
      ),
      error: (e, _) => Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: scheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.couldNotLoad(label),
              style: TextStyle(color: scheme.error, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () =>
                ref.invalidate(surahTranslationProvider((surah: surah, edition: source.id))),
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );

    if (!showLabel) return body;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        body,
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
