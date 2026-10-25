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
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.savedForOffline(book.name))));
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
    await Downloads.saveBytes(bytes, name, mimeType: 'application/pdf');
  } catch (e) {
    if (!context.mounted) return;
    if (!cancelled) Navigator.of(context).pop();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.pdfFailed('$e'))));
  }
}
