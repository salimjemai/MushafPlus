import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../state/masjid_providers.dart';
import '../state/providers.dart';
import 'masjid.dart';
import 'prayer_times.dart';
import 'quran_repository.dart';
import 'translation_service.dart';
import 'watch_bridge.dart';

/// Days of prayer times and verses the watch receives in one go, so the
/// complication stays correct for a week without the phone.
const watchPayloadDays = 7;

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Everything the Apple Watch app and its complication show, as plain JSON:
/// the active place, a week of prayer times (epoch seconds, so time zones
/// need no handling on the watch) and a week of verses of the day.
///
/// [translations] maps a surah number to that surah's translated ayahs when
/// one is available; verses without one are sent in Arabic only.
Map<String, Object?> buildWatchPayload({
  required Masjid? place,
  required QuranRepository quran,
  required DateTime now,
  Map<int, List<String>> translations = const {},
  Map<String, String> labels = const {},
  int days = watchPayloadDays,
}) {
  final dayList = <Map<String, Object?>>[];
  if (place != null) {
    final local = nowAt(place);
    for (var d = 0; d < days; d++) {
      final date = DateTime(local.year, local.month, local.day + d);
      final t = prayerTimesFor(place, date);
      dayList.add({
        'date': _isoDate(date),
        for (final p in Prayer.values) p.name: t[p].millisecondsSinceEpoch ~/ 1000,
      });
    }
  }
  final verses = <Map<String, Object?>>[];
  for (var d = 0; d < days; d++) {
    final date = DateTime(now.year, now.month, now.day + d);
    final ayah = quran.ayah(verseOfTheDayFor(date));
    final surah = quran.surah(ayah.surah);
    final tr = translations[ayah.surah];
    verses.add({
      'date': _isoDate(date),
      'ref': ayah.key,
      'surah': surah.englishName,
      'surahArabic': surah.name,
      'arabic': ayah.text,
      if (tr != null && tr.length >= ayah.numberInSurah) 'translation': tr[ayah.numberInSurah - 1],
    });
  }
  return {
    'version': 1,
    'generatedAt': now.millisecondsSinceEpoch ~/ 1000,
    if (place != null) ...{
      'place': place.name,
      'timezone': place.timezone,
      'latitude': place.latitude,
      'longitude': place.longitude,
    },
    'days': dayList,
    'verses': verses,
    'labels': labels,
  };
}

/// Interface strings in the phone's language, so the watch app needs no
/// localisation of its own.
Map<String, String> watchLabels(AppLocalizations l) => {
      'fajr': l.fajr,
      'sunrise': l.sunrise,
      'dhuhr': l.dhuhr,
      'asr': l.asr,
      'maghrib': l.maghrib,
      'isha': l.isha,
      'prayerTimes': l.prayerTimes,
      'in': l.inDuration('').trim(),
      'qibla': l.qibla,
      'facingQibla': l.facingQibla,
      'compassWaiting': l.compassWaiting,
      'compassUnavailable': l.compassUnavailable,
      'left': l.left,
      'right': l.right,
      'useLocationShort': l.useLocationShort,
      'tasbih': l.tasbih,
      'verseOfTheDay': l.verseOfTheDay,
      'reciteAndCheck': l.reciteAndCheck,
      'listening': l.listening,
      'tapMicToStart': l.tapMicToStart,
      'stop': l.stop,
      'reset': l.reset,
    };

Timer? _pending;

/// Sends the payload to the paired watch shortly (coalescing bursts of
/// changes). A no-op on platforms without a watch bridge.
void scheduleWatchSync(WidgetRef ref) {
  if (!watchBridgeSupported) return;
  _pending?.cancel();
  _pending = Timer(const Duration(seconds: 2), () => syncWatch(ref));
}

/// Builds and publishes the payload now.
Future<void> syncWatch(WidgetRef ref) async {
  if (!watchBridgeSupported) return;
  final quran = ref.read(repositoryProvider).value;
  if (quran == null) return;
  final place = ref.read(activePlaceProvider);
  final edition = ref.read(settingsProvider).translations.firstOrNull ?? TranslationService.defaultEdition;
  final service = ref.read(translationServiceProvider);
  final now = DateTime.now();
  final translations = <int, List<String>>{};
  for (var d = 0; d < watchPayloadDays; d++) {
    final ayah = quran.ayah(verseOfTheDayFor(DateTime(now.year, now.month, now.day + d)));
    if (translations.containsKey(ayah.surah)) continue;
    final s = quran.surah(ayah.surah);
    try {
      translations[ayah.surah] = await service.forSurah(edition, ayah.surah, startAyah: s.startAyah, count: s.numberOfAyahs);
    } catch (_) {
      // Offline and not cached: the watch shows the Arabic alone.
    }
  }
  final localeTag = ref.read(settingsProvider).locale ?? PlatformDispatcher.instance.locale.languageCode;
  Map<String, String> labels = const {};
  try {
    labels = watchLabels(lookupAppLocalizations(Locale(localeTag)));
  } catch (_) {
    // Unsupported locale: the watch falls back to English.
  }
  final payload = buildWatchPayload(place: place, quran: quran, now: now, translations: translations, labels: labels);
  await publishToWatch(jsonEncode(payload));
}
