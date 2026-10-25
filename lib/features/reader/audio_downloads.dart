import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../data/downloads.dart';
import '../../data/models.dart';
import '../../data/reciters.dart';
import '../../state/providers.dart';

/// Downloads one ayah's recording: saved for offline playback and handed to
/// the user (share sheet on mobile, Downloads folder on desktop, browser
/// download on web).
Future<void> downloadAyahAudio(BuildContext context, WidgetRef ref, Ayah ayah) async {
  final l = context.l10n;
  final reciter = reciterById(ref.read(settingsProvider).reciter);
  final url = reciter.ayahUrl(ayah.surah, ayah.numberInSurah);
  final name = 'quran-${ayah.surah.toString().padLeft(3, '0')}-${ayah.numberInSurah.toString().padLeft(3, '0')}-${reciter.id.split('/').last}.mp3';
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    if (Downloads.supportsCache) {
      await Downloads.cacheAyah(reciter.id, ayah.surah, ayah.numberInSurah, url);
    }
    await Downloads.saveUrl(url, name);
    messenger?.showSnackBar(SnackBar(content: Text(l.downloaded('${ayah.key} · ${reciter.name}'))));
  } catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(l.downloadFailed('$e'))));
  }
}

/// Caches every ayah of [surah] for the current reciter so the recitation
/// plays offline. Native platforms only; the web has no file cache.
Future<void> downloadSurahAudio(BuildContext context, WidgetRef ref, Surah surah) async {
  final l = context.l10n;
  if (!Downloads.supportsCache) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.offlineAudioNativeOnly)));
    return;
  }
  final reciter = reciterById(ref.read(settingsProvider).reciter);
  final progress = ValueNotifier<(int, int)>((0, surah.numberOfAyahs));
  var cancelled = false;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: Text(l.downloadSurahAudio),
      content: ValueListenableBuilder<(int, int)>(
        valueListenable: progress,
        builder: (_, v, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: v.$2 == 0 ? 0 : v.$1 / v.$2),
            const SizedBox(height: 12),
            Text('${surah.englishName} · ${reciter.name}\n${v.$1} / ${v.$2}', textAlign: TextAlign.center),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            cancelled = true;
            Navigator.of(dialogContext).pop();
          },
          child: Text(l.cancel),
        ),
      ],
    ),
  );

  var failed = 0;
  for (var a = 1; a <= surah.numberOfAyahs; a++) {
    if (cancelled) return;
    try {
      await Downloads.cacheAyah(reciter.id, surah.number, a, reciter.ayahUrl(surah.number, a));
    } catch (_) {
      failed++;
    }
    progress.value = (a, surah.numberOfAyahs);
  }
  if (!context.mounted) return;
  Navigator.of(context).pop();
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
    content: Text(failed == 0 ? l.surahAudioSaved(surah.englishName) : l.downloadDoneWithFailures(failed)),
  ));
}
