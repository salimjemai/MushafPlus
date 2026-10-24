import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/audio_controller.dart';
import '../../state/providers.dart';
import 'tafsir_sheet.dart';
import 'word_by_word_view.dart';

/// Builds a shareable plain-text version of the ayah using whatever
/// translations are already loaded.
String composeAyahText(WidgetRef ref, Ayah ayah) {
  final repo = ref.quran;
  final settings = ref.read(settingsProvider);
  final surah = repo.surah(ayah.surah);
  final buf = StringBuffer()
    ..writeln(ayah.text)
    ..writeln();
  if (settings.showTransliteration) {
    buf
      ..writeln(repo.transliterationOf(ayah.number))
      ..writeln();
  }
  for (final id in settings.translations) {
    final v = ref.read(surahTranslationProvider((surah: ayah.surah, edition: id)));
    final list = v.asData?.value;
    if (list != null && ayah.numberInSurah - 1 < list.length) {
      final name = repo.edition(id)?.englishName ?? id;
      buf
        ..writeln(list[ayah.numberInSurah - 1])
        ..writeln('— $name')
        ..writeln();
    }
  }
  buf.write('Quran ${ayah.key} · ${surah.englishName}');
  return buf.toString();
}

Future<void> showAyahActions(BuildContext context, WidgetRef ref, Ayah ayah) {
  final repo = ref.quran;
  final surah = repo.surah(ayah.surah);

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          final bookmarked = ref.watch(
            bookmarksProvider.select((l) => l.any((b) => b.ayahNumber == ayah.number)),
          );
          final settings = ref.watch(settingsProvider);
          final scheme = Theme.of(context).colorScheme;
          final translation = ref.watch(surahTranslationProvider(
            (surah: ayah.surah, edition: settings.translations.firstOrNull ?? 'en.sahih'),
          ));

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${surah.englishName} · Ayah ${ayah.numberInSurah}',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Text(
                  ayah.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: ArabicStyles.ayah(context, scale: 0.85, font: settings.arabicFont),
                ),
                const SizedBox(height: 6),
                Text(
                  repo.transliterationOf(ayah.number),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontStyle: FontStyle.italic, color: scheme.primary),
                ),
                if (translation.asData != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    translation.asData!.value[ayah.numberInSurah - 1],
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(height: 1.5),
                  ),
                ],
                const Divider(height: 24),
                ListTile(
                  leading: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: bookmarked ? scheme.secondary : null),
                  title: Text(bookmarked ? 'Remove bookmark' : 'Bookmark this ayah'),
                  onTap: () {
                    ref.read(bookmarksProvider.notifier).toggle(ayah.number);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.segment),
                  title: const Text('Word by word'),
                  subtitle: const Text('Transliteration and meaning of every word'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    showWordByWordSheet(context, ayah);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.auto_stories_outlined),
                  title: const Text('Tafsir'),
                  subtitle: const Text('Commentary from Ibn Kathir and others'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    showTafsirSheet(context, ayah);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: const Text('Play recitation from here'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ref.read(audioProvider.notifier).playAyah(ayah.number);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy_outlined),
                  title: const Text('Copy'),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: composeAyahText(ref, ayah)));
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.maybeOf(context)
                          ?.showSnackBar(const SnackBar(content: Text('Ayah copied')));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.ios_share),
                  title: const Text('Share'),
                  onTap: () {
                    final text = composeAyahText(ref, ayah);
                    Navigator.of(sheetContext).pop();
                    Share.share(text, subject: 'Quran ${ayah.key}');
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
