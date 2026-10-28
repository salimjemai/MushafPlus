import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_plus/data/mushaf_pages.dart';
import 'package:mushaf_plus/data/quran_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuranRepository repo;
  late MushafPages pages;
  setUpAll(() async {
    repo = await QuranRepository.load();
    pages = await MushafPages.load(basmala: repo.ayah(1).text);
  });

  test('every page has a layout with the printed number of lines', () {
    expect(pages.count, 604);
    for (var p = 1; p <= 604; p++) {
      final layout = pages.page(p)!;
      expect(layout.slots, p <= 2 ? 8 : 15);
      expect(layout.lines.length, inInclusiveRange(layout.slots - 1, layout.slots), reason: 'page $p');
      expect(layout.lines.whereType<TextLine>(), isNotEmpty, reason: 'page $p');
    }
  });

  test('pages follow each other word by word', () {
    for (var p = 1; p < 604; p++) {
      final end = pages.page(p)!.end;
      final next = pages.page(p + 1)!.lines.whereType<TextLine>().first.start;
      final words = pages.visualWordsOf(repo.ayah(end.ayah)).length;
      final expected = end.word < words ? PageToken(end.ayah, end.word + 1) : PageToken(end.ayah + 1, 0);
      expect(next, expected, reason: 'page $p ends at $end');
    }
    expect(pages.page(604)!.end, PageToken(6236, pages.visualWordsOf(repo.ayah(6236)).length));
  });

  test('opening pages carry the header, basmala and the known first lines', () {
    final fatiha = pages.page(1)!;
    expect(fatiha.lines.first, isA<HeaderLine>().having((h) => h.surah, 'surah', 1));
    expect(fatiha.lines[1], isA<TextLine>().having((t) => t.start, 'start', const PageToken(1, 0)));
    final baqarah = pages.page(2)!;
    expect(baqarah.lines[1], isA<BasmalaLine>());
    expect(baqarah.lines[2], isA<TextLine>().having((t) => t.start, 'start', const PageToken(8, 0)));
    // At-Tawbah has no basmala.
    final tawbah = pages.page(187)!;
    expect(tawbah.lines[0], isA<HeaderLine>().having((h) => h.surah, 'surah', 9));
    expect(tawbah.lines[1], isA<TextLine>());
  });

  test('visual words merge pause marks and the hizb star like the print', () {
    final a = repo.ayahAt(2, 2); // ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًۭى لِّلْمُتَّقِينَ
    final words = pages.visualWordsOf(a);
    expect(words.length, 7);
    expect(words[3].text, 'رَيْبَ ۛ');
    expect(words[3].firstToken, 3);
    expect(words[3].lastToken, 4);
    expect(words[6].firstToken, 8);

    final hizb = repo.ayahAt(2, 26);
    expect(hizb.text.startsWith('۞ '), isTrue);
    expect(pages.visualWordsOf(hizb).first.text, '۞ ${hizb.text.split(' ')[1]}');
    expect(pages.visualWordsOf(hizb).first.firstToken, 0);
    expect(pages.visualWordsOf(hizb).first.lastToken, 1);

    // Tanzil writes the basmala inside 95:1; the Mushaf prints it on its own line.
    final tin = repo.ayahAt(95, 1);
    expect(pages.visualWordsOf(tin).map((w) => w.text).toList(), tin.text.split(' ').sublist(4));
    expect(pages.visualWordsOf(tin).first.firstToken, 4);
    expect(pages.visualWordsOf(repo.ayahAt(1, 1)).length, 4);
    final yasin = repo.ayahAt(37, 130).text.split(' '); // سَلَٰمٌ عَلَىٰٓ إِلْ يَاسِينَ
    expect(pages.visualWordsOf(repo.ayahAt(37, 130)).map((w) => w.text).toList(),
        [yasin[0], yasin[1], '${yasin[2]} ${yasin[3]}']);
  });
}
