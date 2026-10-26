import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_plus/data/prayer_times.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Expected values come from DeenTime's IsnaCalculator fixtures (Cedar Park,
/// TX; ISNA; Hanafi Asr; Dhuhr +5 min; Maghrib +1 min). DeenTime truncates to
/// the minute while Quran+ rounds, so a one-minute tolerance is allowed.
void main() {
  setUpAll(tzdata.initializeTimeZones);

  PrayerCriteria cedarPark() => PrayerCriteria(
        latitude: 30.5052,
        longitude: -97.8203,
        location: tz.getLocation('America/Chicago'),
        methodId: 'isna',
        asrHanafi: true,
        dhuhrOffsetMinutes: 5,
        maghribOffsetMinutes: 1,
      );

  void expectClose(tz.TZDateTime actual, String hhmm) {
    final parts = hhmm.split(':').map(int.parse).toList();
    final expectedMinutes = parts[0] * 60 + parts[1];
    final actualMinutes = actual.hour * 60 + actual.minute;
    expect((actualMinutes - expectedMinutes).abs(), lessThanOrEqualTo(1),
        reason: 'expected $hhmm got ${actual.hour}:${actual.minute.toString().padLeft(2, '0')}');
  }

  test('matches DeenTime for a winter day (CST)', () {
    final t = computePrayerTimes(cedarPark(), DateTime(2026, 1, 15));
    expectClose(t[Prayer.fajr], '06:18');
    expectClose(t[Prayer.sunrise], '07:28');
    expectClose(t[Prayer.dhuhr], '12:45');
    expectClose(t[Prayer.asr], '16:15');
    expectClose(t[Prayer.maghrib], '17:53');
    expectClose(t[Prayer.isha], '19:02');
  });

  test('matches DeenTime for a summer day (CDT, DST applied per date)', () {
    final t = computePrayerTimes(cedarPark(), DateTime(2026, 6, 21));
    expectClose(t[Prayer.fajr], '05:10');
    expectClose(t[Prayer.sunrise], '06:29');
    expectClose(t[Prayer.dhuhr], '13:37');
    expectClose(t[Prayer.asr], '18:27');
    expectClose(t[Prayer.maghrib], '20:37');
    expectClose(t[Prayer.isha], '21:55');
  });

  test('Umm al-Qura uses Isha = sunset + 90 minutes', () {
    final c = PrayerCriteria(
      latitude: 21.4225,
      longitude: 39.8262,
      location: tz.getLocation('Asia/Riyadh'),
      methodId: 'ummalqura',
    );
    final t = computePrayerTimes(c, DateTime(2026, 3, 1));
    expect(t[Prayer.isha].difference(t[Prayer.maghrib]).inMinutes, 90);
    expect(t[Prayer.fajr].isBefore(t[Prayer.sunrise]), isTrue);
    expect(t[Prayer.asr].isAfter(t[Prayer.dhuhr]), isTrue);
  });

  test('qibla from New York points east-northeast', () {
    final q = qiblaDirection(40.7128, -74.0060);
    expect(q, closeTo(58.5, 1.0));
  });

  test('hijri conversion is within a day of the known date', () {
    // 1 Ramadan 1447 AH ≈ 18-19 February 2026.
    final h = hijriFromGregorian(DateTime(2026, 2, 19));
    expect(h.year, 1447);
    expect(h.month, 9);
    expect(h.day, inInclusiveRange(1, 2));
  });
}
