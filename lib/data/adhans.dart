/// Adhan recordings served by the Internet Archive (CORS-enabled, direct
/// download). Durations are from the archive's file metadata.
class Adhan {
  const Adhan({
    required this.id,
    required this.name,
    required this.place,
    required this.url,
    required this.seconds,
    this.fajr = false,
  });

  final String id;
  final String name; // muezzin or recording title
  final String place; // city / mosque / maqam
  final String url;
  final int seconds;

  /// A Fajr adhan (with "as-salatu khayrun min an-nawm").
  final bool fajr;

  String get fileName => '$id.mp3';
}

const _sunnah = 'https://archive.org/download/adhans_sunnah/';
const _alafasy = 'https://archive.org/download/azan-alafasy/';

const adhans = <Adhan>[
  Adhan(id: 'makkah', name: 'Masjid al-Haram', place: 'Makkah', url: '${_sunnah}adhan_makkah.mp3', seconds: 201),
  Adhan(id: 'makkah_fajr_ali_mullah', name: 'Sheikh Ali Mullah (Fajr)', place: 'Makkah', fajr: true,
      url: 'https://archive.org/download/MakkahFajrAdhan6913SheikhAliMullah/Makkah%20Fajr%20Adhan%206-9-13%20Sheikh%20Ali%20Mullah.mp3', seconds: 243),
  Adhan(id: 'madina', name: 'Masjid an-Nabawi', place: 'Madinah', url: '${_sunnah}adhan_madina.mp3', seconds: 96),
  Adhan(id: 'madina_1952', name: 'Masjid an-Nabawi (1952 recording)', place: 'Madinah', url: '${_sunnah}adhan_madina_1952.mp3', seconds: 172),
  Adhan(id: 'mishari', name: 'Mishary Rashid Alafasy', place: 'Kuwait', url: '${_sunnah}adhan_mishari.mp3', seconds: 157),
  Adhan(id: 'mishari_fajr', name: 'Mishary Rashid Alafasy (Fajr)', place: 'Kuwait', fajr: true, url: '${_sunnah}adhan_morning_mishari.mp3', seconds: 263),
  Adhan(id: 'alafasy_hejaz', name: 'Alafasy — maqam Hijaz', place: 'Kuwait', url: '${_alafasy}azan-hejaz-2013-other.mp3', seconds: 187),
  Adhan(id: 'alafasy_hejaz_fajr', name: 'Alafasy — maqam Hijaz (Fajr)', place: 'Kuwait', fajr: true, url: '${_alafasy}azan-hejaz-2013-al-fajr.mp3', seconds: 221),
  Adhan(id: 'alafasy_nahawand', name: 'Alafasy — maqam Nahawand', place: 'Kuwait', url: '${_alafasy}azan-nahawand-2014-other.mp3', seconds: 258),
  Adhan(id: 'alafasy_rast', name: 'Alafasy — maqam Rast', place: 'Kuwait', url: '${_alafasy}azan-rast-2014-other.mp3', seconds: 179),
  Adhan(id: 'alafasy_saba', name: 'Alafasy — maqam Saba', place: 'Kuwait', url: '${_alafasy}azan-saba-2014-other.mp3', seconds: 182),
  Adhan(id: 'alafasy_bayati', name: 'Alafasy — maqam Bayati', place: 'Kuwait', url: '${_alafasy}azan-bayaty-2014-other.mp3', seconds: 176),
  Adhan(id: 'alafasy_kurd', name: 'Alafasy — maqam Kurd', place: 'Kuwait', url: '${_alafasy}azan-kurd-2008-other.mp3', seconds: 237),
  Adhan(id: 'abdul_baset', name: 'Abdul Basit Abdus-Samad', place: 'Egypt', url: '${_sunnah}adhan_abdul_baset.mp3', seconds: 238),
  Adhan(id: 'nasser_al_qatami', name: 'Nasser al-Qatami', place: 'Saudi Arabia', url: '${_sunnah}adhan_nasser_al_qatami.mp3', seconds: 132),
  Adhan(id: 'islam_sobhi', name: 'Islam Sobhi', place: 'Egypt', url: '${_sunnah}islam_sobhi.mp3', seconds: 173),
  Adhan(id: 'salman_utaybi', name: 'Salman al-Utaybi', place: 'Saudi Arabia', url: '${_sunnah}salman_utaybi.mp3', seconds: 233),
  Adhan(id: 'tareq_mohammad', name: 'Tareq Mohammad', place: 'Egypt', url: '${_sunnah}Azan_Tareq_Mohammad.mp3', seconds: 207),
  Adhan(id: 'majid_pashaii', name: 'Majid Pashaii', place: 'Iran', url: '${_sunnah}Athan_Majid_Pashaii.mp3', seconds: 224),
  Adhan(id: 'egypt', name: 'Egyptian style', place: 'Cairo', url: '${_sunnah}adhan_egypt.mp3', seconds: 183),
  Adhan(id: 'halab', name: 'Aleppo style', place: 'Halab', url: '${_sunnah}adhan_halab.mp3', seconds: 223),
  Adhan(id: 'kurtish', name: 'Molana Kurtish', place: 'Turkey', url: '${_sunnah}athan_molana_kurtish.mp3', seconds: 188),
  Adhan(id: 'iqamah_alafasy', name: 'Iqamah — Alafasy', place: 'Kuwait', url: '${_alafasy}eqamah-al-salah.mp3', seconds: 46),
];

Adhan adhanById(String id) => adhans.firstWhere((a) => a.id == id, orElse: () => adhans.first);

/// The adhan to use for a given prayer: the chosen one, or its Fajr variant
/// when one exists for the same muezzin.
Adhan adhanFor(String chosenId, {required bool fajr}) {
  final chosen = adhanById(chosenId);
  if (!fajr) return chosen;
  final base = chosen.id.replaceAll('_fajr', '');
  return adhans.where((a) => a.fajr && a.id.startsWith(base)).firstOrNull ?? chosen;
}
