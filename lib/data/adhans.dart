/// Adhan recordings. Every entry is under a licence that allows
/// redistribution: CC0, Creative Commons Public Domain Mark or CC BY-SA, from
/// Wikimedia Commons and the Internet Archive (all files are hosted on the
/// app site under web/audio/adhan so playback never depends on them), and only items whose
/// uploader is plausibly the recorder (live/field recordings, muezzins
/// uploading their own adhan). Studio recordings of well-known reciters
/// re-uploaded by third parties are deliberately left out. Keep `author`,
/// `license` and `sourceUrl` with each entry: the credit is shown in the app.
class Adhan {
  const Adhan({
    required this.id,
    required this.name,
    required this.place,
    required this.url,
    required this.seconds,
    required this.author,
    required this.license,
    required this.licenseUrl,
    required this.sourceUrl,
    this.group,
    this.fajr = false,
  });

  final String id;
  final String name; // muezzin or recording title
  final String place; // city / mosque / archive
  final String url;
  final int seconds;

  /// Credit line pieces (author as given by the source, licence name/url,
  /// page the file came from).
  final String author;
  final String license;
  final String licenseUrl;
  final String sourceUrl;

  /// Recordings of the same muezzin/mosque share a group, so a Fajr variant
  /// can be picked automatically.
  final String? group;

  /// A Fajr adhan (with "as-salatu khayrun min an-nawm").
  final bool fajr;

  String get fileName => '$id.mp3';
}

const _site = 'https://salimjemai.github.io/MushafPlus/audio/adhan/';
const _cc0 = 'CC0 1.0';
const _cc0Url = 'https://creativecommons.org/publicdomain/zero/1.0/';
const _pdm = 'Public Domain Mark';
const _pdmUrl = 'https://creativecommons.org/publicdomain/mark/1.0/';
const _bySa = 'CC BY-SA 4.0';
const _bySaUrl = 'https://creativecommons.org/licenses/by-sa/4.0/';

const adhans = <Adhan>[
  // ---- Makkah (live recordings released CC0 by their recorders) ----
  Adhan(
    id: 'makkah_ramadan',
    group: 'makkah',
    name: 'Masjid al-Haram · Ramadan',
    place: 'Makkah',
    url: '${_site}makkah_ramadan.mp3',
    seconds: 283,
    author: 'haramainstaff (Internet Archive)',
    license: _cc0,
    licenseUrl: _cc0Url,
    sourceUrl: 'https://archive.org/details/MakkahAzan-ramadan',
  ),
  Adhan(
    id: 'makkah_fajr_2011',
    group: 'makkah',
    fajr: true,
    name: 'Masjid al-Haram · Fajr (1 Jan 2011)',
    place: 'Makkah',
    url: '${_site}makkah_fajr_2011.mp3',
    seconds: 314,
    author: 'haramainrecordings (Internet Archive)',
    license: _cc0,
    licenseUrl: _cc0Url,
    sourceUrl: 'https://archive.org/details/MakkahFajrAdhaanJan1st2011',
  ),
  Adhan(
    id: 'makkah_fajr_28may',
    group: 'makkah2',
    fajr: true,
    name: 'Masjid al-Haram · Fajr (28 May)',
    place: 'Makkah',
    url: '${_site}makkah_fajr_28may.mp3',
    seconds: 294,
    author: 'forrecordings (Internet Archive)',
    license: _cc0,
    licenseUrl: _cc0Url,
    sourceUrl: 'https://archive.org/details/28MayFajrAdhanMakkah',
  ),
  // ---- Doha, Qatar (field recordings 2013–2014) ----
  Adhan(
    id: 'doha_fajr',
    group: 'doha',
    fajr: true,
    name: 'Doha · Fajr',
    place: 'Qatar',
    url: '${_site}doha_fajr.mp3',
    seconds: 217,
    author: 'Abd al-Rahman (Internet Archive)',
    license: _pdm,
    licenseUrl: _pdmUrl,
    sourceUrl: 'https://archive.org/details/adhan.recordings.from.doha.qatar',
  ),
  Adhan(
    id: 'doha_dhuhr',
    group: 'doha',
    name: 'Doha · Dhuhr',
    place: 'Qatar',
    url: '${_site}doha_dhuhr.mp3',
    seconds: 179,
    author: 'Abd al-Rahman (Internet Archive)',
    license: _pdm,
    licenseUrl: _pdmUrl,
    sourceUrl: 'https://archive.org/details/adhan.recordings.from.doha.qatar',
  ),
  Adhan(
    id: 'doha_asr',
    group: 'doha',
    name: 'Doha · Asr',
    place: 'Qatar',
    url: '${_site}doha_asr.mp3',
    seconds: 187,
    author: 'Abd al-Rahman (Internet Archive)',
    license: _pdm,
    licenseUrl: _pdmUrl,
    sourceUrl: 'https://archive.org/details/adhan.recordings.from.doha.qatar',
  ),
  Adhan(
    id: 'doha_maghrib',
    group: 'doha',
    name: 'Doha · Maghrib',
    place: 'Qatar',
    url: '${_site}doha_maghrib.mp3',
    seconds: 199,
    author: 'Abd al-Rahman (Internet Archive)',
    license: _pdm,
    licenseUrl: _pdmUrl,
    sourceUrl: 'https://archive.org/details/adhan.recordings.from.doha.qatar',
  ),
  Adhan(
    id: 'doha_isha',
    group: 'doha',
    name: 'Doha · Isha',
    place: 'Qatar',
    url: '${_site}doha_isha.mp3',
    seconds: 181,
    author: 'Abd al-Rahman (Internet Archive)',
    license: _pdm,
    licenseUrl: _pdmUrl,
    sourceUrl: 'https://archive.org/details/adhan.recordings.from.doha.qatar',
  ),
  // ---- Muezzins who published their own adhan ----
  Adhan(
    id: 'fouad_adan',
    group: 'fouad',
    name: 'Fouad Adan',
    place: 'Morocco',
    url: '${_site}fouad_adan.mp3',
    seconds: 146,
    author: 'Fouad Adan (Internet Archive)',
    license: _pdm,
    licenseUrl: _pdmUrl,
    sourceUrl: 'https://archive.org/details/AdanAlfajrFouadAdan',
  ),
  Adhan(
    id: 'fouad_adan_fajr',
    group: 'fouad',
    fajr: true,
    name: 'Fouad Adan · Fajr',
    place: 'Morocco',
    url: '${_site}fouad_adan_fajr.mp3',
    seconds: 137,
    author: 'Fouad Adan (Internet Archive)',
    license: _pdm,
    licenseUrl: _pdmUrl,
    sourceUrl: 'https://archive.org/details/AdanAlfajrFouadAdan',
  ),
  Adhan(
    id: 'asim_javed_icr',
    name: 'Asim Javed · Jumu\'ah first adhan',
    place: 'Islamic Centre, 2024',
    url: '${_site}icr_asim_javed.mp3',
    seconds: 220,
    author: 'Asim Javed (Internet Archive)',
    license: _cc0,
    licenseUrl: _cc0Url,
    sourceUrl: 'https://archive.org/details/icr-friday-prayer-1st-adhan-17th-may-2024-9th-dhul-qadah-1445-by-asim-javed',
  ),
  Adhan(
    id: 'mirza_isha',
    name: 'Moazzam Mirza · Isha',
    place: 'Muhammadi Masjid, Ahmedabad',
    url: '${_site}asim_javed_icr.mp3',
    seconds: 275,
    author: 'Moazzam Mirza (Internet Archive)',
    license: _pdm,
    licenseUrl: _pdmUrl,
    sourceUrl: 'https://archive.org/details/IshaAzanByMoazzambegMirza07092013',
  ),
  Adhan(
    id: 'naif_isha',
    name: 'Naif · Isha',
    place: 'Internet Archive, 2009',
    url: '${_site}naif_isha.mp3',
    seconds: 237,
    author: 'sheikhmaahir (Internet Archive)',
    license: 'Public domain',
    licenseUrl: 'https://creativecommons.org/publicdomain/mark/1.0/',
    sourceUrl: 'https://archive.org/details/AzanNaifIshaAzan',
  ),
  Adhan(
    id: 'klcc_dhuhr',
    name: 'Masjid KLCC · Dhuhr',
    place: 'Kuala Lumpur',
    url: '${_site}klcc_dhuhr.mp3',
    seconds: 187,
    author: 'Bryce Fegley (Internet Archive)',
    license: _cc0,
    licenseUrl: _cc0Url,
    sourceUrl: 'https://archive.org/details/AzanZhurMasjidKlcc',
  ),
  // ---- Wikimedia Commons (converted to MP3, hosted on the app site) ----
  Adhan(
    id: 'commons_aaqib_azeez',
    name: 'Aaqib Azeez',
    place: 'Wikimedia Commons',
    url: '${_site}commons_aaqib_azeez.mp3',
    seconds: 87,
    author: 'Atcovi',
    license: _bySa,
    licenseUrl: _bySaUrl,
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:The_Adhan_-_Muslim_Call_to_Prayer_-_Aaqib_Azeez.mp3',
  ),
  Adhan(
    id: 'commons_andrewler',
    name: 'Adhan · Andrewler',
    place: 'Wikimedia Commons',
    url: '${_site}commons_andrewler.mp3',
    seconds: 183,
    author: 'Andrewler',
    license: _bySa,
    licenseUrl: _bySaUrl,
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Azan.ogg',
  ),
  Adhan(
    id: 'commons_adam_synagda',
    name: 'Adhan · Adam-synagda',
    place: 'Wikimedia Commons',
    url: '${_site}commons_adam_synagda.mp3',
    seconds: 154,
    author: 'Adam-synagda',
    license: _cc0,
    licenseUrl: _cc0Url,
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Beautiful_adhan.ogg',
  ),
];

Adhan adhanById(String id) => adhans.firstWhere((a) => a.id == id, orElse: () => adhans.first);

/// The adhan to use for a given prayer: the chosen one, or the Fajr
/// recording of the same group when there is one.
Adhan adhanFor(String chosenId, {required bool fajr}) {
  final chosen = adhanById(chosenId);
  if (!fajr || chosen.fajr || chosen.group == null) return chosen;
  return adhans.where((a) => a.fajr && a.group == chosen.group).firstOrNull ?? chosen;
}
