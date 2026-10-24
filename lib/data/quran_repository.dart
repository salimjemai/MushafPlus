import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/arabic_utils.dart';
import 'models.dart';

/// Holds the complete Quran (Arabic text, surah metadata, English
/// transliteration and the list of available editions). Everything here is
/// bundled with the app so reading works fully offline.
class QuranRepository {
  QuranRepository._({
    required this.surahs,
    required this.ayahs,
    required this.transliteration,
    required this.editions,
    required this.juzs,
  });

  final List<Surah> surahs;
  final List<Ayah> ayahs; // index = global number - 1
  final List<String> transliteration; // index = global number - 1
  final List<Edition> editions;
  final List<Juz> juzs;

  static const totalAyahs = 6236;

  static Future<QuranRepository> load() async {
    final raw = await Future.wait([
      rootBundle.loadString('assets/data/surahs.json'),
      rootBundle.loadString('assets/data/quran_uthmani.json'),
      rootBundle.loadString('assets/data/transliteration_en.json'),
      rootBundle.loadString('assets/data/editions.json'),
    ]);
    final parsed = await compute(_parse, raw);
    return parsed;
  }

  static QuranRepository _parse(List<String> raw) {
    final surahs = (jsonDecode(raw[0]) as List)
        .map((e) => Surah.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    final ayahs = (jsonDecode(raw[1]) as List)
        .map((e) => Ayah.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    final translit =
        (jsonDecode(raw[2]) as List).cast<String>().toList(growable: false);
    final editions = (jsonDecode(raw[3]) as List)
        .map((e) => Edition.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    // Derive the 30 juz boundaries from the ayah metadata.
    final juzs = <Juz>[];
    int? current;
    int start = 1;
    for (final a in ayahs) {
      if (a.juz != current) {
        if (current != null) {
          final s = ayahs[start - 1];
          juzs.add(Juz(
            number: current,
            startAyah: start,
            endAyah: a.number - 1,
            startSurah: s.surah,
            startAyahInSurah: s.numberInSurah,
          ));
        }
        current = a.juz;
        start = a.number;
      }
    }
    final s = ayahs[start - 1];
    juzs.add(Juz(
      number: current!,
      startAyah: start,
      endAyah: ayahs.length,
      startSurah: s.surah,
      startAyahInSurah: s.numberInSurah,
    ));

    return QuranRepository._(
      surahs: surahs,
      ayahs: ayahs,
      transliteration: translit,
      editions: editions,
      juzs: juzs,
    );
  }

  Surah surah(int number) => surahs[number - 1];

  Ayah ayah(int globalNumber) => ayahs[globalNumber - 1];

  Ayah ayahAt(int surah, int numberInSurah) =>
      ayahs[this.surah(surah).startAyah - 1 + numberInSurah - 1];

  List<Ayah> ayahsOfSurah(int number) {
    final s = surah(number);
    return ayahs.sublist(s.startAyah - 1, s.startAyah - 1 + s.numberOfAyahs);
  }

  String transliterationOf(int globalNumber) => transliteration[globalNumber - 1];

  Edition? edition(String identifier) {
    for (final e in editions) {
      if (e.identifier == identifier) return e;
    }
    return null;
  }

  /// Languages that have at least one translation edition, sorted by name.
  List<String> get translationLanguages {
    final set = <String>{};
    for (final e in editions) {
      if (e.type == 'translation') set.add(e.language);
    }
    final list = set.toList()
      ..sort((a, b) => languageName(a).compareTo(languageName(b)));
    return list;
  }

  /// Search the Arabic text (diacritic-insensitive) and the transliteration.
  /// Returns global ayah numbers, capped at [limit].
  List<int> searchArabicAndTransliteration(String query, {int limit = 200}) {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final results = <int>[];
    if (containsArabic(q)) {
      final nq = normalizeArabic(q);
      for (final a in ayahs) {
        if (normalizeArabic(a.text).contains(nq)) {
          results.add(a.number);
          if (results.length >= limit) break;
        }
      }
    } else {
      final lq = q.toLowerCase();
      for (var i = 0; i < transliteration.length; i++) {
        if (transliteration[i].toLowerCase().contains(lq)) {
          results.add(i + 1);
          if (results.length >= limit) break;
        }
      }
    }
    return results;
  }

  /// Search a full translation corpus (6236 strings). Returns global numbers.
  static List<int> searchCorpus(List<String> corpus, String query,
      {int limit = 200}) {
    final lq = query.trim().toLowerCase();
    if (lq.isEmpty) return const [];
    final results = <int>[];
    for (var i = 0; i < corpus.length; i++) {
      if (corpus[i].toLowerCase().contains(lq)) {
        results.add(i + 1);
        if (results.length >= limit) break;
      }
    }
    return results;
  }
}
