import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/masjid.dart';
import '../../data/region.dart';
import '../../state/masjid_providers.dart';
import '../../state/providers.dart';

/// Reads the device position, reverse-geocodes it and returns a place with
/// the time zone and the usual calculation method for that country.
Future<Masjid> locateDevice(WidgetRef ref, {String id = 'me', String? label}) async {
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    throw Exception('Location permission denied');
  }
  final pos = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  ).timeout(const Duration(seconds: 30));
  final geo = ref.read(geocodingServiceProvider);
  final place = await geo.reverse(pos.latitude, pos.longitude);
  final tzId = await geo.timezoneFor(pos.latitude, pos.longitude);
  final cc = place?.countryCode ?? ref.read(settingsProvider).region;
  return Masjid(
    id: id,
    name: label ?? (place?.city != null ? place!.city! : 'My location'),
    street: '',
    city: place?.city ?? '',
    state: place?.state ?? '',
    postalCode: place?.postcode ?? '',
    countryCode: cc ?? '',
    latitude: pos.latitude,
    longitude: pos.longitude,
    timezone: tzId,
    methodId: Region.methodFor(cc),
    asrHanafi: Region.hanafiFor(cc),
  );
}
