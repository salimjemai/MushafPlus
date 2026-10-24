/// Verse-by-verse reciters served by everyayah.com (which allows playback from
/// web browsers). Files are named SSSAAA.mp3 inside each reciter's folder.
class Reciter {
  const Reciter(this.id, this.name, {this.language = 'ar', this.note});

  /// The everyayah.com folder, also used as the stored settings value.
  final String id;
  final String name;
  final String language;
  final String? note;

  String ayahUrl(int surah, int ayahInSurah) {
    final s = surah.toString().padLeft(3, '0');
    final a = ayahInSurah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$id/$s$a.mp3';
  }
}

const reciters = <Reciter>[
  Reciter('Alafasy_128kbps', 'Mishary Rashid Alafasy'),
  Reciter('Abdurrahmaan_As-Sudais_192kbps', 'Abdurrahman As-Sudais'),
  Reciter('Husary_128kbps', 'Mahmoud Khalil Al-Husary'),
  Reciter('Husary_128kbps_Mujawwad', 'Al-Husary (Mujawwad)'),
  Reciter('Husary_Muallim_128kbps', 'Al-Husary (Muallim, for learners)'),
  Reciter('Minshawy_Murattal_128kbps', 'Mohamed Siddiq El-Minshawi'),
  Reciter('Minshawy_Mujawwad_192kbps', 'El-Minshawi (Mujawwad)'),
  Reciter('Abdul_Basit_Murattal_192kbps', 'Abdul Basit Abdul Samad'),
  Reciter('Abdul_Basit_Mujawwad_128kbps', 'Abdul Basit (Mujawwad)'),
  Reciter('MaherAlMuaiqly128kbps', 'Maher Al Muaiqly'),
  Reciter('Hudhaify_128kbps', 'Ali Al-Hudhaify'),
  Reciter('Saood_ash-Shuraym_128kbps', 'Saud Ash-Shuraym'),
  Reciter('Abu_Bakr_Ash-Shaatree_128kbps', 'Abu Bakr Ash-Shaatree'),
  Reciter('Muhammad_Ayyoub_128kbps', 'Muhammad Ayyoub'),
  Reciter('Abdullah_Basfar_192kbps', 'Abdullah Basfar'),
  Reciter('ahmed_ibn_ali_al_ajamy_128kbps', 'Ahmed Al-Ajamy'),
  Reciter('Hani_Rifai_192kbps', 'Hani Ar-Rifai'),
  Reciter('Muhammad_Jibreel_128kbps', 'Muhammad Jibreel'),
  Reciter('Yasser_Ad-Dussary_128kbps', 'Yasser Ad-Dussary'),
  Reciter('Nasser_Alqatami_128kbps', 'Nasser Al-Qatami'),
  Reciter('Salah_Al_Budair_128kbps', 'Salah Al-Budair'),
  Reciter('Muhsin_Al_Qasim_192kbps', 'Muhsin Al-Qasim'),
  Reciter('Khaalid_Abdullaah_al-Qahtaanee_192kbps', 'Khalid Al-Qahtani'),
  Reciter('Mohammad_al_Tablaway_128kbps', 'Mohammad Al-Tablawi'),
  Reciter('Ghamadi_40kbps', 'Saad Al-Ghamdi'),
  Reciter('Fares_Abbad_64kbps', 'Fares Abbad'),
  Reciter('Ayman_Sowaid_64kbps', 'Ayman Sowaid'),
  Reciter('warsh/warsh_Abdul_Basit_128kbps', 'Abdul Basit (Warsh riwayah)', note: 'Warsh'),
  Reciter('English/Sahih_Intnl_Ibrahim_Walk_192kbps', 'Ibrahim Walk (English, Saheeh Intl.)', language: 'en'),
  Reciter('MultiLanguage/Basfar_Walk_192kbps', 'Basfar + Walk (Arabic then English)', language: 'ar+en'),
  Reciter('translations/urdu_shamshad_ali_khan_46kbps', 'Shamshad Ali Khan (Urdu)', language: 'ur'),
];

const defaultReciterId = 'Alafasy_128kbps';

Reciter reciterById(String id) =>
    reciters.firstWhere((r) => r.id == id, orElse: () => reciters.first);
