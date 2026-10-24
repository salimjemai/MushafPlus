import 'package:flutter/foundation.dart';

import 'prayer_times.dart';

/// How a masjid sets the iqama for one prayer.
enum IqamaMode { none, fixed, afterAdhan }

@immutable
class IqamaRule {
  const IqamaRule({this.mode = IqamaMode.none, this.fixedMinutes = 0, this.offsetMinutes = 15});

  final IqamaMode mode;

  /// Minutes since midnight for a fixed iqama time (e.g. 6:00 am = 360).
  final int fixedMinutes;

  /// Minutes after the adhan time.
  final int offsetMinutes;

  Map<String, dynamic> toMap() => {'mode': mode.index, 'fixed': fixedMinutes, 'offset': offsetMinutes};

  factory IqamaRule.fromMap(Map<dynamic, dynamic>? m) {
    if (m == null) return const IqamaRule();
    return IqamaRule(
      mode: IqamaMode.values[(m['mode'] as int?) ?? 0],
      fixedMinutes: (m['fixed'] as int?) ?? 0,
      offsetMinutes: (m['offset'] as int?) ?? 15,
    );
  }

  IqamaRule copyWith({IqamaMode? mode, int? fixedMinutes, int? offsetMinutes}) => IqamaRule(
        mode: mode ?? this.mode,
        fixedMinutes: fixedMinutes ?? this.fixedMinutes,
        offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      );
}

@immutable
class JumuahService {
  const JumuahService({required this.minutes, this.label = '', this.khutbahMinutes});

  /// Prayer time as minutes since midnight.
  final int minutes;

  /// e.g. "English khutbah", "Hall B", "Sheikh Ahmad".
  final String label;

  /// Optional khutbah start, minutes since midnight.
  final int? khutbahMinutes;

  Map<String, dynamic> toMap() => {'m': minutes, 'l': label, if (khutbahMinutes != null) 'k': khutbahMinutes};

  factory JumuahService.fromMap(Map<dynamic, dynamic> m) => JumuahService(
        minutes: m['m'] as int,
        label: (m['l'] as String?) ?? '',
        khutbahMinutes: m['k'] as int?,
      );
}

@immutable
class Masjid {
  const Masjid({
    required this.id,
    required this.name,
    this.street = '',
    this.city = '',
    this.state = '',
    this.postalCode = '',
    this.countryCode = '',
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.methodId = 'isna',
    this.asrHanafi = false,
    this.dhuhrOffsetMinutes = 0,
    this.maghribOffsetMinutes = 0,
    this.adjustments = const {},
    this.iqama = const {},
    this.jumuah = const [],
    this.hijriAdjustment = 0,
  });

  final String id;
  final String name;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String timezone; // IANA id
  final String methodId;
  final bool asrHanafi;
  final int dhuhrOffsetMinutes;
  final int maghribOffsetMinutes;
  final Map<Prayer, int> adjustments;
  final Map<Prayer, IqamaRule> iqama;
  final List<JumuahService> jumuah;
  final int hijriAdjustment;

  String get addressLine {
    final parts = [street, city, state, postalCode, countryCode].where((p) => p.trim().isNotEmpty);
    return parts.join(', ');
  }

  Masjid copyWith({
    String? name,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? countryCode,
    double? latitude,
    double? longitude,
    String? timezone,
    String? methodId,
    bool? asrHanafi,
    int? dhuhrOffsetMinutes,
    int? maghribOffsetMinutes,
    Map<Prayer, int>? adjustments,
    Map<Prayer, IqamaRule>? iqama,
    List<JumuahService>? jumuah,
    int? hijriAdjustment,
  }) {
    return Masjid(
      id: id,
      name: name ?? this.name,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      methodId: methodId ?? this.methodId,
      asrHanafi: asrHanafi ?? this.asrHanafi,
      dhuhrOffsetMinutes: dhuhrOffsetMinutes ?? this.dhuhrOffsetMinutes,
      maghribOffsetMinutes: maghribOffsetMinutes ?? this.maghribOffsetMinutes,
      adjustments: adjustments ?? this.adjustments,
      iqama: iqama ?? this.iqama,
      jumuah: jumuah ?? this.jumuah,
      hijriAdjustment: hijriAdjustment ?? this.hijriAdjustment,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'street': street,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'countryCode': countryCode,
        'lat': latitude,
        'lng': longitude,
        'tz': timezone,
        'method': methodId,
        'asrHanafi': asrHanafi,
        'dhuhrOffset': dhuhrOffsetMinutes,
        'maghribOffset': maghribOffsetMinutes,
        'adjustments': {for (final e in adjustments.entries) e.key.name: e.value},
        'iqama': {for (final e in iqama.entries) e.key.name: e.value.toMap()},
        'jumuah': jumuah.map((j) => j.toMap()).toList(),
        'hijriAdjustment': hijriAdjustment,
      };

  factory Masjid.fromMap(Map<dynamic, dynamic> m) {
    Prayer? prayerByName(String n) {
      for (final p in Prayer.values) {
        if (p.name == n) return p;
      }
      return null;
    }

    final adjustments = <Prayer, int>{};
    ((m['adjustments'] as Map?) ?? const {}).forEach((k, v) {
      final p = prayerByName(k as String);
      if (p != null) adjustments[p] = v as int;
    });
    final iqama = <Prayer, IqamaRule>{};
    ((m['iqama'] as Map?) ?? const {}).forEach((k, v) {
      final p = prayerByName(k as String);
      if (p != null) iqama[p] = IqamaRule.fromMap(v as Map?);
    });
    return Masjid(
      id: m['id'] as String,
      name: (m['name'] as String?) ?? 'My masjid',
      street: (m['street'] as String?) ?? '',
      city: (m['city'] as String?) ?? '',
      state: (m['state'] as String?) ?? '',
      postalCode: (m['postalCode'] as String?) ?? '',
      countryCode: (m['countryCode'] as String?) ?? '',
      latitude: (m['lat'] as num).toDouble(),
      longitude: (m['lng'] as num).toDouble(),
      timezone: (m['tz'] as String?) ?? 'UTC',
      methodId: (m['method'] as String?) ?? 'isna',
      asrHanafi: (m['asrHanafi'] as bool?) ?? false,
      dhuhrOffsetMinutes: (m['dhuhrOffset'] as int?) ?? 0,
      maghribOffsetMinutes: (m['maghribOffset'] as int?) ?? 0,
      adjustments: adjustments,
      iqama: iqama,
      jumuah: ((m['jumuah'] as List?) ?? const []).map((j) => JumuahService.fromMap(j as Map)).toList(),
      hijriAdjustment: (m['hijriAdjustment'] as int?) ?? 0,
    );
  }
}

String formatMinutes(int minutesSinceMidnight, {bool use24h = false}) {
  final h = (minutesSinceMidnight ~/ 60) % 24;
  final m = minutesSinceMidnight % 60;
  if (use24h) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  final suffix = h >= 12 ? 'PM' : 'AM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} $suffix';
}
