import 'package:flutter_test/flutter_test.dart';
import 'package:quran_plus/data/hadith_pdf.dart';
import 'package:quran_plus/data/hadith_service.dart';
import 'package:quran_plus/features/hadith/hadith_book_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds a PDF with shaped Arabic and translation', () async {
    const book = HadithBook(
      id: 'test',
      name: 'Test Collection',
      arabic: 'كتاب الاختبار',
      languages: ['ara', 'eng'],
      hadithCount: 2,
      sections: [HadithSection(number: 1, name: 'Revelation', first: 1, last: 2)],
    );
    const hadiths = [
      Hadith(
        number: 1,
        arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
        text: 'Actions are judged by intentions, and every person will get what they intended.',
        grades: ['Sahih'],
        reference: 'Book 1, Hadith 1',
      ),
      Hadith(number: 2, arabic: 'الدِّينُ النَّصِيحَةُ', text: 'Religion is sincerity.', grades: [], reference: ''),
    ];
    final progress = <double>[];
    final bytes = await HadithPdf.build(
      book: book,
      chapters: [(book.sections.first, hadiths)],
      lang: 'eng',
      onProgress: progress.add,
    );
    expect(bytes.length, greaterThan(5000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(progress.last, 1.0);
  });

  test('paginates evenly and keeps every word', () {
    String words(int n, String w) => List.filled(n, w).join(' ');
    final many = [
      // One very long hadith, then many short ones.
      Hadith(number: 1, arabic: words(900, 'كلمة'), text: words(1200, 'word'), grades: const [], reference: ''),
      for (var i = 2; i <= 30; i++)
        Hadith(number: i, arabic: words(12 + i, 'كلمة'), text: words(20 + i, 'word'), grades: const [], reference: ''),
    ];
    final pages = paginateHadiths(many);
    // The long hadith spans several pages instead of being squeezed into one.
    expect(pages.where((p) => p.any((b) => b.hadith.number == 1)).length, greaterThan(3));
    // Every hadith's text survives, in order.
    for (final h in many) {
      final blocks = pages.expand((p) => p).where((b) => identical(b.hadith, h)).toList();
      expect(blocks.first.continued, isFalse);
      expect(blocks.last.continues, isFalse);
      expect(blocks.map((b) => b.arabic).where((s) => s.isNotEmpty).join(' ').split(' ').length, h.arabic.split(' ').length);
      expect(blocks.map((b) => b.text).where((s) => s.isNotEmpty).join(' ').split(' ').length, h.text.split(' ').length);
    }
    // No page is wildly over budget.
    for (final p in pages) {
      expect(p.fold<double>(0, (s, b) => s + b.weight), lessThan(4000 * 1.6));
    }
  });
}
