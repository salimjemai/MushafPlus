
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'hadith_service.dart';

/// Builds a printable PDF of one or more chapters of a hadith collection,
/// with Arabic text shaped and laid out right-to-left and the translation
/// beneath each hadith.
class HadithPdf {
  HadithPdf._();

  static pw.Font? _amiri;
  static pw.Font? _amiriBold;

  static Future<void> _loadFonts() async {
    if (_amiri != null) return;
    final r = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final b = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
    _amiri = pw.Font.ttf(r);
    _amiriBold = pw.Font.ttf(b);
  }

  /// [chapters] is an ordered list of (section, hadiths). [onProgress] is
  /// called with 0..1 as chapters are laid out.
  static Future<Uint8List> build({
    required HadithBook book,
    required List<(HadithSection, List<Hadith>)> chapters,
    required String lang,
    void Function(double progress)? onProgress,
  }) async {
    await _loadFonts();
    final rtl = hadithLanguageIsRtl(lang);
    final gold = PdfColor.fromHex('#9C7A1F');
    final ink = PdfColor.fromHex('#222222');
    final grey = PdfColor.fromHex('#777777');

    final doc = pw.Document(
      title: book.name,
      author: 'Mushaf+',
      theme: pw.ThemeData.withFont(base: _amiri!, bold: _amiriBold!),
    );

    // Title page.
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(color: gold, width: 2)),
          margin: const pw.EdgeInsets.all(24),
          child: pw.Container(
            margin: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: gold, width: 0.6)),
            child: pw.Center(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(book.arabic,
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(font: _amiriBold, fontSize: 40, color: ink)),
                  pw.SizedBox(height: 16),
                  pw.Text(book.name, style: pw.TextStyle(font: _amiriBold, fontSize: 24, color: ink)),
                  pw.SizedBox(height: 8),
                  pw.Text('${book.hadithCount} hadiths · ${book.sections.length} chapters',
                      style: pw.TextStyle(fontSize: 12, color: grey)),
                  pw.SizedBox(height: 40),
                  pw.Text('Mushaf+', style: pw.TextStyle(fontSize: 11, color: gold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Table of contents when exporting more than one chapter.
    if (chapters.length > 1) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => [
            pw.Text('Contents', style: pw.TextStyle(font: _amiriBold, fontSize: 20, color: ink)),
            pw.SizedBox(height: 10),
            for (final (s, _) in chapters)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  children: [
                    pw.SizedBox(width: 36, child: pw.Text('${s.number}', style: pw.TextStyle(color: gold))),
                    pw.Expanded(child: pw.Text(s.titleFor(lang), textDirection: lang == 'ara' ? pw.TextDirection.rtl : null)),
                    if (s.count > 0) pw.Text('${s.first}–${s.last}', style: pw.TextStyle(color: grey, fontSize: 10)),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    var done = 0;
    for (final (section, hadiths) in chapters) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 36),
          header: (ctx) => pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 6),
            decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: gold, width: 0.6))),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('${section.number}. ${section.titleFor(lang)}', style: pw.TextStyle(fontSize: 9, color: grey)),
                pw.Text(book.name, style: pw.TextStyle(fontSize: 9, color: grey)),
              ],
            ),
          ),
          footer: (ctx) => pw.Center(
            child: pw.Text('${ctx.pageNumber}', style: pw.TextStyle(fontSize: 9, color: grey)),
          ),
          build: (ctx) => [
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 6, bottom: 10),
              child: pw.Text('${section.number}. ${section.titleFor(lang)}',
                  style: pw.TextStyle(font: _amiriBold, fontSize: 16, color: ink)),
            ),
            for (final h in hadiths) ...[
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 10),
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#DDDDDD'), width: 0.4)),
                ),
                margin: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Row(
                      children: [
                        pw.Text('#${h.number}', style: pw.TextStyle(font: _amiriBold, fontSize: 10, color: gold)),
                        if (h.grades.isNotEmpty) ...[
                          pw.SizedBox(width: 8),
                          pw.Text(h.grades.take(2).join(', '), style: pw.TextStyle(fontSize: 8, color: grey)),
                        ],
                      ],
                    ),
                    if (h.arabic.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 4),
                        child: pw.Text(
                          h.arabic,
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontSize: 13, lineSpacing: 5, color: ink),
                        ),
                      ),
                    if (h.text.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 6),
                        child: pw.Text(
                          h.text,
                          textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
                          textAlign: rtl ? pw.TextAlign.right : pw.TextAlign.left,
                          style: pw.TextStyle(fontSize: rtl ? 12 : 10.5, lineSpacing: 3, color: ink),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
      done++;
      onProgress?.call(done / chapters.length);
      // Let the UI breathe between chapters.
      await Future<void>.delayed(Duration.zero);
    }

    return doc.save();
  }
}
