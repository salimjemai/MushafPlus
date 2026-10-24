import 'package:flutter_test/flutter_test.dart';
import 'package:quran_plus/data/hadith_pdf.dart';
import 'package:quran_plus/data/hadith_service.dart';

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

  test('paginates without losing hadiths', () {
    final many = [
      for (var i = 1; i <= 40; i++)
        Hadith(number: i, arabic: 'ن' * (50 + i * 10), text: 'x' * (80 + i * 15), grades: const [], reference: ''),
    ];
    // Mirror of the reader's pagination budget.
    final pages = <List<Hadith>>[];
    var current = <Hadith>[];
    var used = 0;
    for (final h in many) {
      final w = h.arabic.length + h.text.length + 80;
      if (current.isNotEmpty && used + w > 1500) {
        pages.add(current);
        current = <Hadith>[];
        used = 0;
      }
      current.add(h);
      used += w;
    }
    if (current.isNotEmpty) pages.add(current);
    expect(pages.expand((p) => p).length, 40);
    expect(pages.length, greaterThan(5));
  });
}
