import 'package:flutter_test/flutter_test.dart';
import 'package:quran_plus/core/arabic_utils.dart';
import 'package:quran_plus/data/quran_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late QuranRepository repo;
  setUpAll(() async => repo = await QuranRepository.load());

  test('search keys drop alifs and diacritics', () {
    expect(arabicSearchKey('ٱلْإِنسَٰنُ'), arabicSearchKey('الانسان'));
    expect(arabicSearchKey('ٱلرَّحْمَٰنِ'), arabicSearchKey('الرحمن'));
    expect(arabicSearchKey('إنسان'), 'نسن');
  });

  test('typed Arabic finds Uthmani ayahs', () {
    final abasa17 = repo.ayahAt(80, 17).number;
    expect(repo.searchArabicAndTransliteration('الانسان'), contains(abasa17));
    expect(repo.searchArabicAndTransliteration('إنسان'), contains(abasa17));
    expect(repo.searchArabicAndTransliteration('الإنسان'), contains(abasa17));
    expect(repo.searchArabicAndTransliteration('الرحمن الرحيم'), contains(1));
    expect(repo.searchArabicAndTransliteration('insan'), isNotEmpty);
  });
}
