// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'مصحف+';

  @override
  String get navRead => 'پڑھیں';

  @override
  String get navHadith => 'حدیث';

  @override
  String get navPrayer => 'نماز';

  @override
  String get navSaved => 'محفوظ';

  @override
  String get navSettings => 'ترتیبات';

  @override
  String get search => 'تلاش';

  @override
  String get searchTheQuran => 'قرآن میں تلاش کریں';

  @override
  String get cancel => 'منسوخ';

  @override
  String get open => 'کھولیں';

  @override
  String get apply => 'لاگو کریں';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get retry => 'دوبارہ کوشش';

  @override
  String get copy => 'کاپی';

  @override
  String get share => 'شیئر';

  @override
  String get clear => 'صاف کریں';

  @override
  String get remove => 'ہٹائیں';

  @override
  String get download => 'ڈاؤن لوڈ';

  @override
  String get more => 'مزید';

  @override
  String get back => 'واپس';

  @override
  String get loading => 'لوڈ ہو رہا ہے…';

  @override
  String get couldNotLoadQuran => 'قرآن کا ڈیٹا لوڈ نہیں ہو سکا۔';

  @override
  String get continueReading => 'پڑھنا جاری رکھیں';

  @override
  String get startReading => 'پڑھنا شروع کریں';

  @override
  String ayahOfJuzPage(int ayah, int total, int juz, int page) {
    return 'آیت $ayah از $total · پارہ $juz · صفحہ $page';
  }

  @override
  String get verseOfTheDay => 'آج کی آیت';

  @override
  String get today => 'آج';

  @override
  String dailyGoalTapToStartPlan(int goal) {
    return 'روزانہ ہدف $goal آیات · ختم قرآن کا منصوبہ شروع کرنے کے لیے دبائیں';
  }

  @override
  String khatmOnTrack(int day, int days) {
    return 'ختم قرآن: ہدف کے مطابق · دن $day/$days';
  }

  @override
  String khatmBehind(int behind, int day, int days) {
    return 'ختم قرآن: $behind آیات پیچھے · دن $day/$days';
  }

  @override
  String get findSurahHint => 'نام، معنی یا نمبر سے سورت تلاش کریں';

  @override
  String get tabSurah => 'سورت';

  @override
  String get tabJuz => 'پارہ';

  @override
  String get tabPage => 'صفحہ';

  @override
  String get noSurahMatches => 'کوئی سورت آپ کی تلاش سے مطابقت نہیں رکھتی۔';

  @override
  String surahSubtitle(String meaning, int count, String type) {
    return '$meaning · $count آیات · $type';
  }

  @override
  String get meccan => 'مکی';

  @override
  String get medinan => 'مدنی';

  @override
  String juzN(int n) {
    return 'پارہ $n';
  }

  @override
  String juzStartsAt(String surah, int ayah, int count) {
    return '$surah، آیت $ayah سے شروع · $count آیات';
  }

  @override
  String get jumpToSurah => 'سورت پر جائیں';

  @override
  String pageN(int n) {
    return 'صفحہ $n';
  }

  @override
  String get backToSurahs => 'سورتوں پر واپس';

  @override
  String get openMushafHere => 'اس سورت پر مصحف کھولیں';

  @override
  String get translations => 'تراجم';

  @override
  String get readingSettings => 'پڑھنے کی ترتیبات';

  @override
  String get playSurah => 'سورت چلائیں';

  @override
  String get pauseRecitation => 'تلاوت روکیں';

  @override
  String get memorizeThisSurah => 'یہ سورت یاد کریں';

  @override
  String get openInMushaf => 'مصحف میں کھولیں';

  @override
  String juzPage(int juz, int page) {
    return 'پارہ $juz · صفحہ $page';
  }

  @override
  String get wordByWord => 'لفظ بہ لفظ';

  @override
  String get tafsir => 'تفسیر';

  @override
  String get bookmark => 'نشانی';

  @override
  String get removeBookmark => 'نشانی ہٹائیں';

  @override
  String get bookmarkThisAyah => 'یہ آیت محفوظ کریں';

  @override
  String get play => 'چلائیں';

  @override
  String get pause => 'روکیں';

  @override
  String get playFromThisAyah => 'اس آیت سے چلائیں';

  @override
  String get sajdahAyah => 'آیتِ سجدہ';

  @override
  String couldNotLoad(String name) {
    return '$name لوڈ نہیں ہو سکا';
  }

  @override
  String wordByWordOffline(String error) {
    return 'لفظ بہ لفظ آف لائن دستیاب نہیں ($error)';
  }

  @override
  String ayahN(int n) {
    return 'آیت $n';
  }

  @override
  String get wordByWordSubtitle => 'ہر لفظ کا تلفظ اور معنی';

  @override
  String get tafsirSubtitle => 'ابن کثیر اور دیگر کی تفسیر';

  @override
  String get playRecitationFromHere => 'یہاں سے تلاوت چلائیں';

  @override
  String get memorizeFromHere => 'یہاں سے یاد کریں';

  @override
  String get memorizeSubtitle =>
      'الفاظ چھپائیں، ایک ایک کر کے ظاہر کریں، تلاوت دہرائیں';

  @override
  String get ayahCopied => 'آیت کاپی ہو گئی';

  @override
  String wordN(int n) {
    return 'لفظ $n';
  }

  @override
  String get wordByWordNeedsInternet =>
      'لفظ بہ لفظ ڈیٹا کے لیے پہلی بار انٹرنیٹ درکار ہے۔';

  @override
  String get tafsirNeedsInternet => 'تفسیر کے لیے پہلی بار انٹرنیٹ درکار ہے۔';

  @override
  String get viaQuranCom => 'بذریعہ Quran.com';

  @override
  String get reciter => 'قاری';

  @override
  String get arabicSize => 'عربی کا سائز';

  @override
  String get translationSize => 'ترجمے کا سائز';

  @override
  String get amiriQuran => 'امیری قرآن';

  @override
  String get amiriNaskh => 'امیری نسخ';

  @override
  String get showTransliteration => 'رومن تلفظ دکھائیں';

  @override
  String get showTransliterationSubtitle => 'ہر آیت کے نیچے رومن حروف میں تلفظ';

  @override
  String get wordByWordMode => 'لفظ بہ لفظ موڈ';

  @override
  String get wordByWordModeSubtitle => 'ہر لفظ اس کے تلفظ اور معنی کے ساتھ';

  @override
  String get wordMeaningsLanguage => 'الفاظ کے معنی کی زبان';

  @override
  String get tapAyahHint =>
      'ترجمہ، تلفظ، تفسیر اور لفظ بہ لفظ کے لیے کسی آیت کو دبائیں۔';

  @override
  String get previousAyah => 'پچھلی آیت';

  @override
  String get nextAyah => 'اگلی آیت';

  @override
  String get stop => 'بند کریں';

  @override
  String get loop => 'دہرائیں';

  @override
  String get searchHint => 'عربی، رومن تلفظ یا انگریزی…';

  @override
  String get searchWholeQuran => 'پورے قرآن میں تلاش کریں';

  @override
  String get searchHelp =>
      'عربی (اعراب کے ساتھ یا بغیر)، رومن تلفظ کا جملہ یا انگریزی لفظ لکھیں۔ نتائج آیت کو ریڈر میں کھولتے ہیں۔';

  @override
  String noAyahMatches(String query) {
    return '\"$query\" سے کوئی آیت مطابقت نہیں رکھتی';
  }

  @override
  String resultsCount(String count) {
    return '$count نتائج';
  }

  @override
  String get savedAyahs => 'محفوظ آیات';

  @override
  String get noBookmarksYet => 'ابھی کوئی نشانی نہیں';

  @override
  String get noBookmarksHelp =>
      'پڑھتے وقت کسی آیت پر نشانی کے آئیکن کو دبائیں تاکہ وہ یہاں محفوظ ہو جائے۔';

  @override
  String get settings => 'ترتیبات';

  @override
  String get appearance => 'ظاہری شکل';

  @override
  String get theme => 'تھیم';

  @override
  String get arabicFont => 'عربی فونٹ';

  @override
  String get language => 'ایپ کی زبان';

  @override
  String get systemDefault => 'سسٹم کی زبان';

  @override
  String get recitation => 'تلاوت';

  @override
  String get recitationHelp =>
      'آڈیو everyayah.com سے آیت بہ آیت چلتی ہے۔ کسی آیت پر پلے دبائیں یا سورت کے سرنامے میں \"سورت چلائیں\"۔';

  @override
  String get reading => 'پڑھنا';

  @override
  String get wordByWordSettingSubtitle =>
      'ہر لفظ اس کے تلفظ اور معنی کے ساتھ دکھائیں (ہر سورت کے لیے ایک بار ڈاؤن لوڈ)';

  @override
  String get defaultView => 'طے شدہ منظر';

  @override
  String get viewTranslation => 'ترجمہ';

  @override
  String get viewMushafBook => 'مصحف';

  @override
  String get languages => 'زبانیں';

  @override
  String get arabicOnlyTapToAdd => 'صرف عربی — تراجم شامل کرنے کے لیے دبائیں';

  @override
  String translationsAvailable(int count, int languages) {
    return '$languages زبانوں میں $count تراجم دستیاب ہیں۔ ہر ایک سورت پہلی بار کھولنے پر ڈاؤن لوڈ ہو کر آف لائن محفوظ رہتا ہے۔';
  }

  @override
  String get storage => 'اسٹوریج';

  @override
  String get offlinePacks => 'آف لائن پیک';

  @override
  String get offlinePacksSubtitle =>
      'پورے قرآن کے تراجم اور لفظ بہ لفظ ڈاؤن لوڈ کریں';

  @override
  String get clearDownloadedData => 'ڈاؤن لوڈ شدہ ڈیٹا صاف کریں';

  @override
  String cachedDownloads(int count) {
    return '$count سورتیں ڈاؤن لوڈ شدہ';
  }

  @override
  String get clearDownloadedDataQuestion => 'ڈاؤن لوڈ شدہ ڈیٹا صاف کریں؟';

  @override
  String get clearDownloadedDataBody =>
      'تراجم اور لفظ بہ لفظ ڈیٹا ضرورت پر دوبارہ ڈاؤن لوڈ ہوں گے۔ نشانیاں اور ترتیبات محفوظ رہیں گی۔';

  @override
  String get downloadedDataCleared => 'ڈاؤن لوڈ شدہ ڈیٹا صاف ہو گیا';

  @override
  String get about => 'تعارف';

  @override
  String get versionBuiltWith => 'ورژن 1.0.0 · Flutter سے بنایا گیا';

  @override
  String get credits =>
      'عربی متن: تنزیل عثمانی۔ تراجم اور تلفظ: Al Quran Cloud۔ لفظ بہ لفظ اور تفسیر: Quran.com۔ تلاوت: EveryAyah.com۔ حدیث: fawazahmed0/hadith-api۔ فونٹس: امیری اور امیری قرآن (SIL لائسنس)۔';

  @override
  String selectedOfMax(int selected, int max) {
    return '$max میں سے $selected منتخب';
  }

  @override
  String get searchLanguageOrTranslator => 'زبان یا مترجم تلاش کریں';

  @override
  String nTranslations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تراجم',
      one: '1 ترجمہ',
    );
    return '$_temp0';
  }

  @override
  String nSelected(int count) {
    return '$count منتخب';
  }

  @override
  String get rightToLeftScript => 'دائیں سے بائیں رسم الخط';

  @override
  String translationLimit(int max) {
    return 'آپ ایک وقت میں زیادہ سے زیادہ $max تراجم دکھا سکتے ہیں۔ پہلے ایک ہٹائیں۔';
  }

  @override
  String get offlineIntro =>
      'عربی متن، انگریزی تلفظ اور تین انگریزی تراجم ہمیشہ آف لائن ہیں۔ باقی ایک بار ڈاؤن لوڈ کریں اور کہیں بھی پڑھیں۔';

  @override
  String get selectedTranslations => 'منتخب تراجم';

  @override
  String get allSelectedBundled => 'تمام منتخب تراجم ایپ میں شامل ہیں۔';

  @override
  String surahDownloadsSaved(int done, int total) {
    return '$total میں سے $done سورتیں محفوظ';
  }

  @override
  String wordByWordPack(String language) {
    return 'لفظ بہ لفظ ($language)';
  }

  @override
  String surahsSavedSize(int done) {
    return '114 میں سے $done سورتیں محفوظ · تقریباً 8 MB';
  }

  @override
  String get tafsirSavedAutomatically =>
      'ہر کھولی گئی آیت کی تفسیر خود بخود محفوظ ہو جاتی ہے۔';

  @override
  String get downloadEverything => 'منتخب سب کچھ ڈاؤن لوڈ کریں';

  @override
  String bundledEditions(String names) {
    return 'شامل ایڈیشن: $names۔';
  }

  @override
  String get everythingOffline => 'منتخب سب کچھ پہلے ہی آف لائن دستیاب ہے۔';

  @override
  String downloadDone(int count) {
    return 'مکمل۔ $count ڈاؤن لوڈ آف لائن کے لیے محفوظ۔';
  }

  @override
  String downloadDoneWithFailures(int failed) {
    return '$failed ناکام ڈاؤن لوڈ کے ساتھ مکمل (کنکشن چیک کر کے دوبارہ چلائیں)۔';
  }

  @override
  String downloadCancelled(int done, int total) {
    return '$total میں سے $done کے بعد منسوخ۔';
  }

  @override
  String get starting => 'شروع ہو رہا ہے…';

  @override
  String get memorize => 'حفظ';

  @override
  String memorizeHeader(String surah, int from, int to, int done, int total) {
    return '$surah · آیات $from–$to · $done/$total یاد';
  }

  @override
  String get changeRange => 'حد تبدیل کریں';

  @override
  String wordsRevealed(int revealed, int total) {
    return '$revealed / $total الفاظ';
  }

  @override
  String get nextWord => 'اگلا لفظ';

  @override
  String get revealAll => 'سب دکھائیں';

  @override
  String get hideAll => 'سب چھپائیں';

  @override
  String get transliteration => 'رومن تلفظ';

  @override
  String get translation => 'ترجمہ';

  @override
  String get memorized => 'یاد ہو گئی';

  @override
  String get markAsMemorized => 'یاد شدہ نشان زد کریں';

  @override
  String get listenAndRepeat => 'سنیں اور دہرائیں';

  @override
  String get repeatEachAyah => 'ہر آیت دہرائیں';

  @override
  String get loopTheRange => 'حد کو دہرائیں';

  @override
  String playRange(int from, int to) {
    return '$from–$to چلائیں';
  }

  @override
  String get thisAyah => 'یہ آیت';

  @override
  String get ayahRange => 'آیات کی حد';

  @override
  String fromToOf(int from, int to, int total) {
    return '$total میں سے $from تا $to';
  }

  @override
  String get readingPlan => 'پڑھنے کا منصوبہ';

  @override
  String get goalReached => 'ہدف پورا ہوا، ماشاء اللہ!';

  @override
  String moreAyahsToGoal(int count) {
    return 'ہدف تک پہنچنے کے لیے مزید $count آیات';
  }

  @override
  String dayStreak(int days) {
    return '$days دن کا تسلسل';
  }

  @override
  String get dailyGoal => 'روزانہ ہدف';

  @override
  String ayahsPerDay(int count) {
    return 'روزانہ $count آیات';
  }

  @override
  String get khatmIn30Days => '208 (30 دن میں ختم)';

  @override
  String get last7Days => 'گزشتہ 7 دن';

  @override
  String get ayahsRead => 'پڑھی گئی آیات';

  @override
  String get activeDays => 'فعال دن';

  @override
  String get quranRead => 'قرآن پڑھا';

  @override
  String get khatmPlan => 'ختم قرآن کا منصوبہ';

  @override
  String get khatmPlanHelp =>
      'شیڈول کے مطابق پورا قرآن مکمل کریں۔ ہم روزانہ بتائیں گے کہ کس آیت تک پہنچنا ہے۔';

  @override
  String nDays(int n) {
    return '$n دن';
  }

  @override
  String get startFromFatiha => 'الفاتحہ سے شروع کریں';

  @override
  String get fromTheBeginning => 'شروع سے';

  @override
  String get fromWhereYouAre => 'موجودہ مقام سے';

  @override
  String aboutAyahsADay(int count) {
    return 'روزانہ تقریباً $count آیات';
  }

  @override
  String get startPlan => 'منصوبہ شروع کریں';

  @override
  String get endPlan => 'منصوبہ ختم کریں';

  @override
  String planStatusLine(int day, int days, String date, int perDay) {
    return 'دن $day از $days · اختتام $date · $perDay آیات/دن';
  }

  @override
  String get onTrack => 'آپ ہدف کے مطابق ہیں۔';

  @override
  String onTrackAhead(int count) {
    return 'آپ ہدف کے مطابق ہیں، $count آیات آگے۔';
  }

  @override
  String catchUp(int count) {
    return 'ہدف پورا کرنے کے لیے آج مزید $count آیات پڑھیں۔';
  }

  @override
  String todaysTarget(String surah, String key) {
    return 'آج کا ہدف: $surah $key';
  }

  @override
  String get continueReadingButton => 'پڑھنا جاری رکھیں';

  @override
  String get hadith => 'حدیث';

  @override
  String get hadithIntro =>
      'صحاح ستہ، موطا امام مالک اور تین اربعین مجموعے، عربی مع ترجمہ۔ ہر باب ایک بار ڈاؤن لوڈ ہو کر آف لائن رہتا ہے۔';

  @override
  String hadithsChapters(int hadiths, int chapters) {
    return '$hadiths احادیث · $chapters ابواب';
  }

  @override
  String couldNotLoadHadithBooks(String error) {
    return 'حدیث کی کتابیں لوڈ نہیں ہو سکیں: $error';
  }

  @override
  String get findAChapter => 'باب تلاش کریں';

  @override
  String hadithsRange(int first, int last) {
    return 'احادیث $first–$last';
  }

  @override
  String chapterN(int n) {
    return 'باب $n';
  }

  @override
  String get chapterNeedsInternet => 'اس باب کے لیے پہلی بار انٹرنیٹ درکار ہے۔';

  @override
  String searchHadithsInChapter(int count) {
    return 'اس باب کی $count احادیث میں تلاش کریں';
  }

  @override
  String get previousChapter => 'پچھلا باب';

  @override
  String get nextChapter => 'اگلا باب';

  @override
  String get hadithCopied => 'حدیث کاپی ہو گئی';

  @override
  String get prayerTimes => 'اوقاتِ نماز';

  @override
  String get prayerTimesForMasjid => 'آپ کی مسجد کے اوقاتِ نماز';

  @override
  String get prayerIntro =>
      'مسجد کا مکمل پتہ یا پوسٹل کوڈ درج کریں۔ اسے درست محلِ وقوع اور ٹائم زون میں بدلا جاتا ہے، پھر آپ کے منتخب طریقۂ حساب سے روزانہ نماز، اقامت اور جمعہ کے اوقات بنائے جاتے ہیں۔';

  @override
  String get setUpMasjid => 'پتے سے مسجد ترتیب دیں';

  @override
  String get useMyLocation => 'میرا موجودہ مقام استعمال کریں';

  @override
  String get methodsList =>
      'طریقۂ حساب: ISNA، رابطہ عالم اسلامی، مصر، کراچی، ام القریٰ، خلیج، کویت، قطر، سنگاپور، دیانت، UOIF، روس، تہران اور جعفری۔ عصر: شافعی/مالکی/حنبلی یا حنفی۔';

  @override
  String couldNotGetLocation(String error) {
    return 'آپ کا مقام معلوم نہیں ہو سکا: $error';
  }

  @override
  String get monthlyTimetable => 'ماہانہ نقشہ';

  @override
  String get shareToday => 'آج کے اوقات شیئر کریں';

  @override
  String get editMasjid => 'مسجد میں ترمیم';

  @override
  String get addAnotherMasjid => 'ایک اور مسجد شامل کریں';

  @override
  String get removeMasjid => 'مسجد ہٹائیں';

  @override
  String removeMasjidQuestion(String name) {
    return '$name ہٹائیں؟';
  }

  @override
  String get removeMasjidBody =>
      'اس کا پتہ، حساب کی ترتیبات، اقامت اور جمعہ کے اوقات حذف ہو جائیں گے۔';

  @override
  String nextPrayerIn(String prayer, String time, String duration) {
    return '$prayer $time پر · $duration بعد';
  }

  @override
  String get fajrTomorrow => 'فجر (کل)';

  @override
  String get jumuah => 'جمعہ';

  @override
  String get noJumuahSet =>
      'جمعہ کے اوقات مقرر نہیں۔ شامل کرنے کے لیے مسجد میں ترمیم کریں۔';

  @override
  String khutbahAt(String time) {
    return 'خطبہ $time';
  }

  @override
  String iqamaAt(String time) {
    return 'اقامت $time';
  }

  @override
  String timesFootnote(String lat, String lng, String tz) {
    return 'اوقات $tz زون میں $lat، $lng کے لیے فلکیاتی طور پر منٹ تک حساب کیے گئے ہیں۔ ہجری تاریخ حسابی ہے اور مقامی رؤیت سے ایک دن مختلف ہو سکتی ہے۔';
  }

  @override
  String qiblaDegrees(int degrees) {
    return 'قبلہ $degrees°';
  }

  @override
  String get asrShafii => 'عصر شافعی';

  @override
  String get asrHanafi => 'عصر حنفی';

  @override
  String get fajr => 'فجر';

  @override
  String get sunrise => 'طلوعِ آفتاب';

  @override
  String get dhuhr => 'ظہر';

  @override
  String get asr => 'عصر';

  @override
  String get maghrib => 'مغرب';

  @override
  String get isha => 'عشاء';

  @override
  String get addMasjid => 'مسجد شامل کریں';

  @override
  String get masjid => 'مسجد';

  @override
  String get masjidName => 'مسجد کا نام';

  @override
  String get enterAName => 'نام درج کریں';

  @override
  String get address => 'پتہ';

  @override
  String get streetAddress => 'گلی / سڑک';

  @override
  String get city => 'شہر';

  @override
  String get stateProvince => 'ریاست / صوبہ';

  @override
  String get postalCode => 'پوسٹل کوڈ';

  @override
  String get countryCode => 'ملک کا کوڈ (US, GB, FR…)';

  @override
  String get findLocation => 'مقام تلاش کریں';

  @override
  String get deviceGps => 'ڈیوائس GPS';

  @override
  String get coordinatesAndTimeZone => 'محلِ وقوع اور ٹائم زون';

  @override
  String get setAutomatically => 'پتے سے خود بخود مقرر';

  @override
  String get latitude => 'عرض بلد';

  @override
  String get longitude => 'طول بلد';

  @override
  String get ianaTimeZone => 'IANA ٹائم زون (مثلاً Asia/Karachi)';

  @override
  String get calculation => 'حساب';

  @override
  String get calculationMethod => 'طریقۂ حساب';

  @override
  String get asrShafiiFull => 'عصر: شافعی / مالکی / حنبلی';

  @override
  String get asrHanafiFull => 'عصر: حنفی';

  @override
  String get dhuhrAfterZawal => 'ظہر: زوال کے بعد منٹ';

  @override
  String get maghribAfterSunset => 'مغرب: غروب کے بعد منٹ';

  @override
  String get fineTune => 'ہر نماز کی باریک ترتیب (منٹ)';

  @override
  String get hijriAdjustment => 'ہجری تاریخ کی ترمیم (دن)';

  @override
  String get iqama => 'اقامت';

  @override
  String get jumuahServices => 'جمعہ کی نمازیں';

  @override
  String get addJumuahTime => 'جمعہ کا وقت شامل کریں';

  @override
  String get addAnotherService => 'ایک اور نماز شامل کریں';

  @override
  String get saveMasjid => 'مسجد محفوظ کریں';

  @override
  String get none => 'کوئی نہیں';

  @override
  String get fixed => 'مقررہ';

  @override
  String get plusMinutes => '+ منٹ';

  @override
  String get khutbahPicker => 'خطبہ…';

  @override
  String get jumuahLabelHint => 'لیبل (زبان، ہال، خطیب)';

  @override
  String get enterZipOrCity => 'کم از کم پوسٹل کوڈ یا شہر درج کریں۔';

  @override
  String get lookingUpAddress => 'پتہ تلاش کیا جا رہا ہے…';

  @override
  String get noMatchTryCountry =>
      'کوئی نتیجہ نہیں۔ شہر اور 2 حرفی ملک کا کوڈ (مثلاً US، GB، FR) شامل کریں۔';

  @override
  String get chooseLocation => 'درست مقام منتخب کریں:';

  @override
  String lookupFailed(String error) {
    return 'تلاش ناکام: $error';
  }

  @override
  String get resolvingTimeZone => 'ٹائم زون معلوم کیا جا رہا ہے…';

  @override
  String located(String name) {
    return 'مقام ملا: $name';
  }

  @override
  String timeZoneLookupFailed(String error) {
    return 'محلِ وقوع مقرر ہوا مگر ٹائم زون معلوم نہیں ہو سکا ($error)۔ America/New_York جیسا IANA زون درج کریں۔';
  }

  @override
  String get gettingPosition => 'آپ کا مقام معلوم کیا جا رہا ہے…';

  @override
  String couldNotUseDevice(String error) {
    return 'ڈیوائس کا مقام استعمال نہیں ہو سکا: $error';
  }

  @override
  String get findLocationFirst =>
      'پہلے \"مقام تلاش کریں\" دبائیں تاکہ محلِ وقوع اور ٹائم زون مقرر ہوں۔';

  @override
  String get setUpMasjidFirst => 'پہلے ایک مسجد ترتیب دیں۔';

  @override
  String get hideIqama => 'اقامت چھپائیں';

  @override
  String get showIqama => 'اقامت دکھائیں';

  @override
  String get copyAsCsv => 'CSV کے طور پر کاپی';

  @override
  String get csvCopied => 'CSV کاپی ہو گیا — Excel یا Sheets میں پیسٹ کریں';

  @override
  String get shareAsText => 'متن کے طور پر شیئر';

  @override
  String get thisMonth => 'یہ مہینہ';

  @override
  String get date => 'تاریخ';

  @override
  String get mushafLayout => 'ترتیب';

  @override
  String get layoutAutomatic => 'خودکار';

  @override
  String get layoutScroll => 'ایک صفحہ، نیچے سکرول';

  @override
  String get layoutFlip => 'ایک صفحہ، ورق گردانی';

  @override
  String get layoutBook => 'دو صفحات، ورق گردانی';

  @override
  String get playThisPage => 'یہ صفحہ چلائیں';

  @override
  String get goToPage => 'صفحے پر جائیں';

  @override
  String get goTo => 'جائیں';

  @override
  String get pageRange => 'صفحہ (1–604)';

  @override
  String get previousPage => 'پچھلا صفحہ';

  @override
  String get nextPage => 'اگلا صفحہ';

  @override
  String pageJuz(int page, int juz) {
    return 'صفحہ $page · پارہ $juz';
  }

  @override
  String get library => 'لائبریری';

  @override
  String get openBook => 'کتاب کھولیں';

  @override
  String get tableOfContents => 'فہرست';

  @override
  String chapterPage(int chapter, int page, int total) {
    return 'باب $chapter · صفحہ $page / $total';
  }

  @override
  String get listView => 'فہرست کا منظر';

  @override
  String get downloadPdf => 'PDF ڈاؤن لوڈ کریں';

  @override
  String get downloadChapterPdf => 'یہ باب PDF میں ڈاؤن لوڈ کریں';

  @override
  String get downloadBookPdf => 'پوری کتاب PDF میں ڈاؤن لوڈ کریں';

  @override
  String preparingPdf(int done, int total) {
    return 'ابواب حاصل کیے جا رہے ہیں… $done / $total';
  }

  @override
  String get renderingPdf => 'PDF تیار ہو رہی ہے…';

  @override
  String pdfFailed(String error) {
    return 'PDF نہیں بن سکی: $error';
  }

  @override
  String hadithsCount(int count) {
    return '$count احادیث';
  }

  @override
  String byAuthor(String author) {
    return 'از $author';
  }

  @override
  String get reciteAndCheck => 'سنائیں اور جانچیں';

  @override
  String get reciteFromHere => 'یہاں سے سنائیں';

  @override
  String get reciteSubtitle =>
      'حفظ سے سنائیں؛ ایپ سنتی ہے اور ہر لفظ کو نشان زد کرتی ہے';

  @override
  String ayahRangeLabel(int from, int to) {
    return 'آیات $from–$to';
  }

  @override
  String get accuracy => 'درستگی';

  @override
  String get matchedWords => 'درست';

  @override
  String get wrongWords => 'غلط';

  @override
  String get missedWords => 'چھوٹے';

  @override
  String wordsReached(int reached, int total) {
    return '$total میں سے $reached الفاظ سنائے گئے';
  }

  @override
  String get listening => 'سن رہا ہے…';

  @override
  String get waitingForSpeech => 'آواز کا انتظار…';

  @override
  String get tapMicToStart => 'مائیک دبائیں اور سنانا شروع کریں';

  @override
  String get heard => 'سنا گیا';

  @override
  String get notInPassage => 'ایسے الفاظ جو اقتباس میں نہیں';

  @override
  String get hideText => 'متن چھپائیں (حفظ)';

  @override
  String get showText => 'متن دکھائیں';

  @override
  String get hint => 'اشارہ';

  @override
  String get reset => 'دوبارہ';

  @override
  String get playThisAyah => 'یہ آیت چلائیں';

  @override
  String get speechUnavailable =>
      'آواز کی شناخت دستیاب نہیں۔ مائیکروفون کی اجازت دیں یا ویب پر Chrome استعمال کریں۔';

  @override
  String get reciteHelp =>
      'صاف اور یکساں رفتار سے سنائیں۔ پرسکون جگہ میں شناخت بہتر ہوتی ہے؛ درست الفاظ سبز، لغزشیں نارنجی اور چھوٹے ہوئے الفاظ سرخ ہو جاتے ہیں۔';

  @override
  String get qibla => 'قبلہ';

  @override
  String get qiblaBearing => 'حقیقی شمال سے قبلے کا رخ';

  @override
  String get qiblaNeedsLocation =>
      'قبلہ آپ کے مقام سے معلوم ہوتا ہے۔ آلے کا GPS استعمال کریں یا پہلے مسجد ترتیب دیں۔';

  @override
  String distanceToMakkah(int km) {
    return 'مکہ تک $km کلومیٹر';
  }

  @override
  String headingDegrees(int degrees) {
    return 'رخ $degrees°';
  }

  @override
  String get facingQibla => 'آپ کا رخ قبلے کی طرف ہے';

  @override
  String get compassWaiting =>
      'قطب نما کا انتظار… کیلیبریشن کے لیے فون کو 8 کی شکل میں گھمائیں۔';

  @override
  String get compassUnavailable =>
      'اس آلے میں قطب نما نہیں: قطب نما یا نقشہ استعمال کریں اور اوپر دیے زاویے کی طرف مڑیں۔';

  @override
  String turnToQibla(String direction, int degrees) {
    return '$direction $degrees° مڑیں';
  }

  @override
  String get left => 'بائیں';

  @override
  String get right => 'دائیں';

  @override
  String get qiblaHelp =>
      'فون کو ہموار اور مقناطیس یا دھات سے دور رکھیں۔ ڈائل پر کعبہ کا نشان قبلہ دکھاتا ہے؛ اوپر کا تیر آپ کا رخ ہے۔';

  @override
  String get adhan => 'اذان';

  @override
  String get adhanIntro =>
      'مختلف مؤذنوں کی اذان سنیں، کوئی بھی ریکارڈنگ ڈاؤن لوڈ کریں اور اپنے اوقاتِ نماز کے لیے طے شدہ اذان منتخب کریں۔';

  @override
  String get adhanCredits =>
      'ریکارڈنگز انٹرنیٹ آرکائیو کے \"adhans\" اور \"azan-alafasy\" مجموعوں سے۔';

  @override
  String downloaded(String name) {
    return '$name ڈاؤن لوڈ ہو گئی';
  }

  @override
  String downloadFailed(String error) {
    return 'ڈاؤن لوڈ ناکام: $error';
  }

  @override
  String get downloadSurahAudio => 'سورت کی آڈیو آف لائن کے لیے ڈاؤن لوڈ کریں';

  @override
  String get downloadAyahAudio => 'اس آیت کی آڈیو ڈاؤن لوڈ کریں (MP3)';

  @override
  String get offlineAudioNativeOnly =>
      'آف لائن آڈیو موبائل اور ڈیسک ٹاپ ایپس میں محفوظ رہتی ہے؛ ویب پر ایک ایک آیت ڈاؤن لوڈ کریں۔';

  @override
  String surahAudioSaved(String surah) {
    return '$surah آف لائن سننے کے لیے محفوظ ہو گئی';
  }

  @override
  String get downloadForOffline => 'آف لائن پڑھنے کے لیے ڈاؤن لوڈ کریں';

  @override
  String savedForOffline(String name) {
    return '$name آف لائن پڑھنے کے لیے محفوظ';
  }

  @override
  String get playAdhan => 'اذان چلائیں';

  @override
  String adhanForNext(String prayer) {
    return '$prayer کی اذان';
  }

  @override
  String get chooseAdhan => 'اذان منتخب کریں';

  @override
  String get pageAnimation => 'صفحے کی حرکت';

  @override
  String get animationCurl => 'ورق کا مڑنا';

  @override
  String get animationFlip => 'کارڈ فلپ';

  @override
  String get animationSlide => 'سلائیڈ';

  @override
  String get animationFade => 'فیڈ';

  @override
  String get highlight => 'نمایاں';

  @override
  String get removeHighlight => 'نمایاں ہٹائیں';

  @override
  String get note => 'نوٹ';

  @override
  String get noteHint => 'اس آیت کے لیے اپنا تدبر یا یاد دہانی لکھیں…';

  @override
  String get noteSaved => 'نوٹ محفوظ';

  @override
  String get noteHelp =>
      'نوٹس اسی آلے پر رہتے ہیں۔ نمایاں آیات مصحف کے صفحات پر رنگین دکھائی دیتی ہیں۔';

  @override
  String get continuous => 'خودکار جاری';

  @override
  String get repeatEach => 'دہرائیں';

  @override
  String get verseDetails => 'آیت کی تفصیل';

  @override
  String get zoomIn => 'بڑا کریں';

  @override
  String get zoomOut => 'چھوٹا کریں';

  @override
  String get fitPage => 'صفحے کے مطابق';

  @override
  String get shareEmbed => 'شیئر اور ایمبیڈ';

  @override
  String get websiteWidget => 'ویب سائٹ ویجٹ اور ٹی وی ڈسپلے';

  @override
  String get widgetLinks => 'عوامی لنکس';

  @override
  String get embedCode => 'ایمبیڈ کوڈ';

  @override
  String get openLink => 'کھولیں';

  @override
  String get linkCopied => 'لنک کاپی ہو گیا';

  @override
  String get codeCopied => 'ایمبیڈ کوڈ کاپی ہو گیا';

  @override
  String get combinedWidget => 'مشترکہ ویجٹ (روزانہ + جمعہ)';

  @override
  String get dailyWidget => 'روزانہ نماز ویجٹ';

  @override
  String get jumuahWidget => 'نمازِ جمعہ ویجٹ';

  @override
  String get compactWidget => 'مختصر ویجٹ';

  @override
  String get tvDisplay => 'ٹی وی ڈسپلے';

  @override
  String get darkWidget => 'گہرا ویجٹ';

  @override
  String get embedHelp =>
      'ایمبیڈ کوڈ اپنی مسجد کی ویب سائٹ میں چسپاں کریں یا لنک شیئر کریں۔ لنک میں مسجد کا مقام، طریقہ، اقامت اور جمعہ کے اوقات شامل ہیں، اس لیے تبدیلی کے بعد دوبارہ کاپی کریں۔ کسی بھی لنک میں ?theme=dark یا &scale=120, &lang=ar شامل کریں۔';

  @override
  String get preview => 'پیش منظر';

  @override
  String get adhanHeader => 'اذان';

  @override
  String get poweredBy => 'Mushaf+ کے تعاون سے';

  @override
  String get invalidWidgetLink => 'یہ ویجٹ لنک غلط یا نامکمل ہے۔';

  @override
  String get micDenied =>
      'مائیکروفون تک رسائی مسترد ہو گئی۔ براؤزر یا سسٹم کی ترتیبات میں اس سائٹ کے لیے اجازت دیں اور دوبارہ کوشش کریں۔';

  @override
  String get noSpeechYet =>
      'ابھی کچھ سنائی نہیں دیا۔ مائیکروفون کے قریب صاف پڑھیں؛ پہچانے گئے الفاظ یہاں ظاہر ہوں گے۔';

  @override
  String get speechNotice => 'شناخت کی اطلاع';

  @override
  String get speechTip =>
      'درست الفاظ سبز اور غلط الفاظ سرخ ہو جاتے ہیں، آواز اور ارتعاش کے ساتھ؛ غلطی کے بعد پڑھتے رہیں، جانچ آپ کے ساتھ چلتی ہے۔';

  @override
  String get strictMode => 'سخت';

  @override
  String get lenientMode => 'نرم';

  @override
  String get strictHelp =>
      'سخت موڈ: لفظ صرف اس وقت درست شمار ہوتا ہے جب ہر حرف مطابق ہو۔ حرکات اور تجوید کی جانچ ممکن نہیں کیونکہ آواز کی شناخت صرف حروف واپس دیتی ہے۔';

  @override
  String get tjHamzatWasl => 'ہمزۂ وصل';

  @override
  String get tjSilent => 'خاموش حرف';

  @override
  String get tjLaamShamsiyyah => 'لامِ شمسی';

  @override
  String get tjMaddNormal => 'مدِ طبعی';

  @override
  String get tjMaddPermissible => 'مدِ جائز';

  @override
  String get tjMaddNecessary => 'مدِ لازم';

  @override
  String get tjQalqalah => 'قلقلہ';

  @override
  String get tjMaddObligatory => 'مدِ واجب متصل';

  @override
  String get tjIkhfaShafawi => 'اخفائے شفوی';

  @override
  String get tjIkhfa => 'اخفائے حقیقی';

  @override
  String get tjIdghamShafawi => 'ادغامِ شفوی';

  @override
  String get tjIqlab => 'اقلاب';

  @override
  String get tjIdghamGhunnah => 'ادغام مع الغنہ';

  @override
  String get tjIdghamNoGhunnah => 'ادغام بلا غنہ';

  @override
  String get tjIdghamMutajanisayn => 'ادغامِ متجانسین';

  @override
  String get tjIdghamMutaqaribayn => 'ادغامِ متقاربین';

  @override
  String get tjGhunnah => 'غنہ';

  @override
  String get tjdHamzatWasl =>
      'لفظ کے شروع کا ہمزہ جو صرف اسی لفظ سے ابتدا کرنے پر پڑھا جاتا ہے؛ پچھلے لفظ سے ملا کر پڑھنے میں خاموش رہتا ہے۔';

  @override
  String get tjdSilent =>
      'مصحف میں لکھا ہوا مگر نہ پڑھا جانے والا حرف، جیسے واوِ جمع کے بعد کا الف؛ تلاوت میں چھوڑ دیں۔';

  @override
  String get tjdLaamShamsiyyah =>
      'شمسی حرف سے پہلے لامِ تعریف نہیں پڑھی جاتی؛ اس کی جگہ شمسی حرف مشدد پڑھیں، جیسے ٱلشَّمْس۔';

  @override
  String get tjdMaddNormal =>
      'مدِ طبعی: حرفِ مد کو دو حرکات کے برابر کھینچیں، نہ کم نہ زیادہ۔';

  @override
  String get tjdMaddPermissible =>
      'حرفِ مد کے بعد اگلے لفظ میں ہمزہ یا وقف کا سکون آئے تو دو، چار یا چھ حرکات مد کریں اور پوری تلاوت میں ایک ہی مقدار رکھیں۔';

  @override
  String get tjdMaddNecessary =>
      'حرفِ مد کے بعد اصلی سکون یا تشدید ہو، جیسے سورتوں کے حروفِ مقطعات؛ چھ حرکات مد کریں۔';

  @override
  String get tjdQalqalah =>
      'قطب جد کے ساکن حروف پر جھٹکے کی آواز؛ حرف کو ہلکی گونج کے ساتھ ادا کریں، وقف پر زیادہ واضح۔';

  @override
  String get tjdMaddObligatory =>
      'حرفِ مد کے بعد اسی لفظ میں ہمزہ؛ چار یا پانچ حرکات مد کریں۔';

  @override
  String get tjdIkhfaShafawi =>
      'ساکن میم کے بعد ب: ہونٹ ہلکے سے ملا کر میم کو دو حرکات کی غنہ کے ساتھ چھپائیں۔';

  @override
  String get tjdIkhfa =>
      'ساکن نون یا تنوین کے بعد اخفا کے پندرہ حروف میں سے کوئی: نون کو دو حرکات کی غنہ سے چھپائیں اور زبان اگلے حرف کے لیے تیار رکھیں۔';

  @override
  String get tjdIdghamShafawi =>
      'ساکن میم کے بعد میم: دونوں کو ایک مشدد میم میں دو حرکات کی غنہ کے ساتھ ملا دیں۔';

  @override
  String get tjdIqlab =>
      'ساکن نون یا تنوین کے بعد ب: نون میم میں بدل جاتا ہے، دو حرکات کی غنہ اور ہلکے ملے ہونٹوں کے ساتھ۔';

  @override
  String get tjdIdghamGhunnah =>
      'ساکن نون یا تنوین کے بعد اگلے لفظ کے شروع میں ی ن م و آئے تو اس میں دو حرکات کی غنہ کے ساتھ ادغام ہوتا ہے۔';

  @override
  String get tjdIdghamNoGhunnah =>
      'ساکن نون یا تنوین کے بعد ل یا ر: بغیر غنہ مکمل ادغام ہوتا ہے۔';

  @override
  String get tjdIdghamMutajanisayn =>
      'ایک ہی مخرج کے دو حروف، پہلا ساکن، ایک مشدد حرف میں ضم ہو جاتے ہیں، جیسے قَد تَّبَيَّنَ۔';

  @override
  String get tjdIdghamMutaqaribayn =>
      'قریب المخرج دو حروف، پہلا ساکن، دوسرے میں ضم ہو جاتا ہے، جیسے قُل رَّبِّ۔';

  @override
  String get tjdGhunnah => 'مشدد میم اور نون پر دو حرکات کی ناک کی گونج۔';

  @override
  String get tjgMadd => 'مد';

  @override
  String get tjgNunTanwin => 'نون ساکن اور تنوین';

  @override
  String get tjgMeemSakinah => 'میم ساکن';

  @override
  String get tjgGhunnah => 'غنہ';

  @override
  String get tjgQalqalah => 'قلقلہ';

  @override
  String get tjgLam => 'لام';

  @override
  String get tjgSilent => 'خاموش حروف';

  @override
  String get tjgIdghamAdjacent => 'ملحقہ حروف کا ادغام';

  @override
  String get tajweed => 'تجوید';

  @override
  String get tajweedColors => 'تجوید کے رنگ';

  @override
  String get tajweedColorsSubtitle =>
      'مصحف اور قاری کے حروف کو تجوید کے قاعدے کے مطابق رنگیں';

  @override
  String get tajweedGuide => 'تجوید کی رہنمائی';

  @override
  String get tajweedLegend => 'تجوید کے رنگوں کی وضاحت';

  @override
  String get seeGuide => 'مکمل رہنمائی';

  @override
  String get tajweedIntro =>
      'تجوید یہ ہے کہ ہر حرف اپنے مخرج سے اس کی صفات کے ساتھ ادا ہو: جہاں مد ہو وہاں کھینچنا، جہاں غنہ ہو وہاں ناک کی آواز، اور جہاں قواعد چاہیں وہاں اخفا، ادغام اور قلقلہ۔ مصحف ہر اس حرف کو رنگتا ہے جس پر کوئی قاعدہ ہو؛ کسی بھی لفظ پر ٹیپ کریں تاکہ اس کے قواعد اور پڑھنے کا طریقہ دیکھ سکیں۔ قواعد روایتِ حفص عن عاصم کے مطابق ہیں۔';

  @override
  String get rulesInThisWord => 'اس لفظ میں تجوید';

  @override
  String get noRulesInWord =>
      'اس لفظ پر کوئی تجویدی قاعدہ نہیں: اس کے حروف سادہ طور پر اپنے مخارج سے پڑھیں۔';

  @override
  String get wordTab => 'لفظ';

  @override
  String wordOfN(int n, int total) {
    return 'لفظ $n از $total';
  }

  @override
  String get playWord => 'لفظ سنیں';

  @override
  String get example => 'مثال';

  @override
  String get triggerLetters => 'حروف';

  @override
  String countsValue(String n) {
    return '$n حرکات';
  }

  @override
  String tuhfaRef(String lines) {
    return 'تحفۃ الاطفال، اشعار $lines';
  }

  @override
  String jazariyyahRef(String lines) {
    return 'جزریہ، اشعار $lines';
  }

  @override
  String get tajweedSource =>
      'قواعد اور رنگ alquran.cloud کی تجوید رہنمائی (روایتِ حفص، تنزیل عثمانی متن) اور quran.com کے KFGQPC رنگوں کے مطابق ہیں۔ اشعار کے حوالے تحفۃ الاطفال اور مقدمہ جزریہ کے ہیں۔';

  @override
  String get fullScreen => 'پوری اسکرین';

  @override
  String get exitFullScreen => 'پوری اسکرین سے باہر';

  @override
  String get playbackSpeed => 'رفتار';

  @override
  String get chooseReciter => 'قاری منتخب کریں';

  @override
  String get approximateLocation =>
      'صرف علاقہ (پوسٹل کوڈ یا شہر) ملا، اس لیے نقاط اس کا مرکز ہیں۔ اگر آپ کو درست نقاط معلوم ہیں تو نیچے درج کریں۔';
}
