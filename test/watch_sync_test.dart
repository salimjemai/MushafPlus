import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_plus/data/masjid.dart';
import 'package:mushaf_plus/data/quran_repository.dart';
import 'package:mushaf_plus/data/watch_sync.dart';
import 'package:mushaf_plus/state/providers.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tzdata.initializeTimeZones);

  test('verse of the day is stable within a day and changes between days', () {
    final a = verseOfTheDayFor(DateTime(2026, 10, 28, 8));
    final b = verseOfTheDayFor(DateTime(2026, 10, 28, 22, 30));
    final c = verseOfTheDayFor(DateTime(2026, 10, 29, 8));
    expect(a, b);
    expect(a, inInclusiveRange(1, QuranRepository.totalAyahs));
    expect(c, inInclusiveRange(1, QuranRepository.totalAyahs));
    expect(a == c, isFalse);
  });

  test('watch payload carries a week of times, verses and labels', () async {
    final quran = await QuranRepository.load();
    const place = Masjid(
      id: 'test',
      name: 'Cedar Park',
      latitude: 30.5052,
      longitude: -97.8203,
      timezone: 'America/Chicago',
      methodId: 'isna',
    );
    final now = DateTime(2026, 10, 28, 9, 15);
    final payload = buildWatchPayload(
      place: place,
      quran: quran,
      now: now,
      translations: {quran.ayah(verseOfTheDayFor(now)).surah: List.filled(300, 'tr')},
      labels: const {'fajr': 'Fajr'},
    );

    expect(payload['place'], 'Cedar Park');
    expect(payload['timezone'], 'America/Chicago');
    final days = payload['days'] as List;
    expect(days, hasLength(watchPayloadDays));
    final first = days.first as Map;
    expect(first['date'], '2026-10-28');
    for (final key in ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha']) {
      expect(first[key], isA<int>(), reason: key);
    }
    expect((first['fajr'] as int) < (first['isha'] as int), isTrue);
    // Consecutive days are a day apart (DST-free week).
    final second = days[1] as Map;
    expect(((second['fajr'] as int) - (first['fajr'] as int)).abs() - 86400, inInclusiveRange(-600, 600));

    final verses = payload['verses'] as List;
    expect(verses, hasLength(watchPayloadDays));
    final today = verses.first as Map;
    expect(today['date'], '2026-10-28');
    expect(today['ref'], quran.ayah(verseOfTheDayFor(now)).key);
    expect(today['arabic'], isNotEmpty);
    expect(today['translation'], 'tr');
    expect((payload['labels'] as Map)['fajr'], 'Fajr');
  });

  test('watch payload without a place still carries the verses', () async {
    final quran = await QuranRepository.load();
    final payload = buildWatchPayload(place: null, quran: quran, now: DateTime(2026, 1, 1));
    expect(payload.containsKey('place'), isFalse);
    expect(payload['days'], isEmpty);
    expect(payload['verses'], hasLength(watchPayloadDays));
  });
}
