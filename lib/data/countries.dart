/// ISO 3166-1 alpha-2 codes with English short names, for the masjid form:
/// people type a country name, the geocoder wants a code.
const countries = <String, String>{
  'AF': 'Afghanistan', 'AL': 'Albania', 'DZ': 'Algeria', 'AS': 'American Samoa', 'AD': 'Andorra', 'AO': 'Angola',
  'AI': 'Anguilla', 'AG': 'Antigua and Barbuda', 'AR': 'Argentina', 'AM': 'Armenia', 'AW': 'Aruba', 'AU': 'Australia',
  'AT': 'Austria', 'AZ': 'Azerbaijan', 'BS': 'Bahamas', 'BH': 'Bahrain', 'BD': 'Bangladesh', 'BB': 'Barbados',
  'BY': 'Belarus', 'BE': 'Belgium', 'BZ': 'Belize', 'BJ': 'Benin', 'BM': 'Bermuda', 'BT': 'Bhutan', 'BO': 'Bolivia',
  'BA': 'Bosnia and Herzegovina', 'BW': 'Botswana', 'BR': 'Brazil', 'BN': 'Brunei', 'BG': 'Bulgaria', 'BF': 'Burkina Faso',
  'BI': 'Burundi', 'CV': 'Cabo Verde', 'KH': 'Cambodia', 'CM': 'Cameroon', 'CA': 'Canada', 'KY': 'Cayman Islands',
  'CF': 'Central African Republic', 'TD': 'Chad', 'CL': 'Chile', 'CN': 'China', 'CO': 'Colombia', 'KM': 'Comoros',
  'CG': 'Congo', 'CD': 'Congo (Democratic Republic)', 'CR': 'Costa Rica', 'CI': "Côte d'Ivoire", 'HR': 'Croatia',
  'CU': 'Cuba', 'CW': 'Curaçao', 'CY': 'Cyprus', 'CZ': 'Czechia', 'DK': 'Denmark', 'DJ': 'Djibouti', 'DM': 'Dominica',
  'DO': 'Dominican Republic', 'EC': 'Ecuador', 'EG': 'Egypt', 'SV': 'El Salvador', 'GQ': 'Equatorial Guinea',
  'ER': 'Eritrea', 'EE': 'Estonia', 'SZ': 'Eswatini', 'ET': 'Ethiopia', 'FJ': 'Fiji', 'FI': 'Finland', 'FR': 'France',
  'GF': 'French Guiana', 'PF': 'French Polynesia', 'GA': 'Gabon', 'GM': 'Gambia', 'GE': 'Georgia', 'DE': 'Germany',
  'GH': 'Ghana', 'GI': 'Gibraltar', 'GR': 'Greece', 'GL': 'Greenland', 'GD': 'Grenada', 'GP': 'Guadeloupe', 'GU': 'Guam',
  'GT': 'Guatemala', 'GG': 'Guernsey', 'GN': 'Guinea', 'GW': 'Guinea-Bissau', 'GY': 'Guyana', 'HT': 'Haiti',
  'HN': 'Honduras', 'HK': 'Hong Kong', 'HU': 'Hungary', 'IS': 'Iceland', 'IN': 'India', 'ID': 'Indonesia', 'IR': 'Iran',
  'IQ': 'Iraq', 'IE': 'Ireland', 'IM': 'Isle of Man', 'IL': 'Israel', 'IT': 'Italy', 'JM': 'Jamaica', 'JP': 'Japan',
  'JE': 'Jersey', 'JO': 'Jordan', 'KZ': 'Kazakhstan', 'KE': 'Kenya', 'KI': 'Kiribati', 'XK': 'Kosovo', 'KW': 'Kuwait',
  'KG': 'Kyrgyzstan', 'LA': 'Laos', 'LV': 'Latvia', 'LB': 'Lebanon', 'LS': 'Lesotho', 'LR': 'Liberia', 'LY': 'Libya',
  'LI': 'Liechtenstein', 'LT': 'Lithuania', 'LU': 'Luxembourg', 'MO': 'Macao', 'MG': 'Madagascar', 'MW': 'Malawi',
  'MY': 'Malaysia', 'MV': 'Maldives', 'ML': 'Mali', 'MT': 'Malta', 'MH': 'Marshall Islands', 'MQ': 'Martinique',
  'MR': 'Mauritania', 'MU': 'Mauritius', 'YT': 'Mayotte', 'MX': 'Mexico', 'FM': 'Micronesia', 'MD': 'Moldova',
  'MC': 'Monaco', 'MN': 'Mongolia', 'ME': 'Montenegro', 'MS': 'Montserrat', 'MA': 'Morocco', 'MZ': 'Mozambique',
  'MM': 'Myanmar', 'NA': 'Namibia', 'NR': 'Nauru', 'NP': 'Nepal', 'NL': 'Netherlands', 'NC': 'New Caledonia',
  'NZ': 'New Zealand', 'NI': 'Nicaragua', 'NE': 'Niger', 'NG': 'Nigeria', 'KP': 'North Korea', 'MK': 'North Macedonia',
  'NO': 'Norway', 'OM': 'Oman', 'PK': 'Pakistan', 'PW': 'Palau', 'PS': 'Palestine', 'PA': 'Panama', 'PG': 'Papua New Guinea',
  'PY': 'Paraguay', 'PE': 'Peru', 'PH': 'Philippines', 'PL': 'Poland', 'PT': 'Portugal', 'PR': 'Puerto Rico', 'QA': 'Qatar',
  'RE': 'Réunion', 'RO': 'Romania', 'RU': 'Russia', 'RW': 'Rwanda', 'KN': 'Saint Kitts and Nevis', 'LC': 'Saint Lucia',
  'VC': 'Saint Vincent and the Grenadines', 'WS': 'Samoa', 'SM': 'San Marino', 'ST': 'Sao Tome and Principe',
  'SA': 'Saudi Arabia', 'SN': 'Senegal', 'RS': 'Serbia', 'SC': 'Seychelles', 'SL': 'Sierra Leone', 'SG': 'Singapore',
  'SX': 'Sint Maarten', 'SK': 'Slovakia', 'SI': 'Slovenia', 'SB': 'Solomon Islands', 'SO': 'Somalia', 'ZA': 'South Africa',
  'KR': 'South Korea', 'SS': 'South Sudan', 'ES': 'Spain', 'LK': 'Sri Lanka', 'SD': 'Sudan', 'SR': 'Suriname',
  'SE': 'Sweden', 'CH': 'Switzerland', 'SY': 'Syria', 'TW': 'Taiwan', 'TJ': 'Tajikistan', 'TZ': 'Tanzania',
  'TH': 'Thailand', 'TL': 'Timor-Leste', 'TG': 'Togo', 'TO': 'Tonga', 'TT': 'Trinidad and Tobago', 'TN': 'Tunisia',
  'TR': 'Türkiye', 'TM': 'Turkmenistan', 'TC': 'Turks and Caicos Islands', 'TV': 'Tuvalu', 'UG': 'Uganda', 'UA': 'Ukraine',
  'AE': 'United Arab Emirates', 'GB': 'United Kingdom', 'US': 'United States', 'UY': 'Uruguay', 'UZ': 'Uzbekistan',
  'VU': 'Vanuatu', 'VE': 'Venezuela', 'VN': 'Vietnam', 'VG': 'Virgin Islands (British)', 'VI': 'Virgin Islands (U.S.)',
  'YE': 'Yemen', 'ZM': 'Zambia', 'ZW': 'Zimbabwe',
};

/// Other spellings people type, mapped to codes.
const _aliases = <String, String>{
  'usa': 'US', 'united states of america': 'US', 'america': 'US', 'uk': 'GB', 'great britain': 'GB', 'england': 'GB',
  'britain': 'GB', 'uae': 'AE', 'emirates': 'AE', 'ksa': 'SA', 'turkey': 'TR', 'tunisie': 'TN', 'tunis': 'TN',
  'maroc': 'MA', 'algerie': 'DZ', 'algérie': 'DZ', 'egypte': 'EG', 'égypte': 'EG', 'deutschland': 'DE', 'españa': 'ES',
  'italia': 'IT', 'nederland': 'NL', 'holland': 'NL', 'belgique': 'BE', 'belgië': 'BE', 'suisse': 'CH', 'schweiz': 'CH',
  'sverige': 'SE', 'norge': 'NO', 'danmark': 'DK', 'suomi': 'FI', 'polska': 'PL', 'türkiye': 'TR', 'turkiye': 'TR',
  'ivory coast': 'CI', 'czech republic': 'CZ', 'south korea': 'KR', 'korea': 'KR', 'russia': 'RU', 'russian federation': 'RU',
  'iran': 'IR', 'syria': 'SY', 'palestine': 'PS', 'bosnia': 'BA', 'macedonia': 'MK', 'burma': 'MM', 'brunei': 'BN',
  'tanzania': 'TZ', 'congo': 'CG', 'drc': 'CD', 'cape verde': 'CV', 'swaziland': 'SZ', 'east timor': 'TL',
  'تونس': 'TN', 'المغرب': 'MA', 'الجزائر': 'DZ', 'مصر': 'EG', 'السعودية': 'SA', 'الإمارات': 'AE', 'قطر': 'QA',
  'الكويت': 'KW', 'البحرين': 'BH', 'عمان': 'OM', 'الأردن': 'JO', 'لبنان': 'LB', 'سوريا': 'SY', 'العراق': 'IQ',
  'اليمن': 'YE', 'ليبيا': 'LY', 'السودان': 'SD', 'فلسطين': 'PS', 'تركيا': 'TR', 'باكستان': 'PK', 'إندونيسيا': 'ID',
  'ماليزيا': 'MY', 'فرنسا': 'FR', 'ألمانيا': 'DE', 'بريطانيا': 'GB', 'أمريكا': 'US', 'كندا': 'CA',
};

String _norm(String s) => s.trim().toLowerCase().replaceAll(RegExp(r'[.\-_]'), ' ').replaceAll(RegExp(r'\s+'), ' ');

/// Resolves a typed country (code, English name, common alias or a prefix
/// of a name) to an ISO code, or null when nothing matches.
String? countryCodeFor(String input) {
  final t = _norm(input);
  if (t.isEmpty) return null;
  final upper = t.toUpperCase();
  if (t.length == 2 && countries.containsKey(upper)) return upper;
  if (_aliases.containsKey(t)) return _aliases[t];
  for (final e in countries.entries) {
    if (_norm(e.value) == t) return e.key;
  }
  final prefix = countries.entries.where((e) => _norm(e.value).startsWith(t)).toList();
  if (prefix.length == 1) return prefix.first.key;
  final contains = countries.entries.where((e) => _norm(e.value).contains(t)).toList();
  if (contains.length == 1) return contains.first.key;
  return null;
}

String countryNameFor(String? code) => code == null ? '' : (countries[code.toUpperCase()] ?? code);

/// Suggestions for an autocomplete field.
Iterable<String> countrySuggestions(String input) {
  final t = _norm(input);
  if (t.isEmpty) return const [];
  final starts = <String>[];
  final within = <String>[];
  for (final e in countries.entries) {
    final n = _norm(e.value);
    if (n.startsWith(t) || e.key.toLowerCase() == t) {
      starts.add(e.value);
    } else if (n.contains(t)) {
      within.add(e.value);
    }
  }
  for (final a in _aliases.entries) {
    if (a.key.startsWith(t)) {
      final name = countries[a.value];
      if (name != null && !starts.contains(name) && !within.contains(name)) within.add(name);
    }
  }
  return [...starts, ...within].take(8);
}
