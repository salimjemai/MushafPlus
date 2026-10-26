/// Core data models for Mushaf+.
library;

class Surah {
  final int number;
  final String name; // Arabic name
  final String englishName;
  final String englishNameTranslation;
  final String revelationType; // Meccan | Medinan
  final int numberOfAyahs;
  final int startPage;
  final int startJuz;
  final int startAyah; // global ayah number of ayah 1

  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.startPage,
    required this.startJuz,
    required this.startAyah,
  });

  bool get isMeccan => revelationType == 'Meccan';

  /// Surah 1 (Bismillah is its first ayah) and 9 (no Bismillah) have no header.
  bool get hasBismillahHeader => number != 1 && number != 9;

  factory Surah.fromJson(Map<String, dynamic> j) => Surah(
        number: j['number'] as int,
        name: j['name'] as String,
        englishName: j['englishName'] as String,
        englishNameTranslation: j['englishNameTranslation'] as String,
        revelationType: j['revelationType'] as String,
        numberOfAyahs: j['numberOfAyahs'] as int,
        startPage: j['startPage'] as int,
        startJuz: j['startJuz'] as int,
        startAyah: j['startAyah'] as int,
      );
}

class Ayah {
  final int number; // global 1..6236
  final int surah;
  final int numberInSurah;
  final String text; // Uthmani Arabic
  final int juz;
  final int page;
  final int hizbQuarter;
  final bool sajda;

  const Ayah({
    required this.number,
    required this.surah,
    required this.numberInSurah,
    required this.text,
    required this.juz,
    required this.page,
    required this.hizbQuarter,
    this.sajda = false,
  });

  String get key => '$surah:$numberInSurah';

  factory Ayah.fromJson(Map<String, dynamic> j) => Ayah(
        number: j['n'] as int,
        surah: j['s'] as int,
        numberInSurah: j['a'] as int,
        text: j['t'] as String,
        juz: j['j'] as int,
        page: j['p'] as int,
        hizbQuarter: j['h'] as int,
        sajda: j['sajda'] == true,
      );
}

class Juz {
  final int number;
  final int startAyah; // global
  final int endAyah; // global
  final int startSurah;
  final int startAyahInSurah;
  const Juz({
    required this.number,
    required this.startAyah,
    required this.endAyah,
    required this.startSurah,
    required this.startAyahInSurah,
  });
}

/// A translation / transliteration / tafsir edition (alquran.cloud identifiers).
class Edition {
  final String identifier;
  final String language; // ISO 639-1
  final String name; // native name
  final String englishName;
  final String type; // translation | transliteration | tafsir
  final String direction; // ltr | rtl

  const Edition({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.type,
    required this.direction,
  });

  bool get isRtl => direction == 'rtl';

  factory Edition.fromJson(Map<String, dynamic> j) => Edition(
        identifier: j['identifier'] as String,
        language: j['language'] as String,
        name: j['name'] as String,
        englishName: j['englishName'] as String,
        type: j['type'] as String,
        direction: (j['direction'] as String?) ?? 'ltr',
      );
}

/// A single word of an ayah with transliteration and meaning (quran.com data).
class QuranWord {
  final int position;
  final String arabic;
  final String transliteration;
  final String translation;
  final bool isEndMarker; // the ayah-number glyph at the end

  const QuranWord({
    required this.position,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.isEndMarker,
  });

  Map<String, dynamic> toJson() => {
        'p': position,
        'a': arabic,
        'tl': transliteration,
        'tr': translation,
        if (isEndMarker) 'e': 1,
      };

  factory QuranWord.fromJson(Map<dynamic, dynamic> j) => QuranWord(
        position: j['p'] as int,
        arabic: j['a'] as String,
        transliteration: (j['tl'] as String?) ?? '',
        translation: (j['tr'] as String?) ?? '',
        isEndMarker: j['e'] == 1,
      );
}

class Bookmark {
  final int ayahNumber; // global
  final DateTime createdAt;
  const Bookmark({required this.ayahNumber, required this.createdAt});

  Map<String, dynamic> toJson() => {
        'n': ayahNumber,
        't': createdAt.millisecondsSinceEpoch,
      };

  factory Bookmark.fromJson(Map<dynamic, dynamic> j) => Bookmark(
        ayahNumber: j['n'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(j['t'] as int),
      );
}

class LastRead {
  final int ayahNumber; // global
  final DateTime at;
  const LastRead({required this.ayahNumber, required this.at});
}
