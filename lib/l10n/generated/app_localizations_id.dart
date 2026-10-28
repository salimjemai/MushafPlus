// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Mushaf+';

  @override
  String get navRead => 'Baca';

  @override
  String get navHadith => 'Hadis';

  @override
  String get navPrayer => 'Salat';

  @override
  String get navSaved => 'Tersimpan';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get search => 'Cari';

  @override
  String get searchTheQuran => 'Cari di Al-Qur\'an';

  @override
  String get cancel => 'Batal';

  @override
  String get open => 'Buka';

  @override
  String get apply => 'Terapkan';

  @override
  String get save => 'Simpan';

  @override
  String get retry => 'Coba lagi';

  @override
  String get copy => 'Salin';

  @override
  String get share => 'Bagikan';

  @override
  String get clear => 'Hapus';

  @override
  String get remove => 'Hapus';

  @override
  String get download => 'Unduh';

  @override
  String get more => 'Lainnya';

  @override
  String get back => 'Kembali';

  @override
  String get loading => 'Memuat…';

  @override
  String get couldNotLoadQuran => 'Tidak dapat memuat data Al-Qur\'an.';

  @override
  String get continueReading => 'LANJUTKAN MEMBACA';

  @override
  String get startReading => 'MULAI MEMBACA';

  @override
  String ayahOfJuzPage(int ayah, int total, int juz, int page) {
    return 'Ayat $ayah dari $total · Juz $juz · Halaman $page';
  }

  @override
  String get verseOfTheDay => 'AYAT HARI INI';

  @override
  String get today => 'Hari ini';

  @override
  String dailyGoalTapToStartPlan(int goal) {
    return 'Target harian $goal ayat · ketuk untuk memulai rencana khatam';
  }

  @override
  String khatmOnTrack(int day, int days) {
    return 'Rencana khatam: sesuai jadwal · hari $day/$days';
  }

  @override
  String khatmBehind(int behind, int day, int days) {
    return 'Rencana khatam: tertinggal $behind ayat · hari $day/$days';
  }

  @override
  String get findSurahHint => 'Cari surah berdasarkan nama, arti, atau nomor';

  @override
  String get tabSurah => 'Surah';

  @override
  String get tabJuz => 'Juz';

  @override
  String get tabPage => 'Halaman';

  @override
  String get noSurahMatches => 'Tidak ada surah yang cocok.';

  @override
  String surahSubtitle(String meaning, int count, String type) {
    return '$meaning · $count ayat · $type';
  }

  @override
  String get meccan => 'Makkiyah';

  @override
  String get medinan => 'Madaniyah';

  @override
  String juzN(int n) {
    return 'Juz $n';
  }

  @override
  String juzStartsAt(String surah, int ayah, int count) {
    return 'Dimulai dari $surah, ayat $ayah · $count ayat';
  }

  @override
  String get jumpToSurah => 'Lompat ke surah';

  @override
  String pageN(int n) {
    return 'Halaman $n';
  }

  @override
  String get backToSurahs => 'Kembali ke daftar surah';

  @override
  String get openMushafHere => 'Buka Mushaf di surah ini';

  @override
  String get translations => 'Terjemahan';

  @override
  String get readingSettings => 'Pengaturan baca';

  @override
  String get playSurah => 'Putar surah';

  @override
  String get pauseRecitation => 'Jeda tilawah';

  @override
  String get memorizeThisSurah => 'Hafalkan surah ini';

  @override
  String get openInMushaf => 'Buka di Mushaf';

  @override
  String juzPage(int juz, int page) {
    return 'Juz $juz · Halaman $page';
  }

  @override
  String get wordByWord => 'Kata per kata';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get bookmark => 'Tandai';

  @override
  String get removeBookmark => 'Hapus penanda';

  @override
  String get bookmarkThisAyah => 'Tandai ayat ini';

  @override
  String get play => 'Putar';

  @override
  String get pause => 'Jeda';

  @override
  String get playFromThisAyah => 'Putar dari ayat ini';

  @override
  String get sajdahAyah => 'Ayat sajdah';

  @override
  String couldNotLoad(String name) {
    return 'Tidak dapat memuat $name';
  }

  @override
  String wordByWordOffline(String error) {
    return 'Kata per kata tidak tersedia offline ($error)';
  }

  @override
  String ayahN(int n) {
    return 'Ayat $n';
  }

  @override
  String get wordByWordSubtitle => 'Transliterasi dan arti setiap kata';

  @override
  String get tafsirSubtitle => 'Tafsir Ibnu Katsir dan lainnya';

  @override
  String get playRecitationFromHere => 'Putar tilawah dari sini';

  @override
  String get memorizeFromHere => 'Hafalkan dari sini';

  @override
  String get memorizeSubtitle =>
      'Sembunyikan kata, tampilkan satu per satu, ulangi tilawah';

  @override
  String get ayahCopied => 'Ayat disalin';

  @override
  String wordN(int n) {
    return 'Kata $n';
  }

  @override
  String get wordByWordNeedsInternet =>
      'Data kata per kata memerlukan koneksi internet saat pertama kali.';

  @override
  String get tafsirNeedsInternet =>
      'Tafsir memerlukan koneksi internet saat pertama kali.';

  @override
  String get viaQuranCom => 'via Quran.com';

  @override
  String get reciter => 'Qari';

  @override
  String get arabicSize => 'Ukuran teks Arab';

  @override
  String get translationSize => 'Ukuran terjemahan';

  @override
  String get amiriQuran => 'Amiri Quran';

  @override
  String get amiriNaskh => 'Amiri Naskh';

  @override
  String get showTransliteration => 'Tampilkan transliterasi';

  @override
  String get showTransliterationSubtitle =>
      'Pelafalan huruf Latin di bawah setiap ayat';

  @override
  String get wordByWordMode => 'Mode kata per kata';

  @override
  String get wordByWordModeSubtitle =>
      'Setiap kata dengan transliterasi dan artinya';

  @override
  String get wordMeaningsLanguage => 'Bahasa arti kata';

  @override
  String get tapAyahHint =>
      'Ketuk ayat untuk terjemahan, transliterasi, tafsir, dan kata per kata.';

  @override
  String get previousAyah => 'Ayat sebelumnya';

  @override
  String get nextAyah => 'Ayat berikutnya';

  @override
  String get stop => 'Berhenti';

  @override
  String get loop => 'ulang';

  @override
  String get searchHint => 'Arab, transliterasi, atau Inggris…';

  @override
  String get searchWholeQuran => 'Cari di seluruh Al-Qur\'an';

  @override
  String get searchHelp =>
      'Ketik Arab (dengan atau tanpa harakat), frasa transliterasi, atau kata Inggris. Hasil membuka ayat di pembaca.';

  @override
  String noAyahMatches(String query) {
    return 'Tidak ada ayat yang cocok dengan \"$query\"';
  }

  @override
  String resultsCount(String count) {
    return '$count hasil';
  }

  @override
  String get savedAyahs => 'Ayat tersimpan';

  @override
  String get noBookmarksYet => 'Belum ada penanda';

  @override
  String get noBookmarksHelp =>
      'Ketuk ikon penanda pada ayat saat membaca untuk menyimpannya di sini.';

  @override
  String get settings => 'Pengaturan';

  @override
  String get appearance => 'Tampilan';

  @override
  String get theme => 'Tema';

  @override
  String get arabicFont => 'Font Arab';

  @override
  String get language => 'Bahasa aplikasi';

  @override
  String get systemDefault => 'Bawaan sistem';

  @override
  String get recitation => 'Tilawah';

  @override
  String get recitationHelp =>
      'Audio diputar ayat per ayat dari everyayah.com. Ketuk putar pada ayat, atau \"Putar surah\" di kepala surah.';

  @override
  String get reading => 'Membaca';

  @override
  String get wordByWordSettingSubtitle =>
      'Tampilkan setiap kata dengan transliterasi dan artinya (diunduh sekali per surah)';

  @override
  String get defaultView => 'Tampilan bawaan';

  @override
  String get viewTranslation => 'Terjemahan';

  @override
  String get viewMushafBook => 'Mushaf';

  @override
  String get languages => 'Bahasa';

  @override
  String get arabicOnlyTapToAdd =>
      'Hanya Arab — ketuk untuk menambah terjemahan';

  @override
  String translationsAvailable(int count, int languages) {
    return '$count terjemahan dalam $languages bahasa tersedia. Masing-masing diunduh saat pertama membuka surah dan disimpan offline.';
  }

  @override
  String get storage => 'Penyimpanan';

  @override
  String get offlinePacks => 'Paket offline';

  @override
  String get offlinePacksSubtitle =>
      'Unduh terjemahan dan kata per kata untuk seluruh Al-Qur\'an';

  @override
  String get clearDownloadedData => 'Hapus data unduhan';

  @override
  String cachedDownloads(int count) {
    return '$count surah terunduh';
  }

  @override
  String get clearDownloadedDataQuestion => 'Hapus data unduhan?';

  @override
  String get clearDownloadedDataBody =>
      'Terjemahan dan data kata per kata akan diunduh lagi saat diperlukan. Penanda dan pengaturan tetap tersimpan.';

  @override
  String get downloadedDataCleared => 'Data unduhan dihapus';

  @override
  String get about => 'Tentang';

  @override
  String get versionBuiltWith => 'Versi 1.0.0 · Dibuat dengan Flutter';

  @override
  String get credits =>
      'Teks Arab: edisi Tanzil Utsmani. Terjemahan dan transliterasi: Al Quran Cloud. Kata per kata dan tafsir: Quran.com. Tilawah: EveryAyah.com. Hadis: fawazahmed0/hadith-api. Font: Amiri & Amiri Quran (Lisensi SIL). Model suara: diturunkan dari tarteel-ai/whisper-base-ar-quran (Apache-2.0, penyetelan dari OpenAI Whisper), dijalankan di perangkat dengan transformers.js dan ONNX Runtime (Apache-2.0).';

  @override
  String selectedOfMax(int selected, int max) {
    return '$selected dari $max dipilih';
  }

  @override
  String get searchLanguageOrTranslator => 'Cari bahasa atau penerjemah';

  @override
  String nTranslations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terjemahan',
      one: '1 terjemahan',
    );
    return '$_temp0';
  }

  @override
  String nSelected(int count) {
    return '$count dipilih';
  }

  @override
  String get rightToLeftScript => 'Aksara kanan ke kiri';

  @override
  String translationLimit(int max) {
    return 'Anda dapat menampilkan maksimal $max terjemahan sekaligus. Hapus satu dulu.';
  }

  @override
  String get offlineIntro =>
      'Teks Arab, transliterasi Inggris, dan tiga terjemahan Inggris selalu offline. Unduh sisanya sekali dan baca di mana saja.';

  @override
  String get selectedTranslations => 'Terjemahan terpilih';

  @override
  String get allSelectedBundled =>
      'Semua terjemahan terpilih sudah termasuk dalam aplikasi.';

  @override
  String surahDownloadsSaved(int done, int total) {
    return '$done dari $total surah tersimpan';
  }

  @override
  String wordByWordPack(String language) {
    return 'Kata per kata ($language)';
  }

  @override
  String surahsSavedSize(int done) {
    return '$done dari 114 surah tersimpan · sekitar 8 MB';
  }

  @override
  String get tafsirSavedAutomatically =>
      'Tafsir disimpan otomatis untuk setiap ayat yang Anda buka.';

  @override
  String get downloadEverything => 'Unduh semua yang dipilih';

  @override
  String bundledEditions(String names) {
    return 'Edisi bawaan: $names.';
  }

  @override
  String get everythingOffline => 'Semua yang dipilih sudah tersedia offline.';

  @override
  String downloadDone(int count) {
    return 'Selesai. $count unduhan disimpan untuk offline.';
  }

  @override
  String downloadDoneWithFailures(int failed) {
    return 'Selesai dengan $failed unduhan gagal (periksa koneksi dan jalankan lagi).';
  }

  @override
  String downloadCancelled(int done, int total) {
    return 'Dibatalkan setelah $done dari $total.';
  }

  @override
  String get starting => 'Memulai…';

  @override
  String get memorize => 'Hafalan';

  @override
  String memorizeHeader(String surah, int from, int to, int done, int total) {
    return '$surah · Ayat $from–$to · $done/$total hafal';
  }

  @override
  String get changeRange => 'Ubah rentang';

  @override
  String wordsRevealed(int revealed, int total) {
    return '$revealed / $total kata';
  }

  @override
  String get nextWord => 'Kata berikutnya';

  @override
  String get revealAll => 'Tampilkan semua';

  @override
  String get hideAll => 'Sembunyikan semua';

  @override
  String get transliteration => 'Transliterasi';

  @override
  String get translation => 'Terjemahan';

  @override
  String get memorized => 'Hafal';

  @override
  String get markAsMemorized => 'Tandai sudah hafal';

  @override
  String get listenAndRepeat => 'Dengar & ulangi';

  @override
  String get repeatEachAyah => 'Ulangi tiap ayat';

  @override
  String get loopTheRange => 'Ulangi rentang';

  @override
  String playRange(int from, int to) {
    return 'Putar $from–$to';
  }

  @override
  String get thisAyah => 'Ayat ini';

  @override
  String get ayahRange => 'Rentang ayat';

  @override
  String fromToOf(int from, int to, int total) {
    return 'Dari $from sampai $to dari $total';
  }

  @override
  String get readingPlan => 'Rencana baca';

  @override
  String get goalReached => 'Target tercapai, masya Allah!';

  @override
  String moreAyahsToGoal(int count) {
    return '$count ayat lagi untuk mencapai target';
  }

  @override
  String dayStreak(int days) {
    return 'Rentetan $days hari';
  }

  @override
  String get dailyGoal => 'Target harian';

  @override
  String ayahsPerDay(int count) {
    return '$count ayat per hari';
  }

  @override
  String get khatmIn30Days => '208 (khatam dalam 30 hari)';

  @override
  String get last7Days => '7 hari terakhir';

  @override
  String get ayahsRead => 'Ayat dibaca';

  @override
  String get activeDays => 'Hari aktif';

  @override
  String get quranRead => 'Al-Qur\'an dibaca';

  @override
  String get khatmPlan => 'Rencana khatam';

  @override
  String get khatmPlanHelp =>
      'Selesaikan seluruh Al-Qur\'an sesuai jadwal. Kami beri tahu ayat yang harus dicapai setiap hari.';

  @override
  String nDays(int n) {
    return '$n hari';
  }

  @override
  String get startFromFatiha => 'Mulai dari Al-Fatihah';

  @override
  String get fromTheBeginning => 'Dari awal';

  @override
  String get fromWhereYouAre => 'Dari posisi sekarang';

  @override
  String aboutAyahsADay(int count) {
    return 'Sekitar $count ayat per hari';
  }

  @override
  String get startPlan => 'Mulai rencana';

  @override
  String get endPlan => 'Akhiri rencana';

  @override
  String planStatusLine(int day, int days, String date, int perDay) {
    return 'Hari $day dari $days · berakhir $date · $perDay ayat/hari';
  }

  @override
  String get onTrack => 'Anda sesuai jadwal.';

  @override
  String onTrackAhead(int count) {
    return 'Anda sesuai jadwal, $count ayat lebih cepat.';
  }

  @override
  String catchUp(int count) {
    return 'Baca $count ayat lagi hari ini untuk mengejar.';
  }

  @override
  String todaysTarget(String surah, String key) {
    return 'Target hari ini: $surah $key';
  }

  @override
  String get continueReadingButton => 'Lanjutkan membaca';

  @override
  String get hadith => 'Hadis';

  @override
  String get hadithIntro =>
      'Kutubus Sittah, Muwatta Malik, dan tiga kumpulan empat puluh hadis, dengan Arab dan terjemahan. Setiap bab diunduh sekali dan tetap offline.';

  @override
  String hadithsChapters(int hadiths, int chapters) {
    return '$hadiths hadis · $chapters bab';
  }

  @override
  String couldNotLoadHadithBooks(String error) {
    return 'Tidak dapat memuat kitab hadis: $error';
  }

  @override
  String get findAChapter => 'Cari bab';

  @override
  String hadithsRange(int first, int last) {
    return 'Hadis $first–$last';
  }

  @override
  String chapterN(int n) {
    return 'Bab $n';
  }

  @override
  String get chapterNeedsInternet =>
      'Bab ini memerlukan koneksi internet saat pertama kali.';

  @override
  String searchHadithsInChapter(int count) {
    return 'Cari di $count hadis bab ini';
  }

  @override
  String get previousChapter => 'Bab sebelumnya';

  @override
  String get nextChapter => 'Bab berikutnya';

  @override
  String get hadithCopied => 'Hadis disalin';

  @override
  String get prayerTimes => 'Jadwal salat';

  @override
  String get prayerTimesForMasjid => 'Jadwal salat untuk masjid Anda';

  @override
  String get prayerIntro =>
      'Masukkan alamat lengkap atau kode pos masjid. Alamat dipetakan ke koordinat presisi dan zona waktunya, lalu jadwal salat, iqamah, dan Jumat dibuat dengan metode perhitungan pilihan Anda.';

  @override
  String get setUpMasjid => 'Atur masjid dari alamatnya';

  @override
  String get useMyLocation => 'Gunakan lokasi saya';

  @override
  String get methodsList =>
      'Metode perhitungan: ISNA, Liga Muslim Dunia, Mesir, Karachi, Umm al-Qura, Teluk, Kuwait, Qatar, Singapura, Diyanet, UOIF, Rusia, Teheran, dan Jafari. Asar: Syafi\'i/Maliki/Hanbali atau Hanafi.';

  @override
  String couldNotGetLocation(String error) {
    return 'Tidak dapat memperoleh lokasi Anda: $error';
  }

  @override
  String get monthlyTimetable => 'Jadwal bulanan';

  @override
  String get shareToday => 'Bagikan hari ini';

  @override
  String get editMasjid => 'Ubah masjid';

  @override
  String get addAnotherMasjid => 'Tambah masjid lain';

  @override
  String get removeMasjid => 'Hapus masjid';

  @override
  String removeMasjidQuestion(String name) {
    return 'Hapus $name?';
  }

  @override
  String get removeMasjidBody =>
      'Alamat, pengaturan perhitungan, jadwal iqamah dan Jumat akan dihapus.';

  @override
  String nextPrayerIn(String prayer, String time, String duration) {
    return '$prayer pukul $time · dalam $duration';
  }

  @override
  String get fajrTomorrow => 'Subuh (besok)';

  @override
  String get jumuah => 'Jumat';

  @override
  String get noJumuahSet =>
      'Belum ada jadwal Jumat. Ubah masjid untuk menambahkannya.';

  @override
  String khutbahAt(String time) {
    return 'Khutbah $time';
  }

  @override
  String iqamaAt(String time) {
    return 'Iqamah $time';
  }

  @override
  String timesFootnote(String lat, String lng, String tz) {
    return 'Waktu dihitung secara astronomis untuk $lat, $lng di zona $tz, dibulatkan ke menit. Tanggal Hijriah dihitung dan dapat berbeda sehari dari rukyat setempat.';
  }

  @override
  String qiblaDegrees(int degrees) {
    return 'Kiblat $degrees°';
  }

  @override
  String get asrShafii => 'Asar Syafi\'i';

  @override
  String get asrHanafi => 'Asar Hanafi';

  @override
  String get fajr => 'Subuh';

  @override
  String get sunrise => 'Terbit';

  @override
  String get dhuhr => 'Zuhur';

  @override
  String get asr => 'Asar';

  @override
  String get maghrib => 'Magrib';

  @override
  String get isha => 'Isya';

  @override
  String get addMasjid => 'Tambah masjid';

  @override
  String get masjid => 'Masjid';

  @override
  String get masjidName => 'Nama masjid';

  @override
  String get enterAName => 'Masukkan nama';

  @override
  String get address => 'Alamat';

  @override
  String get streetAddress => 'Alamat jalan';

  @override
  String get city => 'Kota';

  @override
  String get stateProvince => 'Provinsi';

  @override
  String get postalCode => 'Kode pos';

  @override
  String get countryCode => 'Kode negara (US, GB, ID…)';

  @override
  String get findLocation => 'Cari lokasi';

  @override
  String get deviceGps => 'GPS perangkat';

  @override
  String get coordinatesAndTimeZone => 'Koordinat & zona waktu';

  @override
  String get setAutomatically => 'Diatur otomatis dari alamat';

  @override
  String get latitude => 'Lintang';

  @override
  String get longitude => 'Bujur';

  @override
  String get ianaTimeZone => 'Zona waktu IANA (mis. Asia/Jakarta)';

  @override
  String get calculation => 'Perhitungan';

  @override
  String get calculationMethod => 'Metode perhitungan';

  @override
  String get asrShafiiFull => 'Asar: Syafi\'i / Maliki / Hanbali';

  @override
  String get asrHanafiFull => 'Asar: Hanafi';

  @override
  String get dhuhrAfterZawal => 'Zuhur: menit setelah zawal';

  @override
  String get maghribAfterSunset => 'Magrib: menit setelah terbenam';

  @override
  String get fineTune => 'Sesuaikan tiap salat (menit)';

  @override
  String get hijriAdjustment => 'Penyesuaian tanggal Hijriah (hari)';

  @override
  String get iqama => 'Iqamah';

  @override
  String get jumuahServices => 'Salat Jumat';

  @override
  String get addJumuahTime => 'Tambah waktu Jumat';

  @override
  String get addAnotherService => 'Tambah salat lain';

  @override
  String get saveMasjid => 'Simpan masjid';

  @override
  String get none => 'Tidak ada';

  @override
  String get fixed => 'Tetap';

  @override
  String get plusMinutes => '+ menit';

  @override
  String get khutbahPicker => 'Khutbah…';

  @override
  String get jumuahLabelHint => 'Label (bahasa, ruangan, khatib)';

  @override
  String get enterZipOrCity => 'Masukkan setidaknya kode pos atau kota.';

  @override
  String get lookingUpAddress => 'Mencari alamat…';

  @override
  String get noMatchTryCountry =>
      'Tidak ditemukan. Tambahkan kota dan kode negara 2 huruf (mis. ID, US, GB).';

  @override
  String get chooseLocation => 'Pilih lokasi yang benar:';

  @override
  String lookupFailed(String error) {
    return 'Pencarian gagal: $error';
  }

  @override
  String get resolvingTimeZone => 'Menentukan zona waktu…';

  @override
  String located(String name) {
    return 'Ditemukan: $name';
  }

  @override
  String timeZoneLookupFailed(String error) {
    return 'Koordinat diatur, tetapi zona waktu gagal ($error). Masukkan zona IANA seperti Asia/Jakarta.';
  }

  @override
  String get gettingPosition => 'Mendapatkan posisi Anda…';

  @override
  String couldNotUseDevice(String error) {
    return 'Tidak dapat menggunakan lokasi perangkat: $error';
  }

  @override
  String get findLocationFirst =>
      'Ketuk \"Cari lokasi\" dulu agar koordinat dan zona waktu terisi.';

  @override
  String get setUpMasjidFirst => 'Atur masjid terlebih dahulu.';

  @override
  String get hideIqama => 'Sembunyikan iqamah';

  @override
  String get showIqama => 'Tampilkan iqamah';

  @override
  String get copyAsCsv => 'Salin sebagai CSV';

  @override
  String get csvCopied => 'CSV disalin — tempel di Excel atau Sheets';

  @override
  String get shareAsText => 'Bagikan sebagai teks';

  @override
  String get thisMonth => 'Bulan ini';

  @override
  String get date => 'Tanggal';

  @override
  String get mushafLayout => 'Tata letak';

  @override
  String get layoutAutomatic => 'Otomatis';

  @override
  String get layoutScroll => 'Satu halaman, gulir ke bawah';

  @override
  String get layoutFlip => 'Satu halaman, balik';

  @override
  String get layoutBook => 'Dua halaman, balik';

  @override
  String get playThisPage => 'Putar halaman ini';

  @override
  String get goToPage => 'Ke halaman';

  @override
  String get goTo => 'Ke';

  @override
  String get pageRange => 'Halaman (1–604)';

  @override
  String get previousPage => 'Halaman sebelumnya';

  @override
  String get nextPage => 'Halaman berikutnya';

  @override
  String pageJuz(int page, int juz) {
    return 'Halaman $page · Juz $juz';
  }

  @override
  String get library => 'Perpustakaan';

  @override
  String get openBook => 'Buka kitab';

  @override
  String get tableOfContents => 'Daftar isi';

  @override
  String chapterPage(int chapter, int page, int total) {
    return 'Bab $chapter · Halaman $page / $total';
  }

  @override
  String get listView => 'Tampilan daftar';

  @override
  String get downloadPdf => 'Unduh PDF';

  @override
  String get downloadChapterPdf => 'Unduh bab ini sebagai PDF';

  @override
  String get downloadBookPdf => 'Unduh seluruh kitab sebagai PDF';

  @override
  String preparingPdf(int done, int total) {
    return 'Mengambil bab… $done / $total';
  }

  @override
  String get renderingPdf => 'Membuat PDF…';

  @override
  String pdfFailed(String error) {
    return 'Tidak dapat membuat PDF: $error';
  }

  @override
  String hadithsCount(int count) {
    return '$count hadis';
  }

  @override
  String byAuthor(String author) {
    return 'oleh $author';
  }

  @override
  String get reciteAndCheck => 'Setor & periksa';

  @override
  String get reciteFromHere => 'Setor dari sini';

  @override
  String get reciteSubtitle =>
      'Bacakan dari hafalan; aplikasi mendengar dan menandai tiap kata';

  @override
  String ayahRangeLabel(int from, int to) {
    return 'Ayat $from–$to';
  }

  @override
  String get accuracy => 'akurasi';

  @override
  String get matchedWords => 'benar';

  @override
  String get wrongWords => 'salah';

  @override
  String get missedWords => 'terlewat';

  @override
  String wordsReached(int reached, int total) {
    return '$reached dari $total kata dibacakan';
  }

  @override
  String get listening => 'Mendengarkan…';

  @override
  String get waitingForSpeech => 'Menunggu suara…';

  @override
  String get tapMicToStart => 'Ketuk mikrofon dan mulai membaca';

  @override
  String get heard => 'Terdengar';

  @override
  String get notInPassage => 'Kata yang tidak ada dalam bacaan';

  @override
  String get hideText => 'Sembunyikan teks (hafalan)';

  @override
  String get showText => 'Tampilkan teks';

  @override
  String get hint => 'Petunjuk';

  @override
  String get reset => 'Ulangi';

  @override
  String get playThisAyah => 'Putar ayat ini';

  @override
  String get speechUnavailable =>
      'Pengenalan suara tidak tersedia. Izinkan akses mikrofon, atau gunakan Chrome di web.';

  @override
  String get reciteHelp =>
      'Bacalah dengan jelas dan tempo stabil di tempat tenang; kata benar menjadi hijau, keliru oranye, terlewat merah.';

  @override
  String get qibla => 'Kiblat';

  @override
  String get qiblaBearing => 'Arah kiblat dari utara sejati';

  @override
  String get qiblaNeedsLocation =>
      'Kiblat dihitung dari lokasi Anda. Gunakan GPS perangkat, atau atur masjid terlebih dahulu.';

  @override
  String distanceToMakkah(int km) {
    return '$km km ke Makkah';
  }

  @override
  String headingDegrees(int degrees) {
    return 'Arah $degrees°';
  }

  @override
  String get facingQibla => 'Anda menghadap kiblat';

  @override
  String get compassWaiting =>
      'Menunggu kompas… gerakkan ponsel membentuk angka 8 untuk kalibrasi.';

  @override
  String get compassUnavailable =>
      'Perangkat ini tidak punya kompas: gunakan kompas atau peta dan hadap ke arah di atas.';

  @override
  String turnToQibla(String direction, int degrees) {
    return 'Putar ke $direction sebesar $degrees°';
  }

  @override
  String get left => 'kiri';

  @override
  String get right => 'kanan';

  @override
  String get qiblaHelp =>
      'Pegang ponsel mendatar, jauh dari magnet atau logam. Penanda Ka\'bah di dial menunjukkan kiblat; panah di atas adalah arah Anda.';

  @override
  String get adhan => 'Azan';

  @override
  String get adhanIntro =>
      'Dengarkan azan dari berbagai muazin, unduh rekaman, dan pilih azan bawaan untuk jadwal salat Anda.';

  @override
  String get adhanCredits =>
      'Rekaman dari Wikimedia Commons berlisensi CC0 dan CC BY-SA 4.0, dikonversi ke MP3; ketuk baris kredit untuk membuka berkas asli dan lisensinya.';

  @override
  String downloaded(String name) {
    return '$name diunduh';
  }

  @override
  String downloadFailed(String error) {
    return 'Unduhan gagal: $error';
  }

  @override
  String get downloadSurahAudio => 'Unduh audio surah untuk offline';

  @override
  String get downloadAyahAudio => 'Unduh audio ayat ini (MP3)';

  @override
  String get offlineAudioNativeOnly =>
      'Audio offline disimpan di aplikasi ponsel dan desktop; di web, unduh per ayat.';

  @override
  String surahAudioSaved(String surah) {
    return '$surah tersimpan untuk didengarkan offline';
  }

  @override
  String get downloadForOffline => 'Unduh untuk dibaca offline';

  @override
  String savedForOffline(String name) {
    return '$name tersimpan untuk dibaca offline';
  }

  @override
  String get playAdhan => 'Putar azan';

  @override
  String adhanForNext(String prayer) {
    return 'Azan $prayer';
  }

  @override
  String get chooseAdhan => 'Pilih azan';

  @override
  String get pageAnimation => 'Animasi halaman';

  @override
  String get animationCurl => 'Lipatan halaman';

  @override
  String get animationFlip => 'Balik kartu';

  @override
  String get animationSlide => 'Geser';

  @override
  String get animationFade => 'Pudar';

  @override
  String get highlight => 'Sorot';

  @override
  String get removeHighlight => 'Hapus sorotan';

  @override
  String get note => 'Catatan';

  @override
  String get noteHint => 'Tulis renungan atau pengingat untuk ayat ini…';

  @override
  String get noteSaved => 'Catatan tersimpan';

  @override
  String get noteHelp =>
      'Catatan tersimpan di perangkat ini. Ayat yang disorot diwarnai pada halaman Mushaf.';

  @override
  String get continuous => 'Lanjut otomatis';

  @override
  String get repeatEach => 'Ulangi';

  @override
  String get verseDetails => 'Detail ayat';

  @override
  String get zoomIn => 'Perbesar';

  @override
  String get zoomOut => 'Perkecil';

  @override
  String get fitPage => 'Sesuaikan halaman';

  @override
  String get shareEmbed => 'Bagikan & sematkan';

  @override
  String get websiteWidget => 'Widget situs & tampilan TV';

  @override
  String get widgetLinks => 'Tautan publik';

  @override
  String get embedCode => 'Kode sematan';

  @override
  String get openLink => 'Buka';

  @override
  String get linkCopied => 'Tautan disalin';

  @override
  String get codeCopied => 'Kode sematan disalin';

  @override
  String get combinedWidget => 'Widget gabungan (harian + Jumat)';

  @override
  String get dailyWidget => 'Widget salat harian';

  @override
  String get jumuahWidget => 'Widget salat Jumat';

  @override
  String get compactWidget => 'Widget ringkas';

  @override
  String get tvDisplay => 'Tampilan TV';

  @override
  String get darkWidget => 'Widget gelap';

  @override
  String get embedHelp =>
      'Tempel kode sematan di situs masjid Anda, atau bagikan tautannya. Tautan itu sendiri memuat lokasi, metode, iqamah dan jadwal Jumat masjid ini, jadi salin lagi setelah mengubahnya. Tambahkan ?theme=dark atau &scale=120, &lang=ar pada tautan mana pun.';

  @override
  String get preview => 'Pratinjau';

  @override
  String get adhanHeader => 'Azan';

  @override
  String get poweredBy => 'Didukung Mushaf+';

  @override
  String get invalidWidgetLink =>
      'Tautan widget ini tidak valid atau tidak lengkap.';

  @override
  String get micDenied =>
      'Akses mikrofon ditolak. Izinkan untuk situs ini di pengaturan peramban atau sistem, lalu coba lagi.';

  @override
  String get noSpeechYet =>
      'Belum ada yang terdengar. Bacalah dengan jelas, dekat mikrofon; kata-kata muncul di sini saat dikenali.';

  @override
  String get speechNotice => 'Pemberitahuan pengenalan';

  @override
  String get speechTip =>
      'Kata yang benar menjadi hijau, yang salah merah disertai bunyi dan getaran; teruskan membaca setelah keliru dan pemeriksa akan mengikuti.';

  @override
  String get strictMode => 'Ketat';

  @override
  String get lenientMode => 'Longgar';

  @override
  String get strictHelp =>
      'Mode ketat: kata dihitung benar hanya jika setiap huruf cocok. Harakat dan tajwid tidak dapat diperiksa: pengenalan suara hanya mengembalikan huruf.';

  @override
  String get tjHamzatWasl => 'Hamzah washal';

  @override
  String get tjSilent => 'Huruf tidak dibaca';

  @override
  String get tjLaamShamsiyyah => 'Lam syamsiyah';

  @override
  String get tjMaddNormal => 'Mad thabi’i';

  @override
  String get tjMaddPermissible => 'Mad jaiz';

  @override
  String get tjMaddNecessary => 'Mad lazim';

  @override
  String get tjQalqalah => 'Qalqalah';

  @override
  String get tjMaddObligatory => 'Mad wajib muttashil';

  @override
  String get tjIkhfaShafawi => 'Ikhfa syafawi';

  @override
  String get tjIkhfa => 'Ikhfa haqiqi';

  @override
  String get tjIdghamShafawi => 'Idgham syafawi';

  @override
  String get tjIqlab => 'Iqlab';

  @override
  String get tjIdghamGhunnah => 'Idgham bighunnah';

  @override
  String get tjIdghamNoGhunnah => 'Idgham bilaghunnah';

  @override
  String get tjIdghamMutajanisayn => 'Idgham mutajanisain';

  @override
  String get tjIdghamMutaqaribayn => 'Idgham mutaqaribain';

  @override
  String get tjGhunnah => 'Ghunnah';

  @override
  String get tjdHamzatWasl =>
      'Hamzah penghubung di awal kata: dibaca hanya saat memulai dari kata itu; jika disambung dari kata sebelumnya, hamzah tidak dibaca.';

  @override
  String get tjdSilent =>
      'Huruf yang tertulis di mushaf tetapi tidak dibaca, seperti alif setelah wau jamak. Lewati saat membaca.';

  @override
  String get tjdLaamShamsiyyah =>
      'Lam alif-lam sebelum huruf syamsiyah tidak dibaca; huruf syamsiyahnya yang ditasydid, seperti ٱلشَّمْس → asy-syams.';

  @override
  String get tjdMaddNormal =>
      'Mad thabi’i: panjangkan huruf mad dua harakat, tidak kurang tidak lebih.';

  @override
  String get tjdMaddPermissible =>
      'Mad ketika huruf mad bertemu hamzah di kata berikutnya atau sukun karena waqaf. Panjangkan dua, empat, atau enam harakat secara konsisten.';

  @override
  String get tjdMaddNecessary =>
      'Mad karena sukun asli atau tasydid setelah huruf mad, termasuk huruf pembuka surah. Panjangkan enam harakat.';

  @override
  String get tjdQalqalah =>
      'Pantulan suara pada huruf ق ط ب ج د yang bersukun. Lepaskan huruf dengan pantulan ringan, lebih kuat saat waqaf.';

  @override
  String get tjdMaddObligatory =>
      'Huruf mad diikuti hamzah dalam satu kata. Panjangkan empat sampai lima harakat.';

  @override
  String get tjdIkhfaShafawi =>
      'Mim sukun sebelum ب: rapatkan bibir dengan ringan dan samarkan mim dengan dengung dua harakat.';

  @override
  String get tjdIkhfa =>
      'Nun sukun atau tanwin sebelum salah satu dari lima belas huruf ikhfa: samarkan nun dengan dengung dua harakat, lidah siap pada huruf berikutnya.';

  @override
  String get tjdIdghamShafawi =>
      'Mim sukun sebelum mim: leburkan menjadi satu mim bertasydid dengan dengung dua harakat.';

  @override
  String get tjdIqlab =>
      'Nun sukun atau tanwin sebelum ب berubah menjadi mim yang disamarkan dengan dengung dua harakat dan bibir rapat ringan.';

  @override
  String get tjdIdghamGhunnah =>
      'Nun sukun atau tanwin sebelum ي ن م و di awal kata berikutnya melebur ke huruf itu dengan dengung dua harakat.';

  @override
  String get tjdIdghamNoGhunnah =>
      'Nun sukun atau tanwin sebelum ل atau ر melebur sepenuhnya tanpa dengung.';

  @override
  String get tjdIdghamMutajanisayn =>
      'Dua huruf semakhraj, yang pertama sukun, melebur menjadi satu huruf bertasydid, seperti قَد تَّبَيَّنَ.';

  @override
  String get tjdIdghamMutaqaribayn =>
      'Dua huruf yang makhrajnya berdekatan, yang pertama sukun, melebur ke huruf kedua, seperti قُل رَّبِّ.';

  @override
  String get tjdGhunnah =>
      'Dengung hidung dua harakat pada mim atau nun bertasydid.';

  @override
  String get tjgMadd => 'Mad';

  @override
  String get tjgNunTanwin => 'Nun sukun dan tanwin';

  @override
  String get tjgMeemSakinah => 'Mim sukun';

  @override
  String get tjgGhunnah => 'Ghunnah';

  @override
  String get tjgQalqalah => 'Qalqalah';

  @override
  String get tjgLam => 'Lam';

  @override
  String get tjgSilent => 'Huruf tidak dibaca';

  @override
  String get tjgIdghamAdjacent => 'Idgham huruf berdekatan';

  @override
  String get tajweed => 'Tajwid';

  @override
  String get tajweedColors => 'Warna tajwid';

  @override
  String get tajweedColorsSubtitle =>
      'Warnai huruf Mushaf dan pembaca menurut hukum tajwid';

  @override
  String get tajweedGuide => 'Panduan tajwid';

  @override
  String get tajweedLegend => 'Legenda warna tajwid';

  @override
  String get seeGuide => 'Panduan lengkap';

  @override
  String get tajweedIntro =>
      'Tajwid adalah membaca setiap huruf dari makhrajnya dengan sifat-sifatnya: memanjangkan pada mad, mendengung pada ghunnah, menyamarkan, meleburkan, dan memantulkan sesuai hukumnya. Mushaf mewarnai setiap huruf yang memuat hukum; ketuk kata mana pun untuk melihat hukumnya dan cara membacanya. Hukum mengikuti riwayat Hafs dari Ashim.';

  @override
  String get rulesInThisWord => 'Tajwid pada kata ini';

  @override
  String get noRulesInWord =>
      'Tidak ada hukum tajwid yang ditandai pada kata ini: bacalah hurufnya apa adanya dari makhrajnya.';

  @override
  String get wordTab => 'Kata';

  @override
  String wordOfN(int n, int total) {
    return 'Kata $n dari $total';
  }

  @override
  String get playWord => 'Putar kata';

  @override
  String get example => 'Contoh';

  @override
  String get triggerLetters => 'Huruf';

  @override
  String countsValue(String n) {
    return '$n harakat';
  }

  @override
  String tuhfaRef(String lines) {
    return 'Tuhfatul Athfal, bait $lines';
  }

  @override
  String jazariyyahRef(String lines) {
    return 'al-Jazariyyah, bait $lines';
  }

  @override
  String get tajweedSource =>
      'Hukum dan pewarnaan mengikuti panduan tajwid alquran.cloud (riwayat Hafs, teks Tanzil Utsmani) dan skema warna KFGQPC yang dipakai quran.com. Rujukan bait mengacu pada Tuhfatul Athfal dan al-Muqaddimah al-Jazariyyah.';

  @override
  String get fullScreen => 'Layar penuh';

  @override
  String get exitFullScreen => 'Keluar layar penuh';

  @override
  String get playbackSpeed => 'Kecepatan';

  @override
  String get chooseReciter => 'Pilih qari';

  @override
  String get approximateLocation =>
      'Hanya wilayah (kode pos atau kota) yang ditemukan, jadi koordinatnya adalah pusatnya. Jika Anda tahu koordinat tepatnya, masukkan di bawah.';

  @override
  String get privacyPolicy => 'Kebijakan privasi';

  @override
  String pdfReady(String size) {
    return 'PDF siap ($size)';
  }

  @override
  String get openPdf => 'Buka';

  @override
  String get savePdf => 'Simpan';

  @override
  String get offlineSavedBody =>
      'Kitab tersimpan di perangkat ini dalam bahasa hadis saat ini dan dibuka tanpa internet dari perpustakaan. Unduh lagi setelah mengganti bahasa.';

  @override
  String get adhkar => 'Dzikir';

  @override
  String get hisnAlMuslim => 'Hisnul Muslim';

  @override
  String get hisnAlMuslimSubtitle =>
      'Benteng Muslim · dzikir dan doa dari Al-Qur’an dan Sunnah';

  @override
  String get adhkarIntro =>
      'Dzikir dan doa harian dari Hisnul Muslim karya Sa‘id al-Qahthani, dengan penghitung pengulangan dan audio.';

  @override
  String repeatProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get playChapter => 'Putar bab';

  @override
  String get resetCounters => 'Atur ulang penghitung';

  @override
  String get adhkarLanguageNote =>
      'Terjemahan berasal dari hisnmuslim.com dan hanya tersedia dalam bahasa Inggris dan Arab.';

  @override
  String get findAdhkar => 'Cari bab…';

  @override
  String get morning => 'Pagi';

  @override
  String get evening => 'Petang';

  @override
  String get sleep => 'Tidur';

  @override
  String get afterPrayer => 'Setelah salat';

  @override
  String get allDone => 'Selesai';

  @override
  String timesN(int n) {
    return '×$n';
  }

  @override
  String get readAloud => 'Bacakan';

  @override
  String get stopReading => 'Hentikan';

  @override
  String get ttsUnavailable =>
      'Tidak ada suara untuk bahasa ini di perangkat. Hadis dibacakan dengan suara text-to-speech perangkat.';

  @override
  String get homeSearchHint =>
      'Cari di Al-Qur’an — surah, ayat, kata, atau frasa. Arab dengan atau tanpa harakat, transliterasi (insan, bismillah), arti bahasa Inggris, atau nama/nomor surah…';

  @override
  String get countryLabel => 'Negara';

  @override
  String get region => 'Wilayah';

  @override
  String get changeRegion => 'ketuk untuk mengubah';

  @override
  String get detectRegion => 'Deteksi';

  @override
  String get regionHelp =>
      'Mengisi negara untuk masjid dan memilih perhitungan salat yang lazim di negara itu.';

  @override
  String regionSetTo(String name) {
    return 'Wilayah diatur ke $name. Ketuk bendera untuk mengubah.';
  }

  @override
  String get regionNotDetected => 'Negara tidak terdeteksi. Pilih dari daftar.';

  @override
  String get findCountry => 'Cari negara…';

  @override
  String get myPrayerTimes => 'Jadwal saya';

  @override
  String get masjidsTab => 'Masjid';

  @override
  String get enterMyCity => 'Masukkan kota saya';

  @override
  String get orEnterCity => 'atau masukkan kota Anda';

  @override
  String get editLocation => 'Ubah lokasi';

  @override
  String get personalIntro =>
      'Jadwal salat di tempat Anda: izinkan lokasi presisi atau ketik kota Anda. Metode perhitungan mengikuti negara Anda dan dapat diubah.';

  @override
  String get masjidAdminHint =>
      'Pengurus masjid: atur masjid itu sendiri, dengan iqamah, Jumat dan widget situs, di tab Masjid setelah membuat profil.';

  @override
  String get masjidAdminGate =>
      'Profil masjid memuat iqamah, layanan Jumat dan widget publik, jadi terikat pada pengurus bernama. Buat profil Anda (nama dan email, tersimpan di perangkat ini) untuk mengaturnya.';

  @override
  String get createProfile => 'Buat profil';

  @override
  String get profile => 'Profil';

  @override
  String get profileIntro =>
      'Nama dan email Anda menandai Anda sebagai pengurus masjid yang Anda atur. Keduanya tetap di perangkat ini.';

  @override
  String get name => 'Nama';

  @override
  String get email => 'Email';

  @override
  String get invalidEmail => 'Masukkan alamat email yang valid.';

  @override
  String get profileSaved => 'Profil disimpan';

  @override
  String get masjidRole => 'Peran di masjid (opsional)';

  @override
  String get masjidRoleHint => 'Imam, pengurus, relawan…';

  @override
  String get removeProfile => 'Hapus profil';

  @override
  String get reminders => 'Pengingat';

  @override
  String get remindersOn => 'Aktif · ketuk untuk mengatur';

  @override
  String get remindersOff => 'Nonaktif · salat, dzikir, ayat harian';

  @override
  String get remindersSettingsSubtitle =>
      'Salat dengan azan, dzikir pagi dan petang, ayat atau dzikir harian';

  @override
  String get prayerReminders => 'Pengingat waktu salat';

  @override
  String prayerRemindersSubtitle(String adhan) {
    return 'Setiap salat; membuka pengingat memutar $adhan';
  }

  @override
  String get remindBefore => 'Ingatkan';

  @override
  String get atPrayerTime => 'Saat waktu salat';

  @override
  String minutesBefore(int n) {
    return '$n mnt sebelumnya';
  }

  @override
  String get adhkarReminders => 'Pengingat dzikir';

  @override
  String get adhkarRemindersSubtitle =>
      'Dzikir pagi setelah Subuh, petang setelah Asar, dzikir tidur satu jam setelah Isya';

  @override
  String get dailyReminder => 'Ayat atau dzikir hari ini';

  @override
  String get dailyReminderSubtitle => 'Ayat atau dzikir acak sekali sehari';

  @override
  String get reminderTime => 'Waktu';

  @override
  String get nextReminders => 'Mendatang';

  @override
  String get notificationsWebNote =>
      'Di peramban, pengingat hanya muncul saat Mushaf+ terbuka di tab. Pasang aplikasi Android atau iOS untuk pengingat saat aplikasi tertutup.';

  @override
  String get notificationsDenied =>
      'Notifikasi untuk Mushaf+ diblokir di pengaturan sistem.';

  @override
  String get setLocationFirst => 'Atur lokasi salat Anda dulu';

  @override
  String get adhanOnNotification =>
      'Pengingat salat memakai suara sistem; membukanya memutar azan pilihan Anda secara penuh.';

  @override
  String prayerInMinutes(String prayer, int n) {
    return '$prayer dalam $n menit';
  }

  @override
  String timeForPrayer(String prayer) {
    return 'Waktu $prayer';
  }

  @override
  String get timeAdhkarMorning => 'Dzikir pagi';

  @override
  String get timeAdhkarEvening => 'Dzikir petang';

  @override
  String get timeAdhkarSleep => 'Dzikir tidur';

  @override
  String get adhkarMorningBody => 'Awali hari dengan dzikir pagi.';

  @override
  String get adhkarEveningBody => 'Dzikir petang, sebelum malam.';

  @override
  String get adhkarSleepBody => 'Dzikir sebelum tidur.';

  @override
  String get ayahOfTheDayNotif => 'Ayat hari ini';

  @override
  String get dhikrOfTheDay => 'Dzikir hari ini';

  @override
  String get memorizeCard => 'Hafal & setor';

  @override
  String get memorizeCardSubtitle =>
      'Sembunyikan kata, tampilkan satu per satu, lalu baca dan biarkan aplikasi memeriksa.';

  @override
  String get town => 'Kota';

  @override
  String get suburb => 'Kelurahan';

  @override
  String get province => 'Provinsi';

  @override
  String get zip => 'Kode ZIP';

  @override
  String get postcode => 'Kode pos';

  @override
  String get regionOptional => 'Wilayah (opsional)';

  @override
  String get postalOptional => 'Kode pos (opsional)';

  @override
  String get bundledAlways =>
      'Teks Al-Qur’an, warna tajwid, transliterasi, tiga terjemahan Inggris, indeks hadis dan Hisnul Muslim sudah tertanam dan selalu bekerja luring.';

  @override
  String get downloadTextPacks => 'Unduh semua paket teks';

  @override
  String get textPacks => 'Teks';

  @override
  String get audioPacks => 'Audio';

  @override
  String tafsirPack(String name) {
    return 'Tafsir · $name';
  }

  @override
  String hadithPack(String lang) {
    return 'Kitab hadis ($lang)';
  }

  @override
  String chaptersSaved(int done, int total) {
    return '$done / $total bab tersimpan';
  }

  @override
  String get adhanPack => 'Rekaman azan';

  @override
  String get adhkarAudioPack => 'Audio Hisnul Muslim';

  @override
  String reciterPack(String name) {
    return 'Tilawah lengkap · $name';
  }

  @override
  String filesSaved(int done, int total) {
    return '$done / $total berkas tersimpan';
  }

  @override
  String approxSize(String size) {
    return 'sekitar $size';
  }

  @override
  String get offlinePromptTitle => 'Pakai Mushaf+ secara luring?';

  @override
  String get offlinePromptBody =>
      'Unduh terjemahan, arti kata, tafsir dan kitab hadis sekarang (sekitar 60 MB) agar semuanya bekerja tanpa koneksi. Paket audio bisa ditambahkan nanti di Pengaturan → Paket luring.';

  @override
  String get downloadNow => 'Unduh sekarang';

  @override
  String get later => 'Nanti';

  @override
  String get offlineAutoTitle => 'Mushaf+ bekerja sepenuhnya luring';

  @override
  String get offlineAutoBody =>
      'Aplikasi kini akan mengunduh semua yang dibutuhkan agar bekerja tanpa koneksi: terjemahan, arti kata, tafsir, kitab hadis, rekaman azan dan audio Hisnul Muslim (sekitar 200 MB). Berjalan di latar belakang; Anda bisa terus membaca. Wi-Fi disarankan.';

  @override
  String includeFullRecitation(String name) {
    return 'Tilawah lengkap oleh $name';
  }

  @override
  String get includeFullRecitationHint =>
      'Sekitar 700 MB. Bisa juga ditambahkan nanti di Pengaturan → Paket luring.';

  @override
  String get continueLabel => 'Lanjutkan';

  @override
  String offlineSyncing(int percent) {
    return 'Mengunduh untuk luring · $percent%';
  }

  @override
  String get offlineAutoIntro =>
      'Mushaf+ mengunduh semua yang dibutuhkan di latar belakang agar bekerja tanpa koneksi. Setiap paket di bawah menunjukkan apa yang tersimpan; ketuk untuk mengambil yang kurang.';

  @override
  String get resumeOfflineDownload => 'Unduh semua yang kurang';

  @override
  String get wifiOnly => 'Audio hanya lewat Wi-Fi';

  @override
  String get wifiOnlyHint =>
      'Dengan data seluler hanya paket teks kecil yang terunduh sendiri.';

  @override
  String get waitingForWifi =>
      'Paket teks tersimpan. Paket audio akan terunduh saat Anda memakai Wi-Fi (atau ketuk tombol di atas untuk mengunduh sekarang).';

  @override
  String get watchNoPlace => 'Atur lokasi salat untuk melihat jadwalnya.';

  @override
  String inDuration(String duration) {
    return 'dalam $duration';
  }

  @override
  String get tasbih => 'Tasbih';

  @override
  String get tapToCount => 'Ketuk untuk menghitung, tahan untuk mengatur ulang';

  @override
  String get useLocationShort => 'Lokasi saya';

  @override
  String get supportTitle => 'Dukung Mushaf+';

  @override
  String get supportSubtitle =>
      'Kontribusi sukarela menjaga aplikasi tetap gratis, terbuka dan bebas iklan.';

  @override
  String get supportIntro =>
      'Mushaf+ gratis, tanpa iklan, dan akan selalu begitu. Jika bermanfaat bagi Anda, kontribusi sukarela menutup biaya server, hosting audio dan biaya toko aplikasi, serta memungkinkan kami terus membangun.';

  @override
  String get tipJarIntro =>
      'Pilih tip. Tidak membuka apa pun: semua di Mushaf+ tetap gratis untuk semua orang.';

  @override
  String get tipThanks =>
      'Jazakallahu khairan. Terima kasih telah mendukung Mushaf+!';

  @override
  String get tipUnavailable =>
      'Tip belum tersedia saat ini. Silakan coba lagi nanti.';

  @override
  String get donateIntro => 'Pilih cara berkontribusi.';

  @override
  String get donateComingSoon =>
      'Pilihan donasi sedang disiapkan. Terima kasih atas kesabaran Anda dan karena memakai Mushaf+.';

  @override
  String get bankTransfer => 'Transfer bank';

  @override
  String get copied => 'Disalin';

  @override
  String get supportFootnote =>
      'Kontribusi adalah hadiah sukarela kepada pengembang, bukan pembelian, dan tidak dapat dikurangkan dari pajak.';

  @override
  String get recognitionEngine => 'Mesin pengenalan';

  @override
  String get engineBrowser => 'Peramban';

  @override
  String get engineBrowserDesc => 'Cepat, huruf saja';

  @override
  String get engineVoiceModel => 'Model suara Mushaf+';

  @override
  String get engineVoiceModelDesc =>
      'Unduhan sekali 150 MB, menandai kesalahan harakat';

  @override
  String get engineVoiceModelHelp =>
      'Model suara Mushaf+ mengunduh sekitar 150 MB sekali, lalu berjalan di perangkat ini di dalam peramban. Memeriksa harakat selain huruf. Memerlukan Chrome, Edge, atau Safari versi terbaru.';

  @override
  String get voiceModelDownloadTitle => 'Unduh model suara Mushaf+?';

  @override
  String voiceModelDownloadBody(int size) {
    return 'Sekitar $size MB, diunduh sekali dan disimpan di perangkat ini. Pengenalan kemudian berjalan di peramban Anda; bacaan Anda tidak meninggalkan perangkat.';
  }

  @override
  String voiceModelDownloading(int done, int total) {
    return 'Mengunduh model suara… $done dari $total MB';
  }

  @override
  String get voiceModelPreparing => 'Menyiapkan model suara…';

  @override
  String get voiceModelFailed => 'Model suara tidak dapat dimuat.';

  @override
  String get voiceModelSlow =>
      'Tidak ada akselerasi grafis di peramban ini: hasil bisa tertunda beberapa detik.';

  @override
  String get usingBrowserEngine => 'Memakai mesin peramban untuk saat ini.';

  @override
  String get vowelSlips => 'kesalahan harakat';

  @override
  String get letterErrors => 'kesalahan huruf';

  @override
  String reciteSummary(int correct, int vowel, int letter) {
    return '$correct benar · $vowel kesalahan harakat · $letter kesalahan huruf';
  }

  @override
  String get feedbackDisclaimer =>
      'Umpan balik otomatis bisa keliru; tidak menggantikan guru.';

  @override
  String vowelSlipLine(String heard, String letter, String expected) {
    return 'Terdengar $heard pada $letter, seharusnya $expected';
  }

  @override
  String get wordCorrect => 'Benar';

  @override
  String get wordVowelSlip => 'Kesalahan harakat';

  @override
  String get wordWrong => 'Kata salah';

  @override
  String get wordMissed => 'Terlewat';

  @override
  String get wordPending => 'Belum sampai';

  @override
  String get markFatha => 'fathah';

  @override
  String get markDamma => 'dhammah';

  @override
  String get markKasra => 'kasrah';

  @override
  String get markSukun => 'sukun';

  @override
  String get markShadda => 'syaddah';

  @override
  String get markFathatan => 'fathatain';

  @override
  String get markDammatan => 'dhammatain';

  @override
  String get markKasratan => 'kasratain';

  @override
  String get markNone => 'tanpa harakat';

  @override
  String get markNoShadda => 'tanpa syaddah';

  @override
  String get voiceModelHelp =>
      'Model suara Mushaf+ juga memeriksa harakat: kesalahan harakat ditampilkan berwarna kuning tua. Ketuk kata mana pun untuk rincian.';

  @override
  String get playRecitation => 'Putar bacaan';

  @override
  String get addressLookupCredit =>
      'Pencarian alamat: © kontributor OpenStreetMap (ODbL), geocoding Open-Meteo (CC BY 4.0), Zippopotam.';

  @override
  String get dataSourcesLicences => 'Sumber data & lisensi';

  @override
  String get dataSourcesLicencesHint =>
      'Asal teks, audio dan peta, serta ketentuannya';

  @override
  String get openSourceLicences => 'Lisensi sumber terbuka';

  @override
  String recordingCredit(String author, String license) {
    return 'Rekaman: $author · $license · Wikimedia Commons';
  }
}
