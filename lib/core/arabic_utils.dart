/// Helpers for Arabic text: diacritics stripping, digit conversion, ayah markers.
library;

const _arabicIndicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// Converts 123 -> ١٢٣
String toArabicDigits(int n) =>
    n.toString().split('').map((c) => _arabicIndicDigits[int.parse(c)]).join();

/// The Unicode "end of ayah" ornament followed by the ayah number.
String ayahEndMarker(int n) => '۝${toArabicDigits(n)}';

final _diacritics = RegExp(
  '[ؐ-ًؚ-ٰٟۖ-ۜ۟-۪ۨ-ۭـ۩]',
);

/// Strips tashkeel and normalises letter variants so that searches typed on a
/// plain keyboard match the fully vocalised Uthmani text.
String normalizeArabic(String s) {
  var out = s.replaceAll(_diacritics, '');
  out = out
      .replaceAll(RegExp('[ٱآأإ]'), 'ا') // alef variants
      .replaceAll('ى', 'ي') // ى -> ي
      .replaceAll('ی', 'ي') // Persian yeh -> ي
      .replaceAll('ة', 'ه') // ة -> ه
      .replaceAll('ک', 'ك'); // Persian kaf -> ك
  return out;
}

/// True if the string contains Arabic letters.
bool containsArabic(String s) => RegExp('[؀-ۿ]').hasMatch(s);

const bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

/// Human-readable language names for ISO 639-1 codes used by alquran.cloud.
const languageNames = <String, String>{
  'am': 'Amharic',
  'ar': 'Arabic',
  'az': 'Azerbaijani',
  'ba': 'Bashkir',
  'ber': 'Berber (Amazigh)',
  'bg': 'Bulgarian',
  'bn': 'Bengali',
  'bs': 'Bosnian',
  'ce': 'Chechen',
  'cs': 'Czech',
  'de': 'German',
  'dv': 'Dhivehi',
  'en': 'English',
  'es': 'Spanish',
  'fa': 'Persian',
  'fr': 'French',
  'ha': 'Hausa',
  'hi': 'Hindi',
  'id': 'Indonesian',
  'it': 'Italian',
  'ja': 'Japanese',
  'ko': 'Korean',
  'ku': 'Kurdish',
  'ml': 'Malayalam',
  'ms': 'Malay',
  'my': 'Burmese',
  'nl': 'Dutch',
  'no': 'Norwegian',
  'pl': 'Polish',
  'ps': 'Pashto',
  'pt': 'Portuguese',
  'ro': 'Romanian',
  'ru': 'Russian',
  'sd': 'Sindhi',
  'si': 'Sinhala',
  'so': 'Somali',
  'sq': 'Albanian',
  'sv': 'Swedish',
  'sw': 'Swahili',
  'ta': 'Tamil',
  'tg': 'Tajik',
  'th': 'Thai',
  'tr': 'Turkish',
  'tt': 'Tatar',
  'ug': 'Uyghur',
  'ur': 'Urdu',
  'uz': 'Uzbek',
  'zh': 'Chinese',
};

String languageName(String code) => languageNames[code] ?? code.toUpperCase();

/// Languages for which quran.com offers word-by-word meanings.
const wordByWordLanguages = <String, String>{
  'en': 'English',
  'ur': 'Urdu',
  'id': 'Indonesian',
  'bn': 'Bengali',
  'tr': 'Turkish',
  'fa': 'Persian',
  'ru': 'Russian',
  'hi': 'Hindi',
  'de': 'German',
  'ta': 'Tamil',
  'inh': 'Ingush',
};
