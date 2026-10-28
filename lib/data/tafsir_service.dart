import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

/// A tafsir (commentary) resource on quran.com.
class TafsirSource {
  const TafsirSource(this.id, this.name, this.language, this.author);
  final int id;
  final String name;
  final String language; // ISO 639-1
  final String author;
  bool get isRtl => language == 'ar' || language == 'ur' || language == 'ku';
}

const tafsirSources = <TafsirSource>[
  TafsirSource(169, 'Ibn Kathir (Abridged)', 'en', 'Hafiz Ibn Kathir'),
  TafsirSource(168, "Ma'arif al-Qur'an", 'en', 'Mufti Muhammad Shafi'),
  TafsirSource(817, 'Tazkirul Quran', 'en', 'Maulana Wahiduddin Khan'),
  TafsirSource(16, 'التفسير الميسر', 'ar', 'King Fahd Complex'),
  TafsirSource(14, 'تفسير ابن كثير', 'ar', 'Ibn Kathir'),
  TafsirSource(15, 'تفسير الطبري', 'ar', 'Al-Tabari'),
  TafsirSource(90, 'تفسير القرطبي', 'ar', 'Al-Qurtubi'),
  TafsirSource(91, 'تفسير السعدي', 'ar', "Al-Sa'di"),
  TafsirSource(93, 'التفسير الوسيط', 'ar', 'Tantawi'),
  TafsirSource(94, 'تفسير البغوي', 'ar', 'Al-Baghawi'),
  TafsirSource(160, 'تفسیر ابن کثیر', 'ur', 'Ibn Kathir'),
  TafsirSource(159, 'بیان القرآن', 'ur', 'Dr. Israr Ahmad'),
  TafsirSource(157, 'فی ظلال القرآن', 'ur', 'Sayyid Qutb'),
  TafsirSource(818, 'تذکیر القرآن', 'ur', 'Maulana Wahiduddin Khan'),
  TafsirSource(164, 'তাফসীর ইবনে কাসীর', 'bn', 'Ibn Kathir'),
  TafsirSource(165, 'তাফসীর আহসানুল বায়ান', 'bn', 'Bayaan Foundation'),
  TafsirSource(166, 'তাফসীর আবু বকর যাকারিয়া', 'bn', 'King Fahd Complex'),
  TafsirSource(381, 'তাফসীর ফাতহুল মাজীদ', 'bn', 'AbdulRahman Al-Alshaikh'),
  TafsirSource(170, 'Тафсир ас-Саади', 'ru', "Al-Sa'di"),
  TafsirSource(804, 'Rebar Kurdish Tafsir', 'ku', 'Rebar'),
];

const defaultTafsirId = 169;

TafsirSource tafsirById(int id) =>
    tafsirSources.firstWhere((t) => t.id == id, orElse: () => tafsirSources.first);

/// Fetches tafsir text per ayah from quran.com and caches it on disk.
class TafsirService {
  TafsirService({required Box cache, http.Client? client})
      : _cache = cache,
        _client = client ?? http.Client();

  final Box _cache;
  final http.Client _client;

  /// Returns plain text (paragraphs separated by blank lines, headings
  /// prefixed with "## ") for [verseKey] such as "2:255".
  Future<String> forAyah(int tafsirId, String verseKey) async {
    final k = 'tafsir:$tafsirId:$verseKey';
    final cached = _cache.get(k);
    if (cached is String && cached.isNotEmpty) return cached;
    final uri = Uri.https('api.quran.com', '/api/v4/tafsirs/$tafsirId/by_ayah/$verseKey');
    final res = await _client.get(uri).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) throw TafsirException('Server returned ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final html = ((body['tafsir'] as Map<String, dynamic>?)?['text'] as String?) ?? '';
    final text = htmlToPlainText(html);
    if (text.trim().isEmpty) throw TafsirException('No tafsir available for this ayah');
    await _cache.put(k, text);
    return text;
  }
}

extension TafsirBulk on TafsirService {
  /// Every ayah of a surah in one request, cached per ayah like [forAyah].
  Future<void> forChapter(int tafsirId, int surah) async {
    var page = 1;
    while (true) {
      final uri = Uri.https('api.quran.com', '/api/v4/tafsirs/$tafsirId/by_chapter/$surah', {'per_page': '300', 'page': '$page'});
      final res = await _client.get(uri).timeout(const Duration(seconds: 60));
      if (res.statusCode != 200) throw TafsirException('Server returned ${res.statusCode}');
      final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      await _store(tafsirId, (body['tafsirs'] as List?) ?? const []);
      final next = (body['pagination'] as Map?)?['next_page'];
      if (next is! int || next <= page) break;
      page = next;
    }
  }

  /// Records come in verse order. A tafsir entry often covers a group of
  /// ayahs: the first ayah carries the text and the following ones come back
  /// with an empty body, so those inherit the last text seen (which is what
  /// the by_ayah endpoint returns for them).
  Future<void> _store(int tafsirId, List list) async {
    String? last;
    final leading = <String>[];
    for (final e in list) {
      final m = e as Map<String, dynamic>;
      final key = m['verse_key'] as String?;
      if (key == null) continue;
      final own = htmlToPlainText((m['text'] as String?) ?? '');
      if (own.trim().isNotEmpty) last = own;
      if (last != null) {
        await _cache.put('tafsir:$tafsirId:$key', last);
      } else {
        leading.add(key);
      }
    }
    // A group can start in the previous surah (e.g. 104-105 in Ibn Kathir):
    // those leading ayahs are fetched one by one.
    for (final key in leading) {
      try {
        await forAyah(tafsirId, key);
      } catch (_) {}
    }
  }

  bool isAyahCached(int tafsirId, String verseKey) {
    final v = _cache.get('tafsir:$tafsirId:$verseKey');
    return v is String && v.isNotEmpty;
  }

  /// True when every ayah of the surah is cached (some ayahs legitimately
  /// have no entry in a tafsir, so 90% counts as complete).
  bool isChapterCached(int tafsirId, int surah, int ayahCount) {
    var n = 0;
    for (var a = 1; a <= ayahCount; a++) {
      if (isAyahCached(tafsirId, '$surah:$a')) n++;
    }
    return n >= (ayahCount * 0.9).ceil();
  }
}

class TafsirException implements Exception {
  TafsirException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Very small HTML-to-text conversion good enough for tafsir markup:
/// headings become "## " lines, paragraphs/breaks become blank lines.
String htmlToPlainText(String html) {
  var s = html;
  s = s.replaceAll(RegExp(r'<\s*(h[1-6])[^>]*>', caseSensitive: false), '\n\n## ');
  s = s.replaceAll(RegExp(r'<\s*/\s*h[1-6]\s*>', caseSensitive: false), '\n\n');
  s = s.replaceAll(RegExp(r'<\s*br\s*/?>', caseSensitive: false), '\n');
  s = s.replaceAll(RegExp(r'<\s*/\s*(p|div|li|blockquote|tr)\s*>', caseSensitive: false), '\n\n');
  s = s.replaceAll(RegExp(r'<\s*li[^>]*>', caseSensitive: false), '• ');
  s = s.replaceAll(RegExp(r'<[^>]+>'), '');
  s = s
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&ldquo;', '“')
      .replaceAll('&rdquo;', '”')
      .replaceAll('&lsquo;', '‘')
      .replaceAll('&rsquo;', '’')
      .replaceAll('&hellip;', '…')
      .replaceAll('&mdash;', '—')
      .replaceAll('&ndash;', '–');
  s = s.replaceAllMapped(RegExp(r'&#(\d+);'), (m) => String.fromCharCode(int.parse(m[1]!)));
  s = s.replaceAllMapped(
      RegExp(r'&#x([0-9a-fA-F]+);'), (m) => String.fromCharCode(int.parse(m[1]!, radix: 16)));
  s = s.replaceAll(RegExp(r'[ \t]+\n'), '\n').replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return s.trim();
}
