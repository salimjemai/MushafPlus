import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage.dart';

/// One supplication from Hisn al-Muslim.
class AdhkarItem {
  const AdhkarItem({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.transliteration,
    required this.repeat,
    required this.audio,
  });

  final int id;
  final String arabic;

  /// English meaning (the source has English only).
  final String translation;

  /// Romanised reading.
  final String transliteration;

  /// How many times it is said.
  final int repeat;

  /// MP3 of this dhikr (hisnmuslim.com).
  final String audio;

  factory AdhkarItem.fromJson(Map<String, dynamic> j) => AdhkarItem(
        id: (j['id'] as num).toInt(),
        arabic: j['arabic'] as String? ?? '',
        translation: j['en'] as String? ?? '',
        transliteration: j['tr'] as String? ?? '',
        repeat: (j['repeat'] as num?)?.toInt() ?? 1,
        audio: j['audio'] as String? ?? '',
      );
}

/// A chapter ("door") of Hisn al-Muslim.
class AdhkarChapter {
  const AdhkarChapter({required this.id, required this.arabic, required this.english, required this.audio, required this.items});

  final int id;
  final String arabic;
  final String english;

  /// MP3 of the whole chapter.
  final String audio;
  final List<AdhkarItem> items;

  /// Title for the interface language: Arabic for Arabic, English otherwise.
  String titleFor(String languageCode) => languageCode == 'ar' || english.isEmpty ? arabic : english;

  /// The other title, for a secondary line.
  String secondaryFor(String languageCode) => languageCode == 'ar' ? english : arabic;

  int get totalRepeats => items.fold(0, (n, i) => n + i.repeat);

  factory AdhkarChapter.fromJson(Map<String, dynamic> j) => AdhkarChapter(
        id: (j['id'] as num).toInt(),
        arabic: j['ar'] as String? ?? '',
        english: j['en'] as String? ?? '',
        audio: j['audio'] as String? ?? '',
        items: ((j['items'] as List?) ?? const []).map((e) => AdhkarItem.fromJson(e as Map<String, dynamic>)).toList(growable: false),
      );
}

class AdhkarBook {
  const AdhkarBook(this.chapters);
  final List<AdhkarChapter> chapters;

  static Future<AdhkarBook> load() async {
    final raw = await rootBundle.loadString('assets/data/adhkar.json');
    return AdhkarBook((jsonDecode(raw) as List).map((e) => AdhkarChapter.fromJson(e as Map<String, dynamic>)).toList(growable: false));
  }

  AdhkarChapter? byId(int id) => chapters.where((c) => c.id == id).firstOrNull;

  /// Chapters whose Arabic title matches a keyword (morning/evening, sleep…).
  AdhkarChapter? find(Pattern arabicTitle) => chapters.where((c) => c.arabic.contains(arabicTitle)).firstOrNull;

  int get totalItems => chapters.fold(0, (n, c) => n + c.items.length);
}

final adhkarProvider = FutureProvider<AdhkarBook>((ref) => AdhkarBook.load());

/// Today's repeat counts per dhikr; they reset every day.
class AdhkarCountsNotifier extends Notifier<Map<int, int>> {
  static const _key = 'adhkarCounts';

  String get _today {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  @override
  Map<int, int> build() {
    final v = Storage.settings.get(_key);
    if (v is Map && v['date'] == _today && v['counts'] is Map) {
      return {for (final e in (v['counts'] as Map).entries) (e.key as num).toInt(): (e.value as num).toInt()};
    }
    return {};
  }

  void _save(Map<int, int> next) {
    state = next;
    Storage.settings.put(_key, {'date': _today, 'counts': {for (final e in next.entries) e.key: e.value}});
  }

  /// Adds one repetition; wraps back to zero after the target.
  void tap(AdhkarItem item) {
    final n = (state[item.id] ?? 0) + 1;
    _save({...state, item.id: n > item.repeat ? 0 : n});
  }

  void reset(AdhkarChapter chapter) {
    final next = {...state};
    for (final i in chapter.items) {
      next.remove(i.id);
    }
    _save(next);
  }
}

final adhkarCountsProvider = NotifierProvider<AdhkarCountsNotifier, Map<int, int>>(AdhkarCountsNotifier.new);
