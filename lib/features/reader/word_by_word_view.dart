import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/providers.dart';

/// Lays out an ayah as a right-to-left grid of words; each word shows its
/// Arabic form, Latin transliteration and meaning. Tap a word for details.
class WordByWordView extends StatelessWidget {
  const WordByWordView({
    super.key,
    required this.words,
    this.scale = 1,
    this.font = ArabicStyles.quranFont,
  });

  final List<QuranWord> words;
  final double scale;
  final String font;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      textDirection: TextDirection.rtl,
      spacing: 4,
      runSpacing: 6,
      children: [
        for (final w in words)
          if (w.isEndMarker)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                w.arabic,
                style: TextStyle(
                  fontFamily: ArabicStyles.nameFont,
                  fontSize: 24 * scale,
                  color: scheme.secondary,
                  height: 1.6,
                ),
              ),
            )
          else
            _WordTile(word: w, scale: scale, font: font),
      ],
    );
  }
}

class _WordTile extends StatelessWidget {
  const _WordTile({required this.word, required this.scale, required this.font});
  final QuranWord word;
  final double scale;
  final String font;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showWordDetails(context, word, font),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word.arabic,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: font,
                  fontSize: 24 * scale,
                  height: 1.7,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                word.transliteration,
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontStyle: FontStyle.italic,
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                word.translation,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11 * scale, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showWordDetails(BuildContext context, QuranWord word, String font) {
  final scheme = Theme.of(context).colorScheme;
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              word.arabic,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: font, fontSize: 48, height: 1.6, color: scheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              word.transliteration,
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              word.translation,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.wordN(word.position),
              style: TextStyle(fontSize: 12, color: scheme.outline),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Bottom sheet showing the word-by-word breakdown for a single ayah, with a
/// language switcher for the word meanings.
Future<void> showWordByWordSheet(BuildContext context, Ayah ayah) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) => _WordByWordSheet(ayah: ayah, controller: controller),
    ),
  );
}

class _WordByWordSheet extends ConsumerWidget {
  const _WordByWordSheet({required this.ayah, required this.controller});
  final Ayah ayah;
  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final repo = ref.quran;
    final surah = repo.surah(ayah.surah);
    final words = ref.watch(surahWordsProvider((surah: ayah.surah, lang: settings.wordLanguage)));
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.wordByWord,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(
                    '${surah.englishName} · ${context.l10n.ayahN(ayah.numberInSurah)}',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
            DropdownButton<String>(
              value: wordByWordLanguages.containsKey(settings.wordLanguage)
                  ? settings.wordLanguage
                  : 'en',
              underline: const SizedBox.shrink(),
              items: [
                for (final e in wordByWordLanguages.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) {
                if (v != null) ref.read(settingsProvider.notifier).setWordLanguage(v);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        words.when(
          data: (all) => WordByWordView(
            words: all[ayah.numberInSurah - 1],
            scale: settings.arabicScale,
            font: settings.arabicFont,
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.cloud_off, color: scheme.error, size: 36),
                const SizedBox(height: 8),
                Text(
                  '${context.l10n.wordByWordNeedsInternet}\n$e',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => ref.invalidate(
                    surahWordsProvider((surah: ayah.surah, lang: settings.wordLanguage)),
                  ),
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          repo.transliterationOf(ayah.number),
          style: TextStyle(fontStyle: FontStyle.italic, color: scheme.primary, height: 1.5),
        ),
      ],
    );
  }
}
