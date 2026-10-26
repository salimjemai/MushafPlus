import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_plus/core/arabic_utils.dart';
import 'package:mushaf_plus/data/quran_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late QuranRepository repo;
  setUpAll(() async => repo = await QuranRepository.load());

  test('search keys drop alifs and diacritics', () {
    expect(arabicSearchKey('ٱلْإِنسَٰنُ'), arabicSearchKey('الانسان'));
    expect(arabicSearchKey('ٱلرَّحْمَٰنِ'), arabicSearchKey('الرحمن'));
    expect(arabicSearchKey('إنسان'), 'نسن');
    expect(arabicSearchKey('وَنِسَآءَنَا'), isNot(contains('نسن')));
    expect(transliterationSearchKey('Qutilal-insanu'), 'qutilalinsanu');
    expect(transliterationSearchKey('insaan'), 'insan');
  });

  test('typed Arabic finds Uthmani ayahs', () {
    final abasa17 = repo.ayahAt(80, 17).number;
    expect(repo.searchArabicAndTransliteration('الانسان'), contains(abasa17));
    expect(repo.searchArabicAndTransliteration('إنسان'), contains(abasa17));
    expect(repo.searchArabicAndTransliteration('الإنسان'), contains(abasa17));
    expect(repo.searchArabicAndTransliteration('الرحمن الرحيم'), contains(1));
    // Arabic and transliteration searches for the same word agree.
    final ar = repo.searchArabicAndTransliteration('انسان');
    final en = repo.searchArabicAndTransliteration('insan');
    expect(ar.length, greaterThan(50));
    expect(en.length, greaterThan(50));
    expect((ar.length - en.length).abs(), lessThan(5));
    expect(ar, isNot(contains(repo.ayahAt(3, 61).number)));
  });
}
