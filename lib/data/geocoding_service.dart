import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A resolved place with precise coordinates.
class GeoResult {
  const GeoResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.city,
    this.state,
    this.postcode,
    this.country,
    this.countryCode,
  });

  final double latitude;
  final double longitude;
  final String displayName;
  final String? city;
  final String? state;
  final String? postcode;
  final String? country;
  final String? countryCode;
}

/// Free, keyless geocoding: OpenStreetMap Nominatim for full addresses,
/// Zippopotam for postal codes, Open-Meteo for the IANA time zone.
class GeocodingService {
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Map<String, String> get _headers => kIsWeb
      ? const {}
      : const {'User-Agent': 'QuranPlus/1.0 (https://github.com/salimjemai/QuranPlus)'};

  /// Full-text address search. Returns up to five candidates, best first.
  Future<List<GeoResult>> searchAddress(String query, {String? countryCode}) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'limit': '5',
      'addressdetails': '1',
      if (countryCode != null && countryCode.isNotEmpty) 'countrycodes': countryCode.toLowerCase(),
    });
    final res = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) throw GeocodingException('Address lookup failed (${res.statusCode})');
    final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      final a = (m['address'] as Map<String, dynamic>?) ?? const {};
      return GeoResult(
        latitude: double.parse(m['lat'] as String),
        longitude: double.parse(m['lon'] as String),
        displayName: m['display_name'] as String,
        city: (a['city'] ?? a['town'] ?? a['village'] ?? a['municipality'] ?? a['county']) as String?,
        state: a['state'] as String?,
        postcode: a['postcode'] as String?,
        country: a['country'] as String?,
        countryCode: (a['country_code'] as String?)?.toUpperCase(),
      );
    }).toList();
  }

  /// Postal-code lookup (centre of the ZIP area).
  Future<GeoResult?> lookupPostalCode(String countryCode, String postalCode) async {
    final uri = Uri.https('api.zippopotam.us', '/${countryCode.toLowerCase()}/${postalCode.trim()}');
    final res = await _client.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) throw GeocodingException('Postal code lookup failed (${res.statusCode})');
    final m = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final places = m['places'] as List;
    if (places.isEmpty) return null;
    final p = places.first as Map<String, dynamic>;
    return GeoResult(
      latitude: double.parse(p['latitude'] as String),
      longitude: double.parse(p['longitude'] as String),
      displayName: '${p['place name']}, ${p['state']}, ${m['country']} ${m['post code']}',
      city: p['place name'] as String?,
      state: p['state'] as String?,
      postcode: m['post code'] as String?,
      country: m['country'] as String?,
      countryCode: (m['country abbreviation'] as String?)?.toUpperCase(),
    );
  }

  /// Reverse geocode device coordinates to an address.
  Future<GeoResult?> reverse(double lat, double lng) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': '$lat',
      'lon': '$lng',
      'format': 'jsonv2',
      'addressdetails': '1',
    });
    final res = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) return null;
    final m = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (m['error'] != null) return null;
    final a = (m['address'] as Map<String, dynamic>?) ?? const {};
    return GeoResult(
      latitude: lat,
      longitude: lng,
      displayName: (m['display_name'] as String?) ?? '$lat, $lng',
      city: (a['city'] ?? a['town'] ?? a['village'] ?? a['municipality'] ?? a['county']) as String?,
      state: a['state'] as String?,
      postcode: a['postcode'] as String?,
      country: a['country'] as String?,
      countryCode: (a['country_code'] as String?)?.toUpperCase(),
    );
  }

  /// IANA time zone id for coordinates, e.g. "America/New_York".
  Future<String> timezoneFor(double lat, double lng) async {
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '$lat',
        'longitude': '$lng',
        'timezone': 'auto',
        'forecast_days': '1',
      });
      final res = await _client.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final m = jsonDecode(res.body) as Map<String, dynamic>;
        final id = m['timezone'] as String?;
        if (id != null && id.isNotEmpty) return id;
      }
    } catch (_) {}
    final uri = Uri.https('timeapi.io', '/api/timezone/coordinate', {'latitude': '$lat', 'longitude': '$lng'});
    final res = await _client.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) throw GeocodingException('Time zone lookup failed (${res.statusCode})');
    final m = jsonDecode(res.body) as Map<String, dynamic>;
    return m['timeZone'] as String;
  }
}

class GeocodingException implements Exception {
  GeocodingException(this.message);
  final String message;
  @override
  String toString() => message;
}
