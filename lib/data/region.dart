import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:http/http.dart' as http;

import 'countries.dart';

/// Where the app is being used: an ISO country code chosen on first start
/// (from the network location, else the device locale) and changeable from
/// the flag in the top bar. It pre-fills the masjid form and picks the usual
/// prayer calculation method for that country.
class Region {
  Region._();

  /// Country code from a keyless IP lookup, falling back to the device
  /// locale's region. Null when nothing can be determined.
  static Future<String?> detect() async {
    for (final probe in [_geojs, _ipwho]) {
      try {
        final code = await probe().timeout(const Duration(seconds: 6));
        if (code != null && countries.containsKey(code)) return code;
      } catch (_) {}
    }
    return fromLocale();
  }

  static String? fromLocale() {
    for (final l in PlatformDispatcher.instance.locales) {
      final c = l.countryCode?.toUpperCase();
      if (c != null && countries.containsKey(c)) return c;
    }
    return null;
  }

  static Future<String?> _geojs() async {
    final res = await http.get(Uri.parse('https://get.geojs.io/v1/ip/country.json'));
    if (res.statusCode != 200) return null;
    final m = jsonDecode(res.body) as Map<String, dynamic>;
    return (m['country'] as String?)?.toUpperCase();
  }

  static Future<String?> _ipwho() async {
    final res = await http.get(Uri.parse('https://ipwho.is/?fields=country_code,success'));
    if (res.statusCode != 200) return null;
    final m = jsonDecode(res.body) as Map<String, dynamic>;
    if (m['success'] == false) return null;
    return (m['country_code'] as String?)?.toUpperCase();
  }

  /// Regional indicator flag for a country code (🇹🇳 for TN).
  static String flag(String? code) {
    if (code == null || code.length != 2) return '🌍';
    final c = code.toUpperCase();
    return String.fromCharCodes([0x1F1E6 + c.codeUnitAt(0) - 65, 0x1F1E6 + c.codeUnitAt(1) - 65]);
  }

  /// The calculation authority most masjids in that country follow.
  static String methodFor(String? code) => switch (code) {
        'US' || 'CA' || 'MX' => 'isna',
        'EG' || 'SD' || 'LY' || 'SY' || 'LB' || 'JO' || 'PS' || 'IQ' || 'YE' || 'SO' || 'DJ' || 'ET' || 'ER' => 'egyptian',
        'SA' => 'ummalqura',
        'AE' || 'OM' || 'BH' => 'gulf',
        'KW' => 'kuwait',
        'QA' => 'qatar',
        'PK' || 'IN' || 'BD' || 'AF' || 'LK' || 'NP' || 'MV' => 'karachi',
        'TR' || 'AZ' || 'XK' || 'BA' || 'AL' || 'MK' => 'turkey',
        'IR' => 'tehran',
        'SG' => 'singapore',
        'FR' || 'BE' || 'LU' || 'MC' => 'france',
        'RU' || 'KZ' || 'UZ' || 'TJ' || 'KG' || 'TM' || 'BY' || 'UA' => 'russia',
        _ => 'mwl', // Maghreb, Europe, Indonesia, Malaysia, Africa…
      };

  /// Hanafi asr where that is the common practice.
  static bool hanafiFor(String? code) => const {'PK', 'IN', 'BD', 'AF', 'TR', 'UZ', 'KZ', 'KG', 'TJ', 'TM', 'AZ', 'BA', 'AL', 'XK', 'MK'}.contains(code);
}
