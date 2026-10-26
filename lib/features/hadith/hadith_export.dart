import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../data/downloads.dart';
import '../../data/hadith_pdf.dart';
import '../../data/hadith_service.dart';
import '../../state/providers.dart';

/// Runs a cancellable progress dialog over the chapters of [book], fetching
/// each one (into the offline cache) and optionally rendering a PDF.
Future<void> exportHadith(
  BuildContext context,
  WidgetRef ref,
  HadithBook book, {
  HadithSection? chapterOnly,
  required bool pdf,
}) async {
  final l = context.l10n;
  final lang = ref.read(settingsProvider).hadithLanguage;
  final service = ref.read(hadithServiceProvider);
  final sections = chapterOnly != null ? [chapterOnly] : book.sections;
  final progress = ValueNotifier<(String, double?)>((l.preparingPdf(0, sections.length), 0));
  var cancelled = false;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: Text(pdf ? l.downloadPdf : l.downloadForOffline),
      content: ValueListenableBuilder<(String, double?)>(
        valueListenable: progress,
        builder: (_, v, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: v.$2),
            const SizedBox(height: 12),
            Text(v.$1),
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

  try {
    final chapters = <(HadithSection, List<Hadith>)>[];
    for (var i = 0; i < sections.length; i++) {
      if (cancelled) return;
      final s = sections[i];
      chapters.add((s, await service.section(book.id, s.number, lang)));
      progress.value = (l.preparingPdf(i + 1, sections.length), (i + 1) / sections.length * (pdf ? 0.5 : 1));
    }
    if (cancelled) return;
    if (!pdf) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          icon: const Icon(Icons.offline_pin_outlined),
          title: Text(l.savedForOffline(book.name)),
          content: Text(l.offlineSavedBody),
          actions: [FilledButton(onPressed: () => Navigator.of(c).pop(), child: Text(l.open))],
        ),
      );
      return;
    }
    progress.value = (l.renderingPdf, null);
    final bytes = await HadithPdf.build(
      book: book,
      chapters: chapters,
      lang: lang,
      onProgress: (p) => progress.value = (l.renderingPdf, 0.5 + p * 0.5),
    );
    if (cancelled || !context.mounted) return;
    Navigator.of(context).pop();
    final name = chapterOnly == null ? '${book.id}.pdf' : '${book.id}-chapter-${chapterOnly.number}.pdf';
    final size = bytes.length >= 1024 * 1024
        ? '${(bytes.length / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(bytes.length / 1024).round()} KB';
    // Browsers (Safari above all) only honour a download started by a tap,
    // so the save happens from a button rather than at the end of the job.
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.picture_as_pdf_outlined),
        title: Text(l.pdfReady(size)),
        content: Text('${book.name}\n$name'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(), child: Text(l.cancel)),
          OutlinedButton.icon(
            onPressed: () => Downloads.openBytes(bytes, name, mimeType: 'application/pdf'),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(l.openPdf),
          ),
          FilledButton.icon(
            onPressed: () {
              Downloads.saveBytes(bytes, name, mimeType: 'application/pdf');
              Navigator.of(c).pop();
            },
            icon: const Icon(Icons.download, size: 18),
            label: Text(l.savePdf),
          ),
        ],
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    if (!cancelled) Navigator.of(context).pop();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.pdfFailed('$e'))));
  }
}
