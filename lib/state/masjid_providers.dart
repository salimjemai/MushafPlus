import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/geocoding_service.dart';
import '../data/masjid.dart';
import '../data/prayer_times.dart';
import '../data/storage.dart';

final geocodingServiceProvider = Provider<GeocodingService>((ref) => GeocodingService());

class MasjidsNotifier extends Notifier<List<Masjid>> {
  static const _selectedKey = 'selectedMasjid';

  @override
  List<Masjid> build() {
    final list = Storage.masjids.values.whereType<Map>().map(Masjid.fromMap).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Masjid? byId(String? id) {
    if (id == null) return null;
    for (final m in state) {
      if (m.id == id) return m;
    }
    return null;
  }

  Future<void> save(Masjid m) async {
    await Storage.masjids.put(m.id, m.toMap());
    state = build();
    if (Storage.settings.get(_selectedKey) == null) select(m.id);
  }

  Future<void> remove(String id) async {
    await Storage.masjids.delete(id);
    state = build();
    if (Storage.settings.get(_selectedKey) == id) {
      Storage.settings.put(_selectedKey, state.firstOrNull?.id);
      ref.invalidate(selectedMasjidIdProvider);
    }
  }

  void select(String id) {
    Storage.settings.put(_selectedKey, id);
    ref.invalidate(selectedMasjidIdProvider);
  }
}

final masjidsProvider = NotifierProvider<MasjidsNotifier, List<Masjid>>(MasjidsNotifier.new);

final selectedMasjidIdProvider = Provider<String?>((ref) {
  final stored = Storage.settings.get(MasjidsNotifier._selectedKey) as String?;
  final list = ref.watch(masjidsProvider);
  if (stored != null && list.any((m) => m.id == stored)) return stored;
  return list.firstOrNull?.id;
});

final selectedMasjidProvider = Provider<Masjid?>((ref) {
  final id = ref.watch(selectedMasjidIdProvider);
  return ref.watch(masjidsProvider).where((m) => m.id == id).firstOrNull;
});

PrayerCriteria criteriaFor(Masjid m) {
  tz.Location location;
  try {
    location = tz.getLocation(m.timezone);
  } catch (_) {
    location = tz.UTC;
  }
  return PrayerCriteria(
    latitude: m.latitude,
    longitude: m.longitude,
    location: location,
    methodId: m.methodId,
    asrHanafi: m.asrHanafi,
    dhuhrOffsetMinutes: m.dhuhrOffsetMinutes,
    maghribOffsetMinutes: m.maghribOffsetMinutes,
    adjustments: m.adjustments,
  );
}

/// Prayer times of [masjid] for a local calendar date.
PrayerTimes prayerTimesFor(Masjid masjid, DateTime date) => computePrayerTimes(criteriaFor(masjid), date);

/// Iqama time (minutes since midnight, masjid local) for a prayer, if any.
int? iqamaMinutes(Masjid masjid, PrayerTimes times, Prayer prayer) {
  final rule = masjid.iqama[prayer];
  if (rule == null || rule.mode == IqamaMode.none) return null;
  if (rule.mode == IqamaMode.fixed) return rule.fixedMinutes;
  final t = times[prayer];
  return t.hour * 60 + t.minute + rule.offsetMinutes;
}

/// "Now" in the masjid's own time zone.
tz.TZDateTime nowAt(Masjid masjid) {
  try {
    return tz.TZDateTime.now(tz.getLocation(masjid.timezone));
  } catch (_) {
    return tz.TZDateTime.now(tz.UTC);
  }
}
