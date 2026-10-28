import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/device_form.dart';

import '../core/theme.dart';
import '../data/hadith_service.dart';
import '../data/models.dart';
import '../data/quran_repository.dart';
import '../data/reciters.dart';
import '../data/storage.dart';
import '../data/tafsir_service.dart';
import '../data/translation_service.dart';
import '../data/word_by_word_service.dart';
import 'reading_stats.dart';

// ---------------------------------------------------------------------------
// Core data
// ---------------------------------------------------------------------------

final repositoryProvider = FutureProvider<QuranRepository>((ref) => QuranRepository.load());

final translationServiceProvider =
    Provider<TranslationService>((ref) => TranslationService(cache: Storage.cache));

final wordByWordServiceProvider =
    Provider<WordByWordService>((ref) => WordByWordService(cache: Storage.cache));

final tafsirServiceProvider =
    Provider<TafsirService>((ref) => TafsirService(cache: Storage.cache));

final hadithServiceProvider = Provider<HadithService>((ref) => HadithService(cache: Storage.cache));

final hadithBooksProvider = FutureProvider<List<HadithBook>>((ref) => ref.watch(hadithServiceProvider).books());

typedef HadithSectionKey = ({String book, int section, String lang});

final hadithSectionProvider = FutureProvider.family<List<Hadith>, HadithSectionKey>((ref, k) {
  return ref.watch(hadithServiceProvider).section(k.book, k.section, k.lang);
});

typedef TafsirKey = ({int id, String key});

final tafsirProvider = FutureProvider.family<String, TafsirKey>((ref, k) {
  return ref.watch(tafsirServiceProvider).forAyah(k.id, k.key);
});

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

/// How the Mushaf book is laid out.
enum MushafLayout { auto, scroll, flip, book }

/// How pages turn in the two-page book: paper curl, rigid flip, slide, fade.
enum PageAnimation { curl, flip, slide, fade }

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.arabicScale = 1.0,
    this.translationScale = 1.0,
    this.showTransliteration = true,
    this.offlinePromptShown = false,
    this.offlineReciter = true,
    this.offlineWifiOnly = true,
    this.prayerMode = 'personal',
    this.remindPrayers = false,
    this.prayerReminderMinutes = 0,
    this.remindAdhkar = false,
    this.dailyReminder = false,
    this.dailyReminderHour = 9,
    this.region,
    this.tajweed = true,
    this.wordByWord = false,
    this.wordLanguage = 'en',
    this.translations = const [TranslationService.defaultEdition],
    this.readerMode = ReaderMode.translation,
    this.arabicFont = ArabicStyles.quranFont,
    this.reciter = defaultReciterId,
    this.tafsirId = defaultTafsirId,
    this.hadithLanguage = 'eng',
    this.mushafLayout = MushafLayout.auto,
    this.locale,
    this.pageAnimation = PageAnimation.curl,
    this.adhanId = 'commons_aaqib_azeez',
    this.recognitionEngine = 'browser',
  });

  final ThemeMode themeMode;
  final double arabicScale;
  final double translationScale;
  final bool showTransliteration;

  /// The first-start "download everything for offline" prompt was answered.
  final bool offlinePromptShown;

  /// Also keep the whole recitation of the chosen reciter offline.
  final bool offlineReciter;

  /// Audio packs download only on Wi-Fi / ethernet unless started by hand.
  final bool offlineWifiOnly;

  /// 'personal' (my location) or 'masjid' (a masjid profile) on the Prayer tab.
  final String prayerMode;
  final bool remindPrayers;
  final int prayerReminderMinutes;
  final bool remindAdhkar;
  final bool dailyReminder;
  final int dailyReminderHour;

  /// Country the app is used in (ISO code); null until detected or chosen.
  final String? region;

  /// Colour letters by tajweed rule in the Mushaf and reader.
  final bool tajweed;
  final bool wordByWord;
  final String wordLanguage;
  final List<String> translations;
  final ReaderMode readerMode;
  final String arabicFont;
  final String reciter;
  final int tafsirId;
  final String hadithLanguage;
  final MushafLayout mushafLayout;

  /// Interface language code, or null to follow the system.
  final String? locale;
  final PageAnimation pageAnimation;

  /// Preferred adhan recording.
  final String adhanId;

  /// Recite & check engine: 'browser' (the platform recogniser, letters
  /// only) or 'voice' (the on-device Mushaf+ voice model, web only).
  final String recognitionEngine;

  bool get useVoiceModel => recognitionEngine == 'voice';

  static const maxTranslations = 4;

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? arabicScale,
    double? translationScale,
    bool? showTransliteration,
    bool? offlinePromptShown,
    bool? offlineReciter,
    bool? offlineWifiOnly,
    String? prayerMode,
    bool? remindPrayers,
    int? prayerReminderMinutes,
    bool? remindAdhkar,
    bool? dailyReminder,
    int? dailyReminderHour,
    String? region,
    bool clearRegion = false,
    bool? tajweed,
    bool? wordByWord,
    String? wordLanguage,
    List<String>? translations,
    ReaderMode? readerMode,
    String? arabicFont,
    String? reciter,
    int? tafsirId,
    String? hadithLanguage,
    MushafLayout? mushafLayout,
    String? locale,
    bool clearLocale = false,
    PageAnimation? pageAnimation,
    String? adhanId,
    String? recognitionEngine,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      arabicScale: arabicScale ?? this.arabicScale,
      translationScale: translationScale ?? this.translationScale,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      offlinePromptShown: offlinePromptShown ?? this.offlinePromptShown,
      offlineReciter: offlineReciter ?? this.offlineReciter,
      offlineWifiOnly: offlineWifiOnly ?? this.offlineWifiOnly,
      prayerMode: prayerMode ?? this.prayerMode,
      remindPrayers: remindPrayers ?? this.remindPrayers,
      prayerReminderMinutes: prayerReminderMinutes ?? this.prayerReminderMinutes,
      remindAdhkar: remindAdhkar ?? this.remindAdhkar,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      region: clearRegion ? null : (region ?? this.region),
      tajweed: tajweed ?? this.tajweed,
      wordByWord: wordByWord ?? this.wordByWord,
      wordLanguage: wordLanguage ?? this.wordLanguage,
      translations: translations ?? this.translations,
      readerMode: readerMode ?? this.readerMode,
      arabicFont: arabicFont ?? this.arabicFont,
      reciter: reciter ?? this.reciter,
      tafsirId: tafsirId ?? this.tafsirId,
      hadithLanguage: hadithLanguage ?? this.hadithLanguage,
      mushafLayout: mushafLayout ?? this.mushafLayout,
      locale: clearLocale ? null : (locale ?? this.locale),
      pageAnimation: pageAnimation ?? this.pageAnimation,
      adhanId: adhanId ?? this.adhanId,
      recognitionEngine: recognitionEngine ?? this.recognitionEngine,
    );
  }

  Map<String, dynamic> toMap() => {
        'themeMode': themeMode.index,
        'arabicScale': arabicScale,
        'translationScale': translationScale,
        'showTransliteration': showTransliteration,
        'offlinePromptShown': offlinePromptShown,
        'offlineReciter': offlineReciter,
        'offlineWifiOnly': offlineWifiOnly,
        'prayerMode': prayerMode,
        'remindPrayers': remindPrayers,
        'prayerReminderMinutes': prayerReminderMinutes,
        'remindAdhkar': remindAdhkar,
        'dailyReminder': dailyReminder,
        'dailyReminderHour': dailyReminderHour,
        if (region != null) 'region': region,
        'tajweed': tajweed,
        'wordByWord': wordByWord,
        'wordLanguage': wordLanguage,
        'translations': translations,
        'readerMode': readerMode.index,
        'arabicFont': arabicFont,
        'reciter': reciter,
        'tafsirId': tafsirId,
        'hadithLanguage': hadithLanguage,
        'mushafLayout': mushafLayout.index,
        if (locale != null) 'locale': locale,
        'pageAnimation': pageAnimation.index,
        'adhanId': adhanId,
        'recognitionEngine': recognitionEngine,
      };

  factory AppSettings.fromMap(Map<dynamic, dynamic> m) {
    const d = AppSettings();
    return AppSettings(
      themeMode: ThemeMode.values[(m['themeMode'] as int?) ?? d.themeMode.index],
      arabicScale: (m['arabicScale'] as num?)?.toDouble() ?? d.arabicScale,
      translationScale: (m['translationScale'] as num?)?.toDouble() ?? d.translationScale,
      showTransliteration: (m['showTransliteration'] as bool?) ?? d.showTransliteration,
      offlinePromptShown: (m['offlinePromptShown'] as bool?) ?? d.offlinePromptShown,
      offlineReciter: (m['offlineReciter'] as bool?) ?? d.offlineReciter,
      offlineWifiOnly: (m['offlineWifiOnly'] as bool?) ?? d.offlineWifiOnly,
      prayerMode: (m['prayerMode'] as String?) ?? d.prayerMode,
      remindPrayers: (m['remindPrayers'] as bool?) ?? d.remindPrayers,
      prayerReminderMinutes: (m['prayerReminderMinutes'] as int?) ?? d.prayerReminderMinutes,
      remindAdhkar: (m['remindAdhkar'] as bool?) ?? d.remindAdhkar,
      dailyReminder: (m['dailyReminder'] as bool?) ?? d.dailyReminder,
      dailyReminderHour: (m['dailyReminderHour'] as int?) ?? d.dailyReminderHour,
      region: m['region'] as String?,
      tajweed: (m['tajweed'] as bool?) ?? d.tajweed,
      wordByWord: (m['wordByWord'] as bool?) ?? d.wordByWord,
      wordLanguage: (m['wordLanguage'] as String?) ?? d.wordLanguage,
      translations: (m['translations'] as List?)?.cast<String>() ?? d.translations,
      readerMode: ReaderMode.values[(m['readerMode'] as int?) ?? d.readerMode.index],
      arabicFont: (m['arabicFont'] as String?) ?? d.arabicFont,
      reciter: (m['reciter'] as String?) ?? d.reciter,
      tafsirId: (m['tafsirId'] as int?) ?? d.tafsirId,
      hadithLanguage: (m['hadithLanguage'] as String?) ?? d.hadithLanguage,
      mushafLayout: MushafLayout.values[((m['mushafLayout'] as int?) ?? 0).clamp(0, MushafLayout.values.length - 1)],
      locale: m['locale'] as String?,
      pageAnimation: PageAnimation.values[((m['pageAnimation'] as int?) ?? 0).clamp(0, PageAnimation.values.length - 1)],
      adhanId: (m['adhanId'] as String?) ?? d.adhanId,
      recognitionEngine: (m['recognitionEngine'] as String?) ?? d.recognitionEngine,
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
  void setOfflinePromptShown(bool v) => _update(state.copyWith(offlinePromptShown: v));
  void setOfflineReciter(bool v) => _update(state.copyWith(offlineReciter: v));
  void setOfflineWifiOnly(bool v) => _update(state.copyWith(offlineWifiOnly: v));
  void setPrayerMode(String v) => _update(state.copyWith(prayerMode: v));
  void setRemindPrayers(bool v) => _update(state.copyWith(remindPrayers: v));
  void setPrayerReminderMinutes(int v) => _update(state.copyWith(prayerReminderMinutes: v));
  void setRemindAdhkar(bool v) => _update(state.copyWith(remindAdhkar: v));
  void setDailyReminder(bool v) => _update(state.copyWith(dailyReminder: v));
  void setDailyReminderHour(int v) => _update(state.copyWith(dailyReminderHour: v.clamp(0, 23)));
  void setRegion(String? code) => _update(code == null ? state.copyWith(clearRegion: true) : state.copyWith(region: code.toUpperCase()));
  void setTajweed(bool v) => _update(state.copyWith(tajweed: v));
  void setWordByWord(bool v) => _update(state.copyWith(wordByWord: v));
  void setWordLanguage(String v) => _update(state.copyWith(wordLanguage: v));
  void setReaderMode(ReaderMode m) => _update(state.copyWith(readerMode: m));
  void setArabicFont(String f) => _update(state.copyWith(arabicFont: f));
  void setReciter(String id) => _update(state.copyWith(reciter: id));
  void setTafsirId(int id) => _update(state.copyWith(tafsirId: id));
  void setHadithLanguage(String l) => _update(state.copyWith(hadithLanguage: l));
  void setMushafLayout(MushafLayout l) => _update(state.copyWith(mushafLayout: l));
  void setPageAnimation(PageAnimation a) => _update(state.copyWith(pageAnimation: a));
  void setAdhanId(String id) => _update(state.copyWith(adhanId: id));
  void setRecognitionEngine(String id) => _update(state.copyWith(recognitionEngine: id));
  void setLocale(String? code) =>
      _update(code == null ? state.copyWith(clearLocale: true) : state.copyWith(locale: code));

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
    ref.read(readingStatsProvider.notifier).recordRead(ayahNumber);
    if (state?.ayahNumber == ayahNumber) return;
    final v = LastRead(ayahNumber: ayahNumber, at: DateTime.now());
    state = v;
    Storage.settings.put(_key, {'n': ayahNumber, 't': v.at.millisecondsSinceEpoch});
  }
}

final lastReadProvider =
    NotifierProvider<LastReadNotifier, LastRead?>(LastReadNotifier.new);

/// Personal notes per ayah (global number -> text).
class NotesNotifier extends Notifier<Map<int, String>> {
  static const _key = 'notes';

  @override
  Map<int, String> build() {
    final v = Storage.settings.get(_key);
    if (v is Map) return {for (final e in v.entries) (e.key as num).toInt(): e.value as String};
    return {};
  }

  void set(int ayahNumber, String text) {
    final next = {...state};
    if (text.trim().isEmpty) {
      next.remove(ayahNumber);
    } else {
      next[ayahNumber] = text.trim();
    }
    state = next;
    Storage.settings.put(_key, {for (final e in next.entries) e.key: e.value});
  }
}

final notesProvider = NotifierProvider<NotesNotifier, Map<int, String>>(NotesNotifier.new);

/// Highlight colour palette for marked ayahs.
const highlightColors = <Color>[
  Color(0xFFFFE066), // yellow
  Color(0xFF9AE6A0), // green
  Color(0xFF9CCBFF), // blue
  Color(0xFFFFB3C7), // pink
  Color(0xFFFFC98A), // orange
];

/// Highlighted ayahs (global number -> palette index).
class HighlightsNotifier extends Notifier<Map<int, int>> {
  static const _key = 'highlights';

  @override
  Map<int, int> build() {
    final v = Storage.settings.get(_key);
    if (v is Map) return {for (final e in v.entries) (e.key as num).toInt(): (e.value as num).toInt()};
    return {};
  }

  void set(int ayahNumber, int? colorIndex) {
    final next = {...state};
    if (colorIndex == null) {
      next.remove(ayahNumber);
    } else {
      next[ayahNumber] = colorIndex;
    }
    state = next;
    Storage.settings.put(_key, {for (final e in next.entries) e.key: e.value});
  }
}

final highlightsProvider = NotifierProvider<HighlightsNotifier, Map<int, int>>(HighlightsNotifier.new);

/// Global ayah numbers the user has marked as memorised.
class MemorizedNotifier extends Notifier<Set<int>> {
  static const _key = 'memorized';

  @override
  Set<int> build() {
    final v = Storage.settings.get(_key);
    if (v is List) return v.cast<int>().toSet();
    return {};
  }

  void toggle(int ayahNumber) {
    final next = {...state};
    if (!next.remove(ayahNumber)) next.add(ayahNumber);
    state = next;
    Storage.settings.put(_key, next.toList()..sort());
  }
}

final memorizedProvider = NotifierProvider<MemorizedNotifier, Set<int>>(MemorizedNotifier.new);

/// Deterministic "verse of the day" for a calendar date (global ayah number).
int verseOfTheDayFor(DateTime day) {
  // Counted in UTC so a daylight-saving shift cannot move the day boundary.
  final dayOfYear = DateTime.utc(day.year, day.month, day.day).difference(DateTime.utc(day.year, 1, 1)).inDays;
  final seed = day.year * 1000 + dayOfYear;
  // Simple LCG so the pick looks random but is stable for the whole day.
  final r = (seed * 1103515245 + 12345) & 0x7fffffff;
  return (r % QuranRepository.totalAyahs) + 1;
}

/// Deterministic "verse of the day" (changes once per day).
final verseOfTheDayProvider = Provider<int>((ref) => verseOfTheDayFor(DateTime.now()));

/// The kind of device the app runs on; main() overrides it after asking the
/// platform. Watches get the compact interface in features/watch.
final deviceFormProvider = Provider<DeviceForm>((ref) => const DeviceForm());

/// The person using the app; required to administer masjid profiles.
class Profile {
  const Profile({required this.name, required this.email, this.role = ''});
  final String name;
  final String email;
  final String role;
}

class ProfileNotifier extends Notifier<Profile?> {
  static const _key = 'profile';

  @override
  Profile? build() {
    final v = Storage.settings.get(_key);
    if (v is Map && v['email'] is String && (v['email'] as String).isNotEmpty) {
      return Profile(name: (v['name'] as String?) ?? '', email: v['email'] as String, role: (v['role'] as String?) ?? '');
    }
    return null;
  }

  void save(Profile p) {
    state = p;
    Storage.settings.put(_key, {'name': p.name, 'email': p.email, 'role': p.role});
  }

  void clear() {
    state = null;
    Storage.settings.delete(_key);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, Profile?>(ProfileNotifier.new);
