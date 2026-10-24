import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../data/quran_repository.dart';
import '../data/reciters.dart';
import '../data/storage.dart';
import '../data/translation_service.dart';
import '../data/word_by_word_service.dart';

// ---------------------------------------------------------------------------
// Core data
// ---------------------------------------------------------------------------

final repositoryProvider = FutureProvider<QuranRepository>((ref) => QuranRepository.load());

final translationServiceProvider =
    Provider<TranslationService>((ref) => TranslationService(cache: Storage.cache));

final wordByWordServiceProvider =
    Provider<WordByWordService>((ref) => WordByWordService(cache: Storage.cache));

extension QuranRefX on WidgetRef {
  /// The loaded repository. Only call once the app shell is shown.
  QuranRepository get quran => read(repositoryProvider).requireValue;
}

typedef SurahEditionKey = ({int surah, String edition});
typedef SurahLangKey = ({int surah, String lang});

final surahTranslationProvider =
    FutureProvider.family<List<String>, SurahEditionKey>((ref, key) async {
  final repo = await ref.watch(repositoryProvider.future);
  final s = repo.surah(key.surah);
  return ref.watch(translationServiceProvider).forSurah(
        key.edition,
        key.surah,
        startAyah: s.startAyah,
        count: s.numberOfAyahs,
      );
});

final surahWordsProvider =
    FutureProvider.family<List<List<QuranWord>>, SurahLangKey>((ref, key) {
  return ref.watch(wordByWordServiceProvider).forSurah(key.surah, key.lang);
});

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

enum ReaderMode { translation, mushaf }

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.arabicScale = 1.0,
    this.translationScale = 1.0,
    this.showTransliteration = true,
    this.wordByWord = false,
    this.wordLanguage = 'en',
    this.translations = const [TranslationService.defaultEdition],
    this.readerMode = ReaderMode.translation,
    this.arabicFont = ArabicStyles.quranFont,
    this.reciter = defaultReciterId,
  });

  final ThemeMode themeMode;
  final double arabicScale;
  final double translationScale;
  final bool showTransliteration;
  final bool wordByWord;
  final String wordLanguage;
  final List<String> translations;
  final ReaderMode readerMode;
  final String arabicFont;
  final String reciter;

  static const maxTranslations = 4;

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? arabicScale,
    double? translationScale,
    bool? showTransliteration,
    bool? wordByWord,
    String? wordLanguage,
    List<String>? translations,
    ReaderMode? readerMode,
    String? arabicFont,
    String? reciter,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      arabicScale: arabicScale ?? this.arabicScale,
      translationScale: translationScale ?? this.translationScale,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      wordByWord: wordByWord ?? this.wordByWord,
      wordLanguage: wordLanguage ?? this.wordLanguage,
      translations: translations ?? this.translations,
      readerMode: readerMode ?? this.readerMode,
      arabicFont: arabicFont ?? this.arabicFont,
      reciter: reciter ?? this.reciter,
    );
  }

  Map<String, dynamic> toMap() => {
        'themeMode': themeMode.index,
        'arabicScale': arabicScale,
        'translationScale': translationScale,
        'showTransliteration': showTransliteration,
        'wordByWord': wordByWord,
        'wordLanguage': wordLanguage,
        'translations': translations,
        'readerMode': readerMode.index,
        'arabicFont': arabicFont,
        'reciter': reciter,
      };

  factory AppSettings.fromMap(Map<dynamic, dynamic> m) {
    const d = AppSettings();
    return AppSettings(
      themeMode: ThemeMode.values[(m['themeMode'] as int?) ?? d.themeMode.index],
      arabicScale: (m['arabicScale'] as num?)?.toDouble() ?? d.arabicScale,
      translationScale: (m['translationScale'] as num?)?.toDouble() ?? d.translationScale,
      showTransliteration: (m['showTransliteration'] as bool?) ?? d.showTransliteration,
      wordByWord: (m['wordByWord'] as bool?) ?? d.wordByWord,
      wordLanguage: (m['wordLanguage'] as String?) ?? d.wordLanguage,
      translations: (m['translations'] as List?)?.cast<String>() ?? d.translations,
      readerMode: ReaderMode.values[(m['readerMode'] as int?) ?? d.readerMode.index],
      arabicFont: (m['arabicFont'] as String?) ?? d.arabicFont,
      reciter: (m['reciter'] as String?) ?? d.reciter,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'app';

  @override
  AppSettings build() {
    final stored = Storage.settings.get(_key);
    if (stored is Map) return AppSettings.fromMap(stored);
    return const AppSettings();
  }

  void _update(AppSettings next) {
    state = next;
    Storage.settings.put(_key, next.toMap());
  }

  void setThemeMode(ThemeMode m) => _update(state.copyWith(themeMode: m));
  void setArabicScale(double v) => _update(state.copyWith(arabicScale: v));
  void setTranslationScale(double v) => _update(state.copyWith(translationScale: v));
  void setShowTransliteration(bool v) => _update(state.copyWith(showTransliteration: v));
  void setWordByWord(bool v) => _update(state.copyWith(wordByWord: v));
  void setWordLanguage(String v) => _update(state.copyWith(wordLanguage: v));
  void setReaderMode(ReaderMode m) => _update(state.copyWith(readerMode: m));
  void setArabicFont(String f) => _update(state.copyWith(arabicFont: f));
  void setReciter(String id) => _update(state.copyWith(reciter: id));

  /// Adds or removes a translation edition. Returns false when the limit is hit.
  bool toggleTranslation(String edition) {
    final list = [...state.translations];
    if (list.contains(edition)) {
      list.remove(edition);
    } else {
      if (list.length >= AppSettings.maxTranslations) return false;
      list.add(edition);
    }
    _update(state.copyWith(translations: list));
    return true;
  }

  void setTranslations(List<String> editions) =>
      _update(state.copyWith(translations: editions));
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

// ---------------------------------------------------------------------------
// Bookmarks & last read
// ---------------------------------------------------------------------------

class BookmarksNotifier extends Notifier<List<Bookmark>> {
  @override
  List<Bookmark> build() {
    final items = Storage.bookmarks.values
        .whereType<Map>()
        .map(Bookmark.fromJson)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  bool contains(int ayahNumber) => state.any((b) => b.ayahNumber == ayahNumber);

  /// Returns true if the ayah is bookmarked after the call.
  bool toggle(int ayahNumber) {
    if (contains(ayahNumber)) {
      remove(ayahNumber);
      return false;
    }
    final b = Bookmark(ayahNumber: ayahNumber, createdAt: DateTime.now());
    Storage.bookmarks.put('$ayahNumber', b.toJson());
    state = [b, ...state];
    return true;
  }

  void remove(int ayahNumber) {
    Storage.bookmarks.delete('$ayahNumber');
    state = state.where((b) => b.ayahNumber != ayahNumber).toList();
  }
}

final bookmarksProvider =
    NotifierProvider<BookmarksNotifier, List<Bookmark>>(BookmarksNotifier.new);

class LastReadNotifier extends Notifier<LastRead?> {
  static const _key = 'lastRead';

  @override
  LastRead? build() {
    final m = Storage.settings.get(_key);
    if (m is Map) {
      return LastRead(
        ayahNumber: m['n'] as int,
        at: DateTime.fromMillisecondsSinceEpoch(m['t'] as int),
      );
    }
    return null;
  }

  void set(int ayahNumber) {
    if (state?.ayahNumber == ayahNumber) return;
    final v = LastRead(ayahNumber: ayahNumber, at: DateTime.now());
    state = v;
    Storage.settings.put(_key, {'n': ayahNumber, 't': v.at.millisecondsSinceEpoch});
  }
}

final lastReadProvider =
    NotifierProvider<LastReadNotifier, LastRead?>(LastReadNotifier.new);

/// Deterministic "verse of the day" (changes once per day).
final verseOfTheDayProvider = Provider<int>((ref) {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  final seed = now.year * 1000 + dayOfYear;
  // Simple LCG so the pick looks random but is stable for the whole day.
  final r = (seed * 1103515245 + 12345) & 0x7fffffff;
  return (r % QuranRepository.totalAyahs) + 1;
});
