import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

/// Supplies translation text per surah for any alquran.cloud edition.
///
/// Three English editions ship inside the app; every other edition is fetched
/// once from https://api.alquran.cloud and cached on disk, so it is available
/// offline afterwards.
class TranslationService {
  TranslationService({required Box cache, http.Client? client})
      : _cache = cache,
        _client = client ?? http.Client();

  final Box _cache;
  final http.Client _client;

  static const bundledEditions = <String>{'en.sahih', 'en.pickthall', 'en.asad'};
  static const defaultEdition = 'en.sahih';

  final Map<String, List<String>> _bundled = {};
  final Map<String, Future<List<String>>> _inFlight = {};

  bool isBundled(String edition) => bundledEditions.contains(edition);

  bool isCached(String edition, int surah) =>
      isBundled(edition) || _cache.containsKey(_key(edition, surah));

  /// The entire bundled corpus (6236 strings) for offline search.
  Future<List<String>> bundledCorpus(String edition) async {
    assert(isBundled(edition));
    final existing = _bundled[edition];
    if (existing != null) return existing;
    final raw = await rootBundle.loadString('assets/data/translations/$edition.json');
    final list = (jsonDecode(raw) as List).cast<String>();
    _bundled[edition] = list;
    return list;
  }

  /// Returns the translation of every ayah of [surah], in order.
  Future<List<String>> forSurah(String edition, int surah,
      {required int startAyah, required int count}) {
    final k = _key(edition, surah);
    return _inFlight.putIfAbsent(k, () async {
      try {
        if (isBundled(edition)) {
          final corpus = await bundledCorpus(edition);
          return corpus.sublist(startAyah - 1, startAyah - 1 + count);
        }
        final cached = _cache.get(k);
        if (cached is List && cached.length == count) {
          return cached.cast<String>();
        }
        final uri = Uri.parse('https://api.alquran.cloud/v1/surah/$surah/$edition');
        final res = await _client.get(uri).timeout(const Duration(seconds: 25));
        if (res.statusCode != 200) {
          throw TranslationException('Server returned ${res.statusCode}');
        }
        final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final ayahs = (body['data'] as Map<String, dynamic>)['ayahs'] as List;
        final texts = ayahs
            .map((a) => ((a as Map<String, dynamic>)['text'] as String).trim())
            .toList(growable: false);
        if (texts.length != count) {
          throw TranslationException('Unexpected ayah count ${texts.length}');
        }
        await _cache.put(k, texts);
        return texts;
      } finally {
        _inFlight.remove(k);
      }
    });
  }

  static String _key(String edition, int surah) => 'tr:$edition:$surah';
}

class TranslationException implements Exception {
  TranslationException(this.message);
  final String message;
  @override
  String toString() => message;
}
