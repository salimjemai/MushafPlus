import 'dart:math' as math;

import 'package:timezone/timezone.dart' as tz;

/// Prayer-time calculation, ported from DeenTime's IsnaCalculator and
/// extended with a few more conventions. All results are rounded to the
/// minute in the masjid's own IANA time zone, so DST is handled per date.

class CalculationMethod {
  const CalculationMethod(this.id, this.name, this.fajrAngle, this.ishaAngle, {this.ishaMinutesAfterSunset});
  final String id;
  final String name;
  final double fajrAngle;
  final double ishaAngle;

  /// When set, Isha is sunset + this many minutes instead of a solar angle.
  final int? ishaMinutesAfterSunset;
}

const calculationMethods = <CalculationMethod>[
  CalculationMethod('isna', 'ISNA (North America)', 15, 15),
  CalculationMethod('mwl', 'Muslim World League', 18, 17),
  CalculationMethod('egyptian', 'Egyptian General Authority', 19.5, 17.5),
  CalculationMethod('karachi', 'University of Karachi', 18, 18),
  CalculationMethod('ummalqura', 'Umm al-Qura (Makkah)', 18.5, 0, ishaMinutesAfterSunset: 90),
  CalculationMethod('gulf', 'Gulf Region', 19.5, 0, ishaMinutesAfterSunset: 90),
  CalculationMethod('kuwait', 'Kuwait', 18, 17.5),
  CalculationMethod('qatar', 'Qatar', 18, 0, ishaMinutesAfterSunset: 90),
  CalculationMethod('singapore', 'Singapore (MUIS)', 20, 18),
  CalculationMethod('turkey', 'Turkey (Diyanet)', 18, 17),
  CalculationMethod('france', 'France (UOIF 12°)', 12, 12),
  CalculationMethod('russia', 'Russia (Spiritual Administration)', 16, 15),
  CalculationMethod('tehran', 'Tehran (Geophysics Institute)', 17.7, 14),
  CalculationMethod('jafari', 'Jafari (Shia Ithna-Ashari)', 16, 14),
];

CalculationMethod methodById(String id) =>
    calculationMethods.firstWhere((m) => m.id == id, orElse: () => calculationMethods.first);

enum Prayer { fajr, sunrise, dhuhr, asr, maghrib, isha }

extension PrayerX on Prayer {
  String get label => switch (this) {
        Prayer.fajr => 'Fajr',
        Prayer.sunrise => 'Sunrise',
        Prayer.dhuhr => 'Dhuhr',
        Prayer.asr => 'Asr',
        Prayer.maghrib => 'Maghrib',
        Prayer.isha => 'Isha',
      };
  String get arabic => switch (this) {
        Prayer.fajr => 'الفجر',
        Prayer.sunrise => 'الشروق',
        Prayer.dhuhr => 'الظهر',
        Prayer.asr => 'العصر',
        Prayer.maghrib => 'المغرب',
        Prayer.isha => 'العشاء',
      };
  bool get isSalah => this != Prayer.sunrise;
}

class PrayerCriteria {
  const PrayerCriteria({
    required this.latitude,
    required this.longitude,
    required this.location,
    this.methodId = 'isna',
    this.asrHanafi = false,
    this.dhuhrOffsetMinutes = 0,
    this.maghribOffsetMinutes = 0,
    this.adjustments = const {},
  });

  final double latitude;
  final double longitude;
  final tz.Location location;
  final String methodId;
  final bool asrHanafi;

  /// Minutes after true solar noon (zawal) for Dhuhr; many masjids use 1-5.
  final int dhuhrOffsetMinutes;

  /// Minutes after sunset for Maghrib.
  final int maghribOffsetMinutes;

  /// Extra per-prayer minute corrections.
  final Map<Prayer, int> adjustments;
}

class PrayerTimes {
  const PrayerTimes({required this.date, required this.times});
  final DateTime date; // local calendar date
  final Map<Prayer, tz.TZDateTime> times;

  tz.TZDateTime operator [](Prayer p) => times[p]!;

  /// The next prayer (not sunrise) after [now], or null if Isha has passed.
  Prayer? nextAfter(DateTime now) {
    for (final p in Prayer.values) {
      if (!p.isSalah) continue;
      if (times[p]!.isAfter(now)) return p;
    }
    return null;
  }
}

double _rad(double d) => d * math.pi / 180;
double _deg(double r) => r * 180 / math.pi;
double _fixAngle(double a) {
  a = a - 360 * (a / 360).floor();
  return a < 0 ? a + 360 : a;
}

double _fixHour(double h) {
  h = h - 24 * (h / 24).floor();
  return h < 0 ? h + 24 : h;
}

/// Julian day for the given civil date at 0h UT.
double julianDay(int year, int month, int day) {
  var y = year;
  var m = month;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  final a = (y / 100).floor();
  final b = 2 - a + (a / 4).floor();
  return (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + day + b - 1524.5;
}

PrayerTimes computePrayerTimes(PrayerCriteria c, DateTime date) {
  final year = date.year, month = date.month, day = date.day;
  final lat = c.latitude;
  final lng = c.longitude;

  final d = julianDay(year, month, day) - 2451545.0;
  final g = _rad(_fixAngle(357.529 + 0.98560028 * d));
  final q = _fixAngle(280.459 + 0.98564736 * d);
  final l = _rad(_fixAngle(q + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g)));
  final e = _rad(23.439 - 0.00000036 * d);
  final decl = math.asin(math.sin(e) * math.sin(l));
  var ra = _deg(math.atan2(math.cos(e) * math.sin(l), math.cos(l))) / 15.0;
  ra = _fixHour(ra);
  var eqt = q / 15.0 - ra;
  if (eqt > 12) eqt -= 24;
  if (eqt < -12) eqt += 24;

  final noon = 12.0 - lng / 15.0 - eqt; // UTC decimal hours

  double hourAngle(double altitudeDeg) {
    final cosH = (math.sin(_rad(altitudeDeg)) - math.sin(_rad(lat)) * math.sin(decl)) /
        (math.cos(_rad(lat)) * math.cos(decl));
    if (cosH <= -1) return 12.0;
    if (cosH >= 1) return 0.0;
    return _deg(math.acos(cosH)) / 15.0;
  }

  final method = methodById(c.methodId);
  final fajr = noon - hourAngle(-method.fajrAngle);
  final sunrise = noon - hourAngle(-0.8333);
  final dhuhr = noon + c.dhuhrOffsetMinutes / 60.0;
  final shadow = c.asrHanafi ? 2 : 1;
  final asrAlt = _deg(math.atan(1.0 / (shadow + math.tan((decl - _rad(lat)).abs()))));
  final asr = noon + hourAngle(asrAlt);
  final sunset = noon + hourAngle(-0.8333);
  final maghrib = sunset + c.maghribOffsetMinutes / 60.0;
  final isha = method.ishaMinutesAfterSunset != null
      ? sunset + method.ishaMinutesAfterSunset! / 60.0
      : noon + hourAngle(-method.ishaAngle);

  tz.TZDateTime local(double utcHours, Prayer p) {
    final adjust = c.adjustments[p] ?? 0;
    final minutes = (utcHours * 60).round() + adjust;
    final utc = DateTime.utc(year, month, day).add(Duration(minutes: minutes));
    return tz.TZDateTime.from(utc, c.location);
  }

  return PrayerTimes(
    date: DateTime(year, month, day),
    times: {
      Prayer.fajr: local(fajr, Prayer.fajr),
      Prayer.sunrise: local(sunrise, Prayer.sunrise),
      Prayer.dhuhr: local(dhuhr, Prayer.dhuhr),
      Prayer.asr: local(asr, Prayer.asr),
      Prayer.maghrib: local(maghrib, Prayer.maghrib),
      Prayer.isha: local(isha, Prayer.isha),
    },
  );
}

/// Great-circle bearing from the given point to the Kaaba, in degrees from
/// true north (0-360).
double qiblaDirection(double latitude, double longitude) {
  const kaabaLat = 21.4225;
  const kaabaLng = 39.8262;
  final lat1 = _rad(latitude), lat2 = _rad(kaabaLat);
  final dLng = _rad(kaabaLng - longitude);
  final y = math.sin(dLng) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
  return _fixAngle(_deg(math.atan2(y, x)));
}

// ---------------------------------------------------------------------------
// Hijri calendar (tabular / Kuwaiti algorithm, +-1 day from moon sighting)
// ---------------------------------------------------------------------------

class HijriDate {
  const HijriDate(this.year, this.month, this.day);
  final int year;
  final int month;
  final int day;

  static const monthNames = [
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani", 'Jumada al-Ula', 'Jumada al-Akhirah',
    'Rajab', "Sha'ban", 'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
  ];

  String get monthName => monthNames[month - 1];
  @override
  String toString() => '$day $monthName $year AH';
}

HijriDate hijriFromGregorian(DateTime date, {int adjustmentDays = 0}) {
  final d = date.add(Duration(days: adjustmentDays));
  var y = d.year, m = d.month;
  final day = d.day;
  if (m < 3) {
    y -= 1;
    m += 12;
  }
  final a = (y / 100).floor();
  final b = 2 - a + (a / 4).floor();
  final jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + day + b - 1524;
  var l = jd - 1948440 + 10632;
  final n = ((l - 1) / 10631).floor();
  l = l - 10631 * n + 354;
  final j = ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
      (l / 5670).floor() * ((43 * l) / 15238).floor();
  l = l - ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() - (j / 16).floor() * ((15238 * j) / 43).floor() + 29;
  final hm = ((24 * l) / 709).floor();
  final hd = l - ((709 * hm) / 24).floor();
  final hy = 30 * n + j - 30;
  return HijriDate(hy, hm, hd);
}
