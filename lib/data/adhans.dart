/// Adhan recordings. Every file here is under a licence that allows
/// redistribution (CC0 or CC BY-SA 4.0, from Wikimedia Commons); the
/// originals were converted to mono MP3 and are served from the app's own
/// site so that iOS can play them too. Keep `author`, `license` and
/// `sourceUrl` with each entry: CC BY-SA requires that credit to be shown.
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

  /// A Fajr adhan (with "as-salatu khayrun min an-nawm").
  final bool fajr;

  String get fileName => '$id.mp3';
}

const _base = 'https://salimjemai.github.io/MushafPlus/audio/adhan/';

const adhans = <Adhan>[
  Adhan(
    id: 'commons_aaqib_azeez',
    name: 'Aaqib Azeez',
    place: 'Wikimedia Commons',
    url: '${_base}commons_aaqib_azeez.mp3',
    seconds: 87,
    author: 'Atcovi',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:The_Adhan_-_Muslim_Call_to_Prayer_-_Aaqib_Azeez.mp3',
  ),
  Adhan(
    id: 'commons_andrewler',
    name: 'Adhan · recording 2',
    place: 'Wikimedia Commons',
    url: '${_base}commons_andrewler.mp3',
    seconds: 183,
    author: 'Andrewler',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Azan.ogg',
  ),
  Adhan(
    id: 'commons_adam_synagda',
    name: 'Adhan · recording 3',
    place: 'Wikimedia Commons',
    url: '${_base}commons_adam_synagda.mp3',
    seconds: 154,
    author: 'Adam-synagda',
    license: 'CC0 1.0',
    licenseUrl: 'https://creativecommons.org/publicdomain/zero/1.0/',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Beautiful_adhan.ogg',
  ),
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
