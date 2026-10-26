// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Kur\'an+';

  @override
  String get navRead => 'Oku';

  @override
  String get navHadith => 'Hadis';

  @override
  String get navPrayer => 'Namaz';

  @override
  String get navSaved => 'Kayıtlı';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get search => 'Ara';

  @override
  String get searchTheQuran => 'Kur\'an\'da ara';

  @override
  String get cancel => 'İptal';

  @override
  String get open => 'Aç';

  @override
  String get apply => 'Uygula';

  @override
  String get save => 'Kaydet';

  @override
  String get retry => 'Yeniden dene';

  @override
  String get copy => 'Kopyala';

  @override
  String get share => 'Paylaş';

  @override
  String get clear => 'Temizle';

  @override
  String get remove => 'Kaldır';

  @override
  String get download => 'İndir';

  @override
  String get more => 'Daha fazla';

  @override
  String get back => 'Geri';

  @override
  String get loading => 'Yükleniyor…';

  @override
  String get couldNotLoadQuran => 'Kur\'an verileri yüklenemedi.';

  @override
  String get continueReading => 'OKUMAYA DEVAM ET';

  @override
  String get startReading => 'OKUMAYA BAŞLA';

  @override
  String ayahOfJuzPage(int ayah, int total, int juz, int page) {
    return 'Ayet $ayah/$total · Cüz $juz · Sayfa $page';
  }

  @override
  String get verseOfTheDay => 'GÜNÜN AYETİ';

  @override
  String get today => 'Bugün';

  @override
  String dailyGoalTapToStartPlan(int goal) {
    return 'Günlük hedef $goal ayet · hatim planı başlatmak için dokunun';
  }

  @override
  String khatmOnTrack(int day, int days) {
    return 'Hatim planı: yolunda · gün $day/$days';
  }

  @override
  String khatmBehind(int behind, int day, int days) {
    return 'Hatim planı: $behind ayet geride · gün $day/$days';
  }

  @override
  String get findSurahHint => 'Ad, anlam veya numaraya göre sure bul';

  @override
  String get tabSurah => 'Sure';

  @override
  String get tabJuz => 'Cüz';

  @override
  String get tabPage => 'Sayfa';

  @override
  String get noSurahMatches => 'Aramanızla eşleşen sure yok.';

  @override
  String surahSubtitle(String meaning, int count, String type) {
    return '$meaning · $count ayet · $type';
  }

  @override
  String get meccan => 'Mekkî';

  @override
  String get medinan => 'Medenî';

  @override
  String juzN(int n) {
    return 'Cüz $n';
  }

  @override
  String juzStartsAt(String surah, int ayah, int count) {
    return '$surah, ayet $ayah ile başlar · $count ayet';
  }

  @override
  String get jumpToSurah => 'Sureye git';

  @override
  String pageN(int n) {
    return 'Sayfa $n';
  }

  @override
  String get backToSurahs => 'Surelere dön';

  @override
  String get openMushafHere => 'Mushafı bu surede aç';

  @override
  String get translations => 'Mealler';

  @override
  String get readingSettings => 'Okuma ayarları';

  @override
  String get playSurah => 'Sureyi dinle';

  @override
  String get pauseRecitation => 'Tilaveti duraklat';

  @override
  String get memorizeThisSurah => 'Bu sureyi ezberle';

  @override
  String get openInMushaf => 'Mushafta aç';

  @override
  String juzPage(int juz, int page) {
    return 'Cüz $juz · Sayfa $page';
  }

  @override
  String get wordByWord => 'Kelime kelime';

  @override
  String get tafsir => 'Tefsir';

  @override
  String get bookmark => 'Yer imi';

  @override
  String get removeBookmark => 'Yer imini kaldır';

  @override
  String get bookmarkThisAyah => 'Bu ayeti kaydet';

  @override
  String get play => 'Oynat';

  @override
  String get pause => 'Duraklat';

  @override
  String get playFromThisAyah => 'Bu ayetten başlat';

  @override
  String get sajdahAyah => 'Secde ayeti';

  @override
  String couldNotLoad(String name) {
    return '$name yüklenemedi';
  }

  @override
  String wordByWordOffline(String error) {
    return 'Kelime kelime çevrimdışı kullanılamıyor ($error)';
  }

  @override
  String ayahN(int n) {
    return 'Ayet $n';
  }

  @override
  String get wordByWordSubtitle => 'Her kelimenin okunuşu ve anlamı';

  @override
  String get tafsirSubtitle => 'İbn Kesir ve diğerlerinin tefsiri';

  @override
  String get playRecitationFromHere => 'Tilaveti buradan başlat';

  @override
  String get memorizeFromHere => 'Buradan ezberle';

  @override
  String get memorizeSubtitle =>
      'Kelimeleri gizle, tek tek göster, tilaveti tekrarla';

  @override
  String get ayahCopied => 'Ayet kopyalandı';

  @override
  String wordN(int n) {
    return 'Kelime $n';
  }

  @override
  String get wordByWordNeedsInternet =>
      'Kelime kelime verisi ilk seferde internet bağlantısı gerektirir.';

  @override
  String get tafsirNeedsInternet =>
      'Tefsir ilk seferde internet bağlantısı gerektirir.';

  @override
  String get viaQuranCom => 'Quran.com aracılığıyla';

  @override
  String get reciter => 'Kârî';

  @override
  String get arabicSize => 'Arapça boyutu';

  @override
  String get translationSize => 'Meal boyutu';

  @override
  String get amiriQuran => 'Amiri Quran';

  @override
  String get amiriNaskh => 'Amiri Nesih';

  @override
  String get showTransliteration => 'Okunuşu göster';

  @override
  String get showTransliterationSubtitle =>
      'Her ayetin altında Latin harfleriyle okunuş';

  @override
  String get wordByWordMode => 'Kelime kelime modu';

  @override
  String get wordByWordModeSubtitle => 'Her kelime okunuşu ve anlamıyla';

  @override
  String get wordMeaningsLanguage => 'Kelime anlamı dili';

  @override
  String get tapAyahHint =>
      'Meal, okunuş, tefsir ve kelime kelime için bir ayete dokunun.';

  @override
  String get previousAyah => 'Önceki ayet';

  @override
  String get nextAyah => 'Sonraki ayet';

  @override
  String get stop => 'Durdur';

  @override
  String get loop => 'döngü';

  @override
  String get searchHint => 'Arapça, okunuş veya İngilizce…';

  @override
  String get searchWholeQuran => 'Tüm Kur\'an\'da ara';

  @override
  String get searchHelp =>
      'Arapça (harekeli veya harekesiz), Latin harfli bir ifade ya da İngilizce bir kelime yazın. Sonuçlar ayeti okuyucuda açar.';

  @override
  String noAyahMatches(String query) {
    return '\"$query\" ile eşleşen ayet yok';
  }

  @override
  String resultsCount(String count) {
    return '$count sonuç';
  }

  @override
  String get savedAyahs => 'Kayıtlı ayetler';

  @override
  String get noBookmarksYet => 'Henüz yer imi yok';

  @override
  String get noBookmarksHelp =>
      'Okurken bir ayetin yer imi simgesine dokunarak buraya kaydedin.';

  @override
  String get settings => 'Ayarlar';

  @override
  String get appearance => 'Görünüm';

  @override
  String get theme => 'Tema';

  @override
  String get arabicFont => 'Arapça yazı tipi';

  @override
  String get language => 'Uygulama dili';

  @override
  String get systemDefault => 'Sistem varsayılanı';

  @override
  String get recitation => 'Tilavet';

  @override
  String get recitationHelp =>
      'Ses everyayah.com\'dan ayet ayet akar. Bir ayette oynat\'a ya da sure başlığındaki \"Sureyi dinle\"ye dokunun.';

  @override
  String get reading => 'Okuma';

  @override
  String get wordByWordSettingSubtitle =>
      'Her kelimeyi okunuşu ve anlamıyla göster (sure başına bir kez indirilir)';

  @override
  String get defaultView => 'Varsayılan görünüm';

  @override
  String get viewTranslation => 'Meal';

  @override
  String get viewMushafBook => 'Mushaf';

  @override
  String get languages => 'Diller';

  @override
  String get arabicOnlyTapToAdd =>
      'Yalnızca Arapça — meal eklemek için dokunun';

  @override
  String translationsAvailable(int count, int languages) {
    return '$languages dilde $count meal mevcut. Her biri sure ilk açıldığında indirilir ve çevrimdışı saklanır.';
  }

  @override
  String get storage => 'Depolama';

  @override
  String get offlinePacks => 'Çevrimdışı paketler';

  @override
  String get offlinePacksSubtitle =>
      'Tüm Kur\'an için mealleri ve kelime kelimeyi indir';

  @override
  String get clearDownloadedData => 'İndirilen verileri temizle';

  @override
  String cachedDownloads(int count) {
    return '$count sure indirildi';
  }

  @override
  String get clearDownloadedDataQuestion => 'İndirilen veriler temizlensin mi?';

  @override
  String get clearDownloadedDataBody =>
      'Mealler ve kelime kelime verileri gerektiğinde yeniden indirilir. Yer imleri ve ayarlar korunur.';

  @override
  String get downloadedDataCleared => 'İndirilen veriler temizlendi';

  @override
  String get about => 'Hakkında';

  @override
  String get versionBuiltWith => 'Sürüm 1.0.0 · Flutter ile yapıldı';

  @override
  String get credits =>
      'Arapça metin: Tanzil Osmanî baskısı. Mealler ve okunuş: Al Quran Cloud. Kelime kelime ve tefsir: Quran.com. Tilavet: EveryAyah.com. Hadis: fawazahmed0/hadith-api. Yazı tipleri: Amiri ve Amiri Quran (SIL lisansı).';

  @override
  String selectedOfMax(int selected, int max) {
    return '$max içinden $selected seçili';
  }

  @override
  String get searchLanguageOrTranslator => 'Dil veya mütercim ara';

  @override
  String nTranslations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meal',
      one: '1 meal',
    );
    return '$_temp0';
  }

  @override
  String nSelected(int count) {
    return '$count seçili';
  }

  @override
  String get rightToLeftScript => 'Sağdan sola yazı';

  @override
  String translationLimit(int max) {
    return 'Aynı anda en fazla $max meal gösterebilirsiniz. Önce birini kaldırın.';
  }

  @override
  String get offlineIntro =>
      'Arapça metin, İngilizce okunuş ve üç İngilizce meal her zaman çevrimdışıdır. Geri kalanını bir kez indirip her yerde okuyun.';

  @override
  String get selectedTranslations => 'Seçili mealler';

  @override
  String get allSelectedBundled =>
      'Seçili tüm mealler uygulamayla birlikte gelir.';

  @override
  String surahDownloadsSaved(int done, int total) {
    return '$total surenin $done tanesi kaydedildi';
  }

  @override
  String wordByWordPack(String language) {
    return 'Kelime kelime ($language)';
  }

  @override
  String surahsSavedSize(int done) {
    return '114 surenin $done tanesi kaydedildi · yaklaşık 8 MB';
  }

  @override
  String get tafsirSavedAutomatically =>
      'Tefsir, açtığınız her ayet için otomatik kaydedilir.';

  @override
  String get downloadEverything => 'Seçili her şeyi indir';

  @override
  String bundledEditions(String names) {
    return 'Dahili baskılar: $names.';
  }

  @override
  String get everythingOffline => 'Seçili her şey zaten çevrimdışı mevcut.';

  @override
  String downloadDone(int count) {
    return 'Tamam. $count indirme çevrimdışı için kaydedildi.';
  }

  @override
  String downloadDoneWithFailures(int failed) {
    return '$failed başarısız indirmeyle tamamlandı (bağlantıyı kontrol edip tekrar çalıştırın).';
  }

  @override
  String downloadCancelled(int done, int total) {
    return '$total içinden $done sonra iptal edildi.';
  }

  @override
  String get starting => 'Başlatılıyor…';

  @override
  String get memorize => 'Ezber';

  @override
  String memorizeHeader(String surah, int from, int to, int done, int total) {
    return '$surah · Ayetler $from–$to · $done/$total ezberlendi';
  }

  @override
  String get changeRange => 'Aralığı değiştir';

  @override
  String wordsRevealed(int revealed, int total) {
    return '$revealed / $total kelime';
  }

  @override
  String get nextWord => 'Sonraki kelime';

  @override
  String get revealAll => 'Tümünü göster';

  @override
  String get hideAll => 'Tümünü gizle';

  @override
  String get transliteration => 'Okunuş';

  @override
  String get translation => 'Meal';

  @override
  String get memorized => 'Ezberlendi';

  @override
  String get markAsMemorized => 'Ezberlendi olarak işaretle';

  @override
  String get listenAndRepeat => 'Dinle ve tekrarla';

  @override
  String get repeatEachAyah => 'Her ayeti tekrarla';

  @override
  String get loopTheRange => 'Aralığı döngüye al';

  @override
  String playRange(int from, int to) {
    return '$from–$to dinle';
  }

  @override
  String get thisAyah => 'Bu ayet';

  @override
  String get ayahRange => 'Ayet aralığı';

  @override
  String fromToOf(int from, int to, int total) {
    return '$total içinden $from – $to';
  }

  @override
  String get readingPlan => 'Okuma planı';

  @override
  String get goalReached => 'Hedefe ulaşıldı, maşallah!';

  @override
  String moreAyahsToGoal(int count) {
    return 'Hedefe $count ayet kaldı';
  }

  @override
  String dayStreak(int days) {
    return '$days günlük seri';
  }

  @override
  String get dailyGoal => 'Günlük hedef';

  @override
  String ayahsPerDay(int count) {
    return 'Günde $count ayet';
  }

  @override
  String get khatmIn30Days => '208 (30 günde hatim)';

  @override
  String get last7Days => 'Son 7 gün';

  @override
  String get ayahsRead => 'Okunan ayet';

  @override
  String get activeDays => 'Aktif gün';

  @override
  String get quranRead => 'Okunan Kur\'an';

  @override
  String get khatmPlan => 'Hatim planı';

  @override
  String get khatmPlanHelp =>
      'Kur\'an\'ı bir takvime göre bitirin. Her gün ulaşmanız gereken ayeti söyleriz.';

  @override
  String nDays(int n) {
    return '$n gün';
  }

  @override
  String get startFromFatiha => 'Fatiha\'dan başla';

  @override
  String get fromTheBeginning => 'Baştan';

  @override
  String get fromWhereYouAre => 'Bulunduğunuz yerden';

  @override
  String aboutAyahsADay(int count) {
    return 'Günde yaklaşık $count ayet';
  }

  @override
  String get startPlan => 'Planı başlat';

  @override
  String get endPlan => 'Planı bitir';

  @override
  String planStatusLine(int day, int days, String date, int perDay) {
    return 'Gün $day/$days · bitiş $date · günde $perDay ayet';
  }

  @override
  String get onTrack => 'Planınız yolunda.';

  @override
  String onTrackAhead(int count) {
    return 'Planınız yolunda, $count ayet öndesiniz.';
  }

  @override
  String catchUp(int count) {
    return 'Yetişmek için bugün $count ayet daha okuyun.';
  }

  @override
  String todaysTarget(String surah, String key) {
    return 'Bugünün hedefi: $surah $key';
  }

  @override
  String get continueReadingButton => 'Okumaya devam et';

  @override
  String get hadith => 'Hadis';

  @override
  String get hadithIntro =>
      'Kütüb-i Sitte, Muvatta ve üç kırk hadis derlemesi, Arapça ve çevirisiyle. Her bölüm bir kez indirilir ve çevrimdışı kalır.';

  @override
  String hadithsChapters(int hadiths, int chapters) {
    return '$hadiths hadis · $chapters bölüm';
  }

  @override
  String couldNotLoadHadithBooks(String error) {
    return 'Hadis kitapları yüklenemedi: $error';
  }

  @override
  String get findAChapter => 'Bölüm bul';

  @override
  String hadithsRange(int first, int last) {
    return 'Hadisler $first–$last';
  }

  @override
  String chapterN(int n) {
    return 'Bölüm $n';
  }

  @override
  String get chapterNeedsInternet =>
      'Bu bölüm ilk seferde internet bağlantısı gerektirir.';

  @override
  String searchHadithsInChapter(int count) {
    return 'Bu bölümdeki $count hadiste ara';
  }

  @override
  String get previousChapter => 'Önceki bölüm';

  @override
  String get nextChapter => 'Sonraki bölüm';

  @override
  String get hadithCopied => 'Hadis kopyalandı';

  @override
  String get prayerTimes => 'Namaz vakitleri';

  @override
  String get prayerTimesForMasjid => 'Caminiz için namaz vakitleri';

  @override
  String get prayerIntro =>
      'Caminin tam adresini veya posta kodunu girin. Hassas koordinatlara ve saat dilimine çevrilir; ardından seçtiğiniz hesaplama yöntemiyle günlük namaz, ikamet ve cuma vakitleri üretilir.';

  @override
  String get setUpMasjid => 'Adresinden cami ekle';

  @override
  String get useMyLocation => 'Mevcut konumumu kullan';

  @override
  String get methodsList =>
      'Hesaplama yöntemleri: ISNA, Dünya İslam Birliği, Mısır, Karaçi, Ümmü\'l-Kura, Körfez, Kuveyt, Katar, Singapur, Diyanet, UOIF, Rusya, Tahran ve Caferî. İkindi: Şafiî/Malikî/Hanbelî veya Hanefî.';

  @override
  String couldNotGetLocation(String error) {
    return 'Konumunuz alınamadı: $error';
  }

  @override
  String get monthlyTimetable => 'Aylık imsakiye';

  @override
  String get shareToday => 'Bugünü paylaş';

  @override
  String get editMasjid => 'Camiyi düzenle';

  @override
  String get addAnotherMasjid => 'Başka cami ekle';

  @override
  String get removeMasjid => 'Camiyi kaldır';

  @override
  String removeMasjidQuestion(String name) {
    return '$name kaldırılsın mı?';
  }

  @override
  String get removeMasjidBody =>
      'Adresi, hesaplama ayarları, ikamet ve cuma vakitleri silinecek.';

  @override
  String nextPrayerIn(String prayer, String time, String duration) {
    return '$prayer $time · $duration sonra';
  }

  @override
  String get fajrTomorrow => 'İmsak (yarın)';

  @override
  String get jumuah => 'Cuma';

  @override
  String get noJumuahSet =>
      'Cuma vakti ayarlanmamış. Eklemek için camiyi düzenleyin.';

  @override
  String khutbahAt(String time) {
    return 'Hutbe $time';
  }

  @override
  String iqamaAt(String time) {
    return 'İkamet $time';
  }

  @override
  String timesFootnote(String lat, String lng, String tz) {
    return 'Vakitler $tz dilimindeki $lat, $lng için astronomik olarak hesaplanıp dakikaya yuvarlanır. Hicrî tarih hesaplanmıştır ve yerel hilal gözleminden bir gün farklı olabilir.';
  }

  @override
  String qiblaDegrees(int degrees) {
    return 'Kıble $degrees°';
  }

  @override
  String get asrShafii => 'İkindi Şafiî';

  @override
  String get asrHanafi => 'İkindi Hanefî';

  @override
  String get fajr => 'İmsak';

  @override
  String get sunrise => 'Güneş';

  @override
  String get dhuhr => 'Öğle';

  @override
  String get asr => 'İkindi';

  @override
  String get maghrib => 'Akşam';

  @override
  String get isha => 'Yatsı';

  @override
  String get addMasjid => 'Cami ekle';

  @override
  String get masjid => 'Cami';

  @override
  String get masjidName => 'Cami adı';

  @override
  String get enterAName => 'Bir ad girin';

  @override
  String get address => 'Adres';

  @override
  String get streetAddress => 'Sokak adresi';

  @override
  String get city => 'Şehir';

  @override
  String get stateProvince => 'İl / Eyalet';

  @override
  String get postalCode => 'Posta kodu';

  @override
  String get countryCode => 'Ülke kodu (TR, US, DE…)';

  @override
  String get findLocation => 'Konumu bul';

  @override
  String get deviceGps => 'Cihaz GPS';

  @override
  String get coordinatesAndTimeZone => 'Koordinatlar ve saat dilimi';

  @override
  String get setAutomatically => 'Adresten otomatik ayarlanır';

  @override
  String get latitude => 'Enlem';

  @override
  String get longitude => 'Boylam';

  @override
  String get ianaTimeZone => 'IANA saat dilimi (ör. Europe/Istanbul)';

  @override
  String get calculation => 'Hesaplama';

  @override
  String get calculationMethod => 'Hesaplama yöntemi';

  @override
  String get asrShafiiFull => 'İkindi: Şafiî / Malikî / Hanbelî';

  @override
  String get asrHanafiFull => 'İkindi: Hanefî';

  @override
  String get dhuhrAfterZawal => 'Öğle: zevalden sonra dakika';

  @override
  String get maghribAfterSunset => 'Akşam: gün batımından sonra dakika';

  @override
  String get fineTune => 'Her vakti ince ayarla (dakika)';

  @override
  String get hijriAdjustment => 'Hicrî tarih düzeltmesi (gün)';

  @override
  String get iqama => 'İkamet';

  @override
  String get jumuahServices => 'Cuma namazları';

  @override
  String get addJumuahTime => 'Cuma vakti ekle';

  @override
  String get addAnotherService => 'Başka namaz ekle';

  @override
  String get saveMasjid => 'Camiyi kaydet';

  @override
  String get none => 'Yok';

  @override
  String get fixed => 'Sabit';

  @override
  String get plusMinutes => '+ dk';

  @override
  String get khutbahPicker => 'Hutbe…';

  @override
  String get jumuahLabelHint => 'Etiket (dil, salon, hatip)';

  @override
  String get enterZipOrCity => 'En azından posta kodu veya şehir girin.';

  @override
  String get lookingUpAddress => 'Adres aranıyor…';

  @override
  String get noMatchTryCountry =>
      'Eşleşme yok. Şehri ve 2 harfli ülke kodunu (ör. TR, US, GB) ekleyin.';

  @override
  String get chooseLocation => 'Doğru konumu seçin:';

  @override
  String lookupFailed(String error) {
    return 'Arama başarısız: $error';
  }

  @override
  String get resolvingTimeZone => 'Saat dilimi belirleniyor…';

  @override
  String located(String name) {
    return 'Bulundu: $name';
  }

  @override
  String timeZoneLookupFailed(String error) {
    return 'Koordinatlar ayarlandı ancak saat dilimi bulunamadı ($error). Europe/Istanbul gibi bir IANA dilimi girin.';
  }

  @override
  String get gettingPosition => 'Konumunuz alınıyor…';

  @override
  String couldNotUseDevice(String error) {
    return 'Cihaz konumu kullanılamadı: $error';
  }

  @override
  String get findLocationFirst =>
      'Koordinat ve saat diliminin ayarlanması için önce \"Konumu bul\"a dokunun.';

  @override
  String get setUpMasjidFirst => 'Önce bir cami ekleyin.';

  @override
  String get hideIqama => 'İkameti gizle';

  @override
  String get showIqama => 'İkameti göster';

  @override
  String get copyAsCsv => 'CSV olarak kopyala';

  @override
  String get csvCopied => 'CSV kopyalandı — Excel veya Sheets\'e yapıştırın';

  @override
  String get shareAsText => 'Metin olarak paylaş';

  @override
  String get thisMonth => 'Bu ay';

  @override
  String get date => 'Tarih';

  @override
  String get mushafLayout => 'Düzen';

  @override
  String get layoutAutomatic => 'Otomatik';

  @override
  String get layoutScroll => 'Tek sayfa, aşağı kaydır';

  @override
  String get layoutFlip => 'Tek sayfa, çevir';

  @override
  String get layoutBook => 'İki sayfa, çevir';

  @override
  String get playThisPage => 'Bu sayfayı dinle';

  @override
  String get goToPage => 'Sayfaya git';

  @override
  String get goTo => 'Git';

  @override
  String get pageRange => 'Sayfa (1–604)';

  @override
  String get previousPage => 'Önceki sayfa';

  @override
  String get nextPage => 'Sonraki sayfa';

  @override
  String pageJuz(int page, int juz) {
    return 'Sayfa $page · Cüz $juz';
  }

  @override
  String get library => 'Kütüphane';

  @override
  String get openBook => 'Kitabı aç';

  @override
  String get tableOfContents => 'İçindekiler';

  @override
  String chapterPage(int chapter, int page, int total) {
    return 'Bölüm $chapter · Sayfa $page / $total';
  }

  @override
  String get listView => 'Liste görünümü';

  @override
  String get downloadPdf => 'PDF indir';

  @override
  String get downloadChapterPdf => 'Bu bölümü PDF olarak indir';

  @override
  String get downloadBookPdf => 'Tüm kitabı PDF olarak indir';

  @override
  String preparingPdf(int done, int total) {
    return 'Bölümler alınıyor… $done / $total';
  }

  @override
  String get renderingPdf => 'PDF oluşturuluyor…';

  @override
  String pdfFailed(String error) {
    return 'PDF oluşturulamadı: $error';
  }

  @override
  String hadithsCount(int count) {
    return '$count hadis';
  }

  @override
  String byAuthor(String author) {
    return '$author tarafından';
  }

  @override
  String get reciteAndCheck => 'Oku ve kontrol et';

  @override
  String get reciteFromHere => 'Buradan oku';

  @override
  String get reciteSubtitle =>
      'Ezberden okuyun; uygulama dinler ve her kelimeyi işaretler';

  @override
  String ayahRangeLabel(int from, int to) {
    return 'Ayetler $from–$to';
  }

  @override
  String get accuracy => 'doğruluk';

  @override
  String get matchedWords => 'doğru';

  @override
  String get wrongWords => 'yanlış';

  @override
  String get missedWords => 'atlanan';

  @override
  String wordsReached(int reached, int total) {
    return '$total kelimeden $reached tanesi okundu';
  }

  @override
  String get listening => 'Dinleniyor…';

  @override
  String get waitingForSpeech => 'Ses bekleniyor…';

  @override
  String get tapMicToStart => 'Mikrofona dokunun ve okumaya başlayın';

  @override
  String get heard => 'Duyulan';

  @override
  String get notInPassage => 'Pasajda olmayan kelimeler';

  @override
  String get hideText => 'Metni gizle (ezber)';

  @override
  String get showText => 'Metni göster';

  @override
  String get hint => 'İpucu';

  @override
  String get reset => 'Sıfırla';

  @override
  String get playThisAyah => 'Bu ayeti dinle';

  @override
  String get speechUnavailable =>
      'Konuşma tanıma kullanılamıyor. Mikrofon iznini verin veya web\'de Chrome kullanın.';

  @override
  String get reciteHelp =>
      'Sessiz bir yerde açık ve düzenli bir tempoda okuyun; doğru kelimeler yeşil, hatalar turuncu, atlananlar kırmızı olur.';

  @override
  String get qibla => 'Kıble';

  @override
  String get qiblaBearing => 'Gerçek kuzeye göre kıble açısı';

  @override
  String get qiblaNeedsLocation =>
      'Kıble konumunuzdan hesaplanır. Cihazın GPS\'ini kullanın ya da önce bir cami ekleyin.';

  @override
  String distanceToMakkah(int km) {
    return 'Mekke\'ye $km km';
  }

  @override
  String headingDegrees(int degrees) {
    return 'Yön $degrees°';
  }

  @override
  String get facingQibla => 'Kıbleye dönüksünüz';

  @override
  String get compassWaiting =>
      'Pusula bekleniyor… kalibrasyon için telefonu 8 çizer gibi hareket ettirin.';

  @override
  String get compassUnavailable =>
      'Bu cihazda pusula yok: bir pusula ya da harita kullanıp yukarıdaki açıya dönün.';

  @override
  String turnToQibla(String direction, int degrees) {
    return '$degrees° $direction dönün';
  }

  @override
  String get left => 'sola';

  @override
  String get right => 'sağa';

  @override
  String get qiblaHelp =>
      'Telefonu düz tutun, mıknatıs ve metalden uzak durun. Kadrandaki Kâbe işareti kıbleyi, üstteki ok baktığınız yönü gösterir.';

  @override
  String get adhan => 'Ezan';

  @override
  String get adhanIntro =>
      'Farklı müezzinlerden ezan dinleyin, kaydı indirin ve namaz vakitleriniz için varsayılan ezanı seçin.';

  @override
  String get adhanCredits =>
      'Kayıtlar Internet Archive \"adhans\" ve \"azan-alafasy\" koleksiyonlarından.';

  @override
  String downloaded(String name) {
    return '$name indirildi';
  }

  @override
  String downloadFailed(String error) {
    return 'İndirme başarısız: $error';
  }

  @override
  String get downloadSurahAudio => 'Sure sesini çevrimdışı için indir';

  @override
  String get downloadAyahAudio => 'Bu ayetin sesini indir (MP3)';

  @override
  String get offlineAudioNativeOnly =>
      'Çevrimdışı ses mobil ve masaüstü uygulamalarda saklanır; web\'de ayetleri tek tek indirin.';

  @override
  String surahAudioSaved(String surah) {
    return '$surah çevrimdışı dinleme için kaydedildi';
  }

  @override
  String get downloadForOffline => 'Çevrimdışı okumak için indir';

  @override
  String savedForOffline(String name) {
    return '$name çevrimdışı okuma için kaydedildi';
  }

  @override
  String get playAdhan => 'Ezanı çal';

  @override
  String adhanForNext(String prayer) {
    return '$prayer ezanı';
  }

  @override
  String get chooseAdhan => 'Ezan seç';

  @override
  String get pageAnimation => 'Sayfa animasyonu';

  @override
  String get animationCurl => 'Sayfa kıvrımı';

  @override
  String get animationFlip => 'Kart çevirme';

  @override
  String get animationSlide => 'Kaydırma';

  @override
  String get animationFade => 'Solma';

  @override
  String get highlight => 'Vurgula';

  @override
  String get removeHighlight => 'Vurguyu kaldır';

  @override
  String get note => 'Not';

  @override
  String get noteHint => 'Bu ayet için düşüncenizi veya hatırlatmanızı yazın…';

  @override
  String get noteSaved => 'Not kaydedildi';

  @override
  String get noteHelp =>
      'Notlar bu cihazda kalır. Vurgulanan ayetler Mushaf sayfalarında renkli görünür.';

  @override
  String get continuous => 'Otomatik devam';

  @override
  String get repeatEach => 'Tekrar';

  @override
  String get verseDetails => 'Ayet ayrıntıları';

  @override
  String get zoomIn => 'Yakınlaştır';

  @override
  String get zoomOut => 'Uzaklaştır';

  @override
  String get fitPage => 'Sayfaya sığdır';

  @override
  String get shareEmbed => 'Paylaş ve göm';

  @override
  String get websiteWidget => 'Web sitesi widget’ı ve TV ekranı';

  @override
  String get widgetLinks => 'Herkese açık bağlantılar';

  @override
  String get embedCode => 'Gömme kodu';

  @override
  String get openLink => 'Aç';

  @override
  String get linkCopied => 'Bağlantı kopyalandı';

  @override
  String get codeCopied => 'Gömme kodu kopyalandı';

  @override
  String get combinedWidget => 'Birleşik widget (günlük + Cuma)';

  @override
  String get dailyWidget => 'Günlük namaz widget’ı';

  @override
  String get jumuahWidget => 'Cuma namazı widget’ı';

  @override
  String get compactWidget => 'Kompakt widget';

  @override
  String get tvDisplay => 'TV ekranı';

  @override
  String get darkWidget => 'Koyu widget';

  @override
  String get embedHelp =>
      'Gömme kodunu caminizin web sitesine yapıştırın veya bağlantıyı paylaşın. Bağlantı caminin konumunu, yöntemini, ikamet ve Cuma saatlerini taşır; değiştirdikten sonra yeniden kopyalayın. Herhangi bir bağlantıya ?theme=dark veya &scale=120, &lang=ar ekleyin.';

  @override
  String get preview => 'Önizleme';

  @override
  String get adhanHeader => 'Ezan';

  @override
  String get poweredBy => 'Mushaf+ ile';

  @override
  String get invalidWidgetLink => 'Bu widget bağlantısı geçersiz veya eksik.';

  @override
  String get micDenied =>
      'Mikrofon erişimi reddedildi. Tarayıcı veya sistem ayarlarından bu siteye izin verin ve yeniden deneyin.';

  @override
  String get noSpeechYet =>
      'Henüz bir şey duyulmadı. Mikrofona yakın ve net okuyun; tanınan kelimeler burada görünür.';

  @override
  String get speechNotice => 'Tanıma bildirimi';

  @override
  String get speechTip =>
      'Doğru kelimeler yeşile, yanlışlar sesli uyarı ve titreşimle kırmızıya döner; bir hatadan sonra okumaya devam edin, denetleyici sizi izler.';

  @override
  String get strictMode => 'Katı';

  @override
  String get lenientMode => 'Esnek';

  @override
  String get strictHelp =>
      'Katı mod: bir kelime ancak her harfi eşleştiğinde doğru sayılır. Harekeler ve tecvid denetlenemez: konuşma tanıma yalnızca harfleri döndürür.';

  @override
  String get tjHamzatWasl => 'Vasıl hemzesi';

  @override
  String get tjSilent => 'Okunmayan harf';

  @override
  String get tjLaamShamsiyyah => 'Şemsî lam';

  @override
  String get tjMaddNormal => 'Tabiî med';

  @override
  String get tjMaddPermissible => 'Caiz med';

  @override
  String get tjMaddNecessary => 'Lâzım med';

  @override
  String get tjQalqalah => 'Kalkale';

  @override
  String get tjMaddObligatory => 'Vacip muttasıl med';

  @override
  String get tjIkhfaShafawi => 'Dudak ihfası';

  @override
  String get tjIkhfa => 'İhfa';

  @override
  String get tjIdghamShafawi => 'Dudak idgamı';

  @override
  String get tjIqlab => 'İklab';

  @override
  String get tjIdghamGhunnah => 'Gunneli idgam';

  @override
  String get tjIdghamNoGhunnah => 'Gunnesiz idgam';

  @override
  String get tjIdghamMutajanisayn => 'Mütecaniseyn idgamı';

  @override
  String get tjIdghamMutaqaribayn => 'Mütekaribeyn idgamı';

  @override
  String get tjGhunnah => 'Gunne';

  @override
  String get tjdHamzatWasl =>
      'Kelime başındaki bağlama hemzesi: yalnızca o kelimeyle başlarken okunur; önceki kelimeden geçerken okunmaz.';

  @override
  String get tjdSilent =>
      'Mushafta yazılı olup okunmayan harf, örneğin çoğul vavından sonraki elif. Okurken atlanır.';

  @override
  String get tjdLaamShamsiyyah =>
      'Şemsî harften önceki tanım lamı okunmaz; yerine şemsî harf şeddeli okunur: ٱلشَّمْس → eş-şems.';

  @override
  String get tjdMaddNormal =>
      'Tabiî med: uzun ünlüyü iki hareke uzatın, ne az ne fazla.';

  @override
  String get tjdMaddPermissible =>
      'Med harfi sonraki kelimede hemzeyle veya vakıf sükûnuyla karşılaştığında iki, dört ya da altı hareke uzatın; okuyuş boyunca aynı ölçüde kalın.';

  @override
  String get tjdMaddNecessary =>
      'Med harfinden sonra aslî sükûn veya şedde geldiğinde, sure başı harfleri dâhil, altı hareke uzatın.';

  @override
  String get tjdQalqalah =>
      'Sükûnlu ق ط ب ج د harflerinde yankılı bir sıçrama; harfi hafif geri sekerek bırakın, vakıfta daha belirgin.';

  @override
  String get tjdMaddObligatory =>
      'Aynı kelimede med harfinden sonra hemze gelirse dört-beş hareke uzatın.';

  @override
  String get tjdIkhfaShafawi =>
      'Sâkin mimden sonra ب: dudakları hafifçe kapatıp mimi iki hareke gunne ile gizleyin.';

  @override
  String get tjdIkhfa =>
      'Sâkin nun veya tenvinden sonra on beş ihfa harfinden biri: nunu iki hareke gunne ile gizleyin, dil sonraki harfe hazır olsun.';

  @override
  String get tjdIdghamShafawi =>
      'Sâkin mimden sonra mim: iki hareke gunne ile tek şeddeli mim olarak birleştirin.';

  @override
  String get tjdIqlab =>
      'Sâkin nun veya tenvinden sonra ب: nun, iki hareke gunne ve hafif kapalı dudaklarla gizlenen mime dönüşür.';

  @override
  String get tjdIdghamGhunnah =>
      'Sâkin nun veya tenvinden sonra bir sonraki kelimenin başında ي ن م و gelirse o harfe iki hareke gunne ile katılır.';

  @override
  String get tjdIdghamNoGhunnah =>
      'Sâkin nun veya tenvinden sonra ل ya da ر gelirse gunnesiz, tam olarak o harfe katılır.';

  @override
  String get tjdIdghamMutajanisayn =>
      'Aynı mahreçten iki harf, ilki sâkin, tek şeddeli harfe katılır: قَد تَّبَيَّنَ.';

  @override
  String get tjdIdghamMutaqaribayn =>
      'Mahreçleri yakın iki harf, ilki sâkin, ikincisine katılır: قُل رَّبِّ.';

  @override
  String get tjdGhunnah =>
      'Şeddeli mim ve nunda iki hareke süren genizden gelen ses.';

  @override
  String get tjgMadd => 'Med';

  @override
  String get tjgNunTanwin => 'Sâkin nun ve tenvin';

  @override
  String get tjgMeemSakinah => 'Sâkin mim';

  @override
  String get tjgGhunnah => 'Gunne';

  @override
  String get tjgQalqalah => 'Kalkale';

  @override
  String get tjgLam => 'Lam';

  @override
  String get tjgSilent => 'Okunmayan harfler';

  @override
  String get tjgIdghamAdjacent => 'Bitişik harflerin idgamı';

  @override
  String get tajweed => 'Tecvid';

  @override
  String get tajweedColors => 'Tecvid renkleri';

  @override
  String get tajweedColorsSubtitle =>
      'Mushaf ve okuyucudaki harfleri tecvid kuralına göre renklendir';

  @override
  String get tajweedGuide => 'Tecvid rehberi';

  @override
  String get tajweedLegend => 'Tecvid renk açıklaması';

  @override
  String get seeGuide => 'Tam rehber';

  @override
  String get tajweedIntro =>
      'Tecvid, her harfi mahrecinden sıfatlarıyla okumaktır: med olan yerde uzatma, gunne olan yerde genizden ses, kurallar gerektirdiğinde ihfa, idgam ve kalkale. Mushaf, kural taşıyan her harfi renklendirir; bir kelimeye dokunarak kurallarını ve nasıl okunacağını görün. Kurallar Hafs an Âsım rivayetine göredir.';

  @override
  String get rulesInThisWord => 'Bu kelimedeki tecvid';

  @override
  String get noRulesInWord =>
      'Bu kelimede işaretli bir tecvid kuralı yok: harflerini mahreçlerinden düz okuyun.';

  @override
  String get wordTab => 'Kelime';

  @override
  String wordOfN(int n, int total) {
    return 'Kelime $n / $total';
  }

  @override
  String get playWord => 'Kelimeyi dinle';

  @override
  String get example => 'Örnek';

  @override
  String get triggerLetters => 'Harfler';

  @override
  String countsValue(String n) {
    return '$n hareke';
  }

  @override
  String tuhfaRef(String lines) {
    return 'Tuhfetü’l-Etfâl, beyit $lines';
  }

  @override
  String jazariyyahRef(String lines) {
    return 'Cezeriyye, beyit $lines';
  }

  @override
  String get tajweedSource =>
      'Kurallar ve renkler alquran.cloud tecvid rehberine (Hafs rivayeti, Tanzil Osmanî metni) ve quran.com’un kullandığı KFGQPC renk düzenine dayanır. Beyit atıfları Tuhfetü’l-Etfâl ve Mukaddimetü’l-Cezeriyye’yedir.';

  @override
  String get fullScreen => 'Tam ekran';

  @override
  String get exitFullScreen => 'Tam ekrandan çık';

  @override
  String get playbackSpeed => 'Hız';

  @override
  String get chooseReciter => 'Okuyucu seç';

  @override
  String get approximateLocation =>
      'Yalnızca bölge (posta kodu veya şehir) bulundu; koordinatlar bölgenin merkezidir. Tam koordinatları biliyorsanız aşağıya girin.';

  @override
  String get privacyPolicy => 'Gizlilik politikası';

  @override
  String pdfReady(String size) {
    return 'PDF hazır ($size)';
  }

  @override
  String get openPdf => 'Aç';

  @override
  String get savePdf => 'Kaydet';

  @override
  String get offlineSavedBody =>
      'Kitap bu cihazda geçerli hadis dilinde saklanır ve kütüphaneden internetsiz açılır. Dili değiştirdikten sonra yeniden indirin.';

  @override
  String get adhkar => 'Zikirler';

  @override
  String get hisnAlMuslim => 'Hısnu’l-Müslim';

  @override
  String get hisnAlMuslimSubtitle =>
      'Müslümanın Kalesi · Kur’an ve Sünnet’ten zikir ve dualar';

  @override
  String get adhkarIntro =>
      'Said el-Kahtânî’nin Hısnu’l-Müslim’inden günlük zikir ve dualar; tekrar sayacı ve sesli okuma ile.';

  @override
  String repeatProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get playChapter => 'Bölümü dinle';

  @override
  String get resetCounters => 'Sayaçları sıfırla';

  @override
  String get adhkarLanguageNote =>
      'Çeviriler hisnmuslim.com’dan alınmıştır ve yalnızca İngilizce ve Arapça mevcuttur.';

  @override
  String get findAdhkar => 'Bölüm ara…';

  @override
  String get morning => 'Sabah';

  @override
  String get evening => 'Akşam';

  @override
  String get sleep => 'Uyku';

  @override
  String get afterPrayer => 'Namaz sonrası';

  @override
  String get allDone => 'Tamamlandı';

  @override
  String timesN(int n) {
    return '×$n';
  }

  @override
  String get readAloud => 'Sesli oku';

  @override
  String get stopReading => 'Okumayı durdur';

  @override
  String get ttsUnavailable =>
      'Bu cihazda bu dil için ses yüklü değil. Hadisler cihazın metin okuma sesleriyle okunur.';
}
