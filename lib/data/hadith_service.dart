import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

/// Hadith collections from the open fawazahmed0/hadith-api CDN (no key).
class HadithBook {
  const HadithBook({
    required this.id,
    required this.name,
    required this.arabic,
    required this.languages,
    required this.hadithCount,
    required this.sections,
  });

  final String id; // bukhari, muslim, ...
  final String name;
  final String arabic;
  final List<String> languages; // 3-letter codes: eng, urd, fra ...
  final int hadithCount;
  final List<HadithSection> sections;

  factory HadithBook.fromJson(Map<String, dynamic> j) => HadithBook(
        id: j['id'] as String,
        name: j['name'] as String,
        arabic: j['arabic'] as String,
        languages: (j['languages'] as List).cast<String>(),
        hadithCount: j['hadiths'] as int,
        sections: (j['sections'] as List)
            .map((s) => HadithSection.fromJson(s as Map<String, dynamic>))
            .toList(growable: false),
      );
}

class HadithSection {
  const HadithSection({required this.number, required this.name, required this.first, required this.last});
  final int number;
  final String name;
  final int first;
  final int last;
  int get count => last >= first ? last - first + 1 : 0;

  factory HadithSection.fromJson(Map<String, dynamic> j) => HadithSection(
        number: j['n'] as int,
        name: j['name'] as String,
        first: j['first'] as int,
        last: j['last'] as int,
      );
}

class Hadith {
  const Hadith({
    required this.number,
    required this.arabic,
    required this.text,
    required this.grades,
    required this.reference,
  });

  final int number;
  final String arabic;
  final String text;
  final List<String> grades;
  final String reference;

  Map<String, dynamic> toJson() =>
      {'n': number, 'a': arabic, 't': text, 'g': grades, 'r': reference};

  factory Hadith.fromJson(Map<dynamic, dynamic> j) => Hadith(
        number: j['n'] as int,
        arabic: (j['a'] as String?) ?? '',
        text: (j['t'] as String?) ?? '',
        grades: ((j['g'] as List?) ?? const []).cast<String>(),
        reference: (j['r'] as String?) ?? '',
      );
}

const hadithLanguages = <String, String>{
  'eng': 'English',
  'ara': 'Arabic only',
  'urd': 'Urdu',
  'fra': 'French',
  'ind': 'Indonesian',
  'tur': 'Turkish',
  'ben': 'Bengali',
  'rus': 'Russian',
  'tam': 'Tamil',
};

bool hadithLanguageIsRtl(String code) => code == 'urd' || code == 'ara';

class HadithService {
  HadithService({required Box cache, http.Client? client})
      : _cache = cache,
        _client = client ?? http.Client();

  static const cdn = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';

  final Box _cache;
  final http.Client _client;
  List<HadithBook>? _books;
  final Map<String, Future<List<Hadith>>> _inFlight = {};

  Future<List<HadithBook>> books() async {
    if (_books != null) return _books!;
    final raw = await rootBundle.loadString('assets/data/hadith_books.json');
    _books = (jsonDecode(raw) as List)
        .map((b) => HadithBook.fromJson(b as Map<String, dynamic>))
        .toList(growable: false);
    return _books!;
  }

  bool isCached(String book, int section, String lang) =>
      _cache.containsKey(_key(book, section, lang));

  /// Hadiths of one section with Arabic plus the [lang] translation.
  Future<List<Hadith>> section(String book, int section, String lang) {
    final k = _key(book, section, lang);
    return _inFlight.putIfAbsent(k, () async {
      try {
        final cached = _cache.get(k);
        if (cached is List && cached.isNotEmpty) {
          return cached.map((h) => Hadith.fromJson(h as Map)).toList(growable: false);
        }
        final arabic = await _fetchSection('ara-$book', section);
        final translated = lang == 'ara' ? <int, Map<String, dynamic>>{} : await _fetchSection('$lang-$book', section);
        final result = <Hadith>[];
        for (final e in arabic.entries) {
          final t = translated[e.key];
          final grades = ((t ?? e.value)['grades'] as List? ?? const [])
              .map((g) => '${(g as Map)['grade']}${g['name'] != null ? ' (${g['name']})' : ''}')
              .where((g) => g.trim().isNotEmpty)
              .toList();
          final ref = (t ?? e.value)['reference'] as Map?;
          result.add(Hadith(
            number: e.key,
            arabic: (e.value['text'] as String? ?? '').trim(),
            text: (t?['text'] as String? ?? '').trim(),
            grades: grades,
            reference: ref == null ? '' : 'Book ${ref['book']}, Hadith ${ref['hadith']}',
          ));
        }
        result.sort((a, b) => a.number.compareTo(b.number));
        await _cache.put(k, result.map((h) => h.toJson()).toList(growable: false));
        return result;
      } finally {
        _inFlight.remove(k);
      }
    });
  }

  Future<Map<int, Map<String, dynamic>>> _fetchSection(String edition, int section) async {
    final uri = Uri.parse('$cdn/editions/$edition/sections/$section.min.json');
    var res = await _client.get(uri).timeout(const Duration(seconds: 25));
    if (res.statusCode == 404) {
      res = await _client
          .get(Uri.parse('$cdn/editions/$edition/sections/$section.json'))
          .timeout(const Duration(seconds: 25));
    }
    if (res.statusCode != 200) throw HadithException('Server returned ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final out = <int, Map<String, dynamic>>{};
    for (final h in body['hadiths'] as List) {
      final m = h as Map<String, dynamic>;
      final n = m['hadithnumber'];
      out[n is int ? n : (n as num).toInt()] = m;
    }
    return out;
  }

  static String _key(String book, int section, String lang) => 'hadith:$book:$section:$lang';
}

class HadithException implements Exception {
  HadithException(this.message);
  final String message;
  @override
  String toString() => message;
}
