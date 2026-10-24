import 'package:flutter_test/flutter_test.dart';
import 'package:quran_plus/core/arabic_utils.dart';
import 'package:quran_plus/data/quran_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('arabic_utils', () {
    test('converts digits to Arabic-Indic', () {
      expect(toArabicDigits(286), '٢٨٦');
      expect(ayahEndMarker(7), '۝٧');
    });

    test('normalises diacritics and letter variants', () {
      expect(normalizeArabic('ٱلرَّحْمَٰنِ'), 'الرحمن');
      expect(normalizeArabic('بِسْمِ ٱللَّهِ'), 'بسم الله');
      expect(containsArabic('hello'), isFalse);
      expect(containsArabic('سلام'), isTrue);
    });
  });

  group('QuranRepository', () {
    late QuranRepository repo;
    setUpAll(() async => repo = await QuranRepository.load());

    test('has the complete Quran', () {
      expect(repo.surahs.length, 114);
      expect(repo.ayahs.length, 6236);
      expect(repo.transliteration.length, 6236);
      expect(repo.juzs.length, 30);
      expect(repo.surahs.fold<int>(0, (s, x) => s + x.numberOfAyahs), 6236);
    });

    test('surah slices line up with global numbering', () {
      for (final s in repo.surahs) {
        final ayahs = repo.ayahsOfSurah(s.number);
        expect(ayahs.length, s.numberOfAyahs);
        expect(ayahs.first.numberInSurah, 1);
        expect(ayahs.first.number, s.startAyah);
        expect(ayahs.last.numberInSurah, s.numberOfAyahs);
        expect(ayahs.every((a) => a.surah == s.number), isTrue);
      }
      expect(repo.ayahAt(2, 255).key, '2:255');
    });

    test('Bismillah is only inline for Al-Fatiha', () {
      expect(repo.ayahAt(1, 1).text, startsWith('بِسْمِ'));
      for (final s in repo.surahs.where((s) => s.hasBismillahHeader)) {
        expect(repo.ayahAt(s.number, 1).text, isNot(startsWith('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ')),
            reason: 'surah ${s.number}');
      }
    });

    test('search is diacritic-insensitive', () {
      final hits = repo.searchArabicAndTransliteration('الرحمن');
      expect(hits, contains(1)); // 1:1
      expect(repo.searchArabicAndTransliteration('Bismillaah'), contains(1));
      expect(repo.searchArabicAndTransliteration(''), isEmpty);
    });

    test('editions cover many languages', () {
      expect(repo.translationLanguages.length, greaterThan(40));
      expect(repo.edition('en.sahih')?.englishName, 'Saheeh International');
    });
  });
}
