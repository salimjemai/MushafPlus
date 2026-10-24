import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

/// Word-by-word data (Arabic word, Latin transliteration, meaning) from the
/// quran.com v4 API. Fetched per surah and cached on disk.
class WordByWordService {
  WordByWordService({required Box cache, http.Client? client})
      : _cache = cache,
        _client = client ?? http.Client();

  final Box _cache;
  final http.Client _client;
  final Map<String, Future<List<List<QuranWord>>>> _inFlight = {};

  bool isCached(int surah, String lang) => _cache.containsKey(_key(surah, lang));

  /// Returns one list of words per ayah of [surah], in order.
  Future<List<List<QuranWord>>> forSurah(int surah, String lang) {
    final k = _key(surah, lang);
    return _inFlight.putIfAbsent(k, () async {
      try {
        final cached = _cache.get(k);
        if (cached is List && cached.isNotEmpty) {
          return cached
              .map((ayah) => (ayah as List)
                  .map((w) => QuranWord.fromJson(w as Map))
                  .toList(growable: false))
              .toList(growable: false);
        }
        final result = <List<QuranWord>>[];
        var page = 1;
        while (true) {
          final uri = Uri.https('api.quran.com', '/api/v4/verses/by_chapter/$surah', {
            'words': 'true',
            'word_fields': 'text_uthmani',
            'word_translation_language': lang,
            'per_page': '50',
            'page': '$page',
          });
          final res = await _client.get(uri).timeout(const Duration(seconds: 25));
          if (res.statusCode != 200) {
            throw WordByWordException('Server returned ${res.statusCode}');
          }
          final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
          for (final v in body['verses'] as List) {
            final words = <QuranWord>[];
            for (final w in (v as Map<String, dynamic>)['words'] as List) {
              final m = w as Map<String, dynamic>;
              final isEnd = m['char_type_name'] == 'end';
              words.add(QuranWord(
                position: m['position'] as int,
                arabic: (m['text_uthmani'] ?? m['text'] ?? '') as String,
                transliteration: isEnd
                    ? ''
                    : ((m['transliteration'] as Map?)?['text'] as String?) ?? '',
                translation: isEnd
                    ? ''
                    : ((m['translation'] as Map?)?['text'] as String?) ?? '',
                isEndMarker: isEnd,
              ));
            }
            result.add(words);
          }
          final next = (body['pagination'] as Map<String, dynamic>)['next_page'];
          if (next == null) break;
          page = next as int;
        }
        await _cache.put(
          k,
          result
              .map((ayah) => ayah.map((w) => w.toJson()).toList(growable: false))
              .toList(growable: false),
        );
        return result;
      } finally {
        _inFlight.remove(k);
      }
    });
  }

  static String _key(int surah, String lang) => 'wbw:$lang:$surah';
}

class WordByWordException implements Exception {
  WordByWordException(this.message);
  final String message;
  @override
  String toString() => message;
}
