/// Verse-by-verse reciters available on the islamic.network CDN, with the best
/// bitrate each one is published at (checked against the CDN).
class Reciter {
  const Reciter(this.id, this.name, this.bitrate, {this.language = 'ar'});
  final String id;
  final String name;
  final int bitrate;
  final String language;

  String ayahUrl(int globalAyah) =>
      'https://cdn.islamic.network/quran/audio/$bitrate/$id/$globalAyah.mp3';
}

const reciters = <Reciter>[
  Reciter('ar.alafasy', 'Mishary Rashid Alafasy', 128),
  Reciter('ar.abdurrahmaansudais', 'Abdurrahman As-Sudais', 192),
  Reciter('ar.husary', 'Mahmoud Khalil Al-Husary', 128),
  Reciter('ar.husarymujawwad', 'Al-Husary (Mujawwad)', 128),
  Reciter('ar.mahermuaiqly', 'Maher Al Muaiqly', 128),
  Reciter('ar.hudhaify', 'Ali Al-Hudhaify', 128),
  Reciter('ar.abdulsamad', 'Abdul Basit Abdul Samad', 64),
  Reciter('ar.shaatree', 'Abu Bakr Ash-Shaatree', 128),
  Reciter('ar.saoodshuraym', 'Saud Ash-Shuraym', 64),
  Reciter('ar.muhammadayyoub', 'Muhammad Ayyoub', 128),
  Reciter('ar.abdullahbasfar', 'Abdullah Basfar', 192),
  Reciter('ar.ahmedajamy', 'Ahmed Al-Ajamy', 128),
  Reciter('ar.hanirifai', 'Hani Ar-Rifai', 192),
  Reciter('ar.muhammadjibreel', 'Muhammad Jibreel', 128),
  Reciter('ar.aymanswoaid', 'Ayman Sowaid', 64),
  Reciter('en.walk', 'Ibrahim Walk (English)', 192, language: 'en'),
  Reciter('fr.leclerc', 'Youssouf Leclerc (French)', 128, language: 'fr'),
  Reciter('ur.khan', 'Shamshad Ali Khan (Urdu)', 64, language: 'ur'),
];

const defaultReciterId = 'ar.alafasy';

Reciter reciterById(String id) =>
    reciters.firstWhere((r) => r.id == id, orElse: () => reciters.first);
