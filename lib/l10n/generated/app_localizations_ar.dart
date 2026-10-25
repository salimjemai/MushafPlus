// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'القرآن+';

  @override
  String get navRead => 'القراءة';

  @override
  String get navHadith => 'الحديث';

  @override
  String get navPrayer => 'الصلاة';

  @override
  String get navSaved => 'المحفوظات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get search => 'بحث';

  @override
  String get searchTheQuran => 'البحث في القرآن';

  @override
  String get cancel => 'إلغاء';

  @override
  String get open => 'فتح';

  @override
  String get apply => 'تطبيق';

  @override
  String get save => 'حفظ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get copy => 'نسخ';

  @override
  String get share => 'مشاركة';

  @override
  String get clear => 'مسح';

  @override
  String get remove => 'إزالة';

  @override
  String get download => 'تنزيل';

  @override
  String get more => 'المزيد';

  @override
  String get back => 'رجوع';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get couldNotLoadQuran => 'تعذّر تحميل بيانات القرآن.';

  @override
  String get continueReading => 'متابعة القراءة';

  @override
  String get startReading => 'ابدأ القراءة';

  @override
  String ayahOfJuzPage(int ayah, int total, int juz, int page) {
    return 'الآية $ayah من $total · الجزء $juz · الصفحة $page';
  }

  @override
  String get verseOfTheDay => 'آية اليوم';

  @override
  String get today => 'اليوم';

  @override
  String dailyGoalTapToStartPlan(int goal) {
    return 'الهدف اليومي $goal آية · اضغط لبدء خطة ختم';
  }

  @override
  String khatmOnTrack(int day, int days) {
    return 'خطة الختم: على المسار · اليوم $day/$days';
  }

  @override
  String khatmBehind(int behind, int day, int days) {
    return 'خطة الختم: متأخر $behind آية · اليوم $day/$days';
  }

  @override
  String get findSurahHint => 'ابحث عن سورة بالاسم أو المعنى أو الرقم';

  @override
  String get tabSurah => 'سورة';

  @override
  String get tabJuz => 'جزء';

  @override
  String get tabPage => 'صفحة';

  @override
  String get noSurahMatches => 'لا توجد سورة مطابقة لبحثك.';

  @override
  String surahSubtitle(String meaning, int count, String type) {
    return '$meaning · $count آية · $type';
  }

  @override
  String get meccan => 'مكية';

  @override
  String get medinan => 'مدنية';

  @override
  String juzN(int n) {
    return 'الجزء $n';
  }

  @override
  String juzStartsAt(String surah, int ayah, int count) {
    return 'يبدأ من $surah، الآية $ayah · $count آية';
  }

  @override
  String get jumpToSurah => 'الانتقال إلى سورة';

  @override
  String pageN(int n) {
    return 'الصفحة $n';
  }

  @override
  String get backToSurahs => 'العودة إلى السور';

  @override
  String get openMushafHere => 'فتح المصحف عند هذه السورة';

  @override
  String get translations => 'الترجمات';

  @override
  String get readingSettings => 'إعدادات القراءة';

  @override
  String get playSurah => 'تشغيل السورة';

  @override
  String get pauseRecitation => 'إيقاف التلاوة مؤقتًا';

  @override
  String get memorizeThisSurah => 'حفظ هذه السورة';

  @override
  String get openInMushaf => 'فتح في المصحف';

  @override
  String juzPage(int juz, int page) {
    return 'الجزء $juz · الصفحة $page';
  }

  @override
  String get wordByWord => 'كلمة بكلمة';

  @override
  String get tafsir => 'التفسير';

  @override
  String get bookmark => 'إشارة مرجعية';

  @override
  String get removeBookmark => 'إزالة الإشارة المرجعية';

  @override
  String get bookmarkThisAyah => 'حفظ هذه الآية';

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get playFromThisAyah => 'التشغيل من هذه الآية';

  @override
  String get sajdahAyah => 'آية سجدة';

  @override
  String couldNotLoad(String name) {
    return 'تعذّر تحميل $name';
  }

  @override
  String wordByWordOffline(String error) {
    return 'كلمة بكلمة غير متاح دون اتصال ($error)';
  }

  @override
  String ayahN(int n) {
    return 'الآية $n';
  }

  @override
  String get wordByWordSubtitle => 'نطق ومعنى كل كلمة';

  @override
  String get tafsirSubtitle => 'تفسير ابن كثير وغيره';

  @override
  String get playRecitationFromHere => 'تشغيل التلاوة من هنا';

  @override
  String get memorizeFromHere => 'الحفظ من هنا';

  @override
  String get memorizeSubtitle =>
      'إخفاء الكلمات وكشفها واحدة تلو الأخرى وتكرار التلاوة';

  @override
  String get ayahCopied => 'تم نسخ الآية';

  @override
  String wordN(int n) {
    return 'الكلمة $n';
  }

  @override
  String get wordByWordNeedsInternet =>
      'تحتاج بيانات كلمة بكلمة إلى اتصال بالإنترنت في المرة الأولى.';

  @override
  String get tafsirNeedsInternet =>
      'يحتاج التفسير إلى اتصال بالإنترنت في المرة الأولى.';

  @override
  String get viaQuranCom => 'عبر Quran.com';

  @override
  String get reciter => 'القارئ';

  @override
  String get arabicSize => 'حجم الخط العربي';

  @override
  String get translationSize => 'حجم الترجمة';

  @override
  String get amiriQuran => 'أميري قرآن';

  @override
  String get amiriNaskh => 'أميري نسخ';

  @override
  String get showTransliteration => 'إظهار النطق اللاتيني';

  @override
  String get showTransliterationSubtitle =>
      'كتابة النطق بالحروف اللاتينية تحت كل آية';

  @override
  String get wordByWordMode => 'وضع كلمة بكلمة';

  @override
  String get wordByWordModeSubtitle => 'كل كلمة مع نطقها ومعناها';

  @override
  String get wordMeaningsLanguage => 'لغة معاني الكلمات';

  @override
  String get tapAyahHint =>
      'اضغط على أي آية للترجمة والنطق والتفسير وكلمة بكلمة.';

  @override
  String get previousAyah => 'الآية السابقة';

  @override
  String get nextAyah => 'الآية التالية';

  @override
  String get stop => 'إيقاف';

  @override
  String get loop => 'تكرار';

  @override
  String get searchHint => 'عربي أو نطق لاتيني أو إنجليزي…';

  @override
  String get searchWholeQuran => 'ابحث في القرآن كله';

  @override
  String get searchHelp =>
      'اكتب بالعربية (مع التشكيل أو بدونه) أو عبارة بالنطق اللاتيني أو كلمة إنجليزية. تفتح النتائج الآية في القارئ.';

  @override
  String noAyahMatches(String query) {
    return 'لا توجد آية مطابقة لـ \"$query\"';
  }

  @override
  String resultsCount(String count) {
    return '$count نتيجة';
  }

  @override
  String get savedAyahs => 'الآيات المحفوظة';

  @override
  String get noBookmarksYet => 'لا توجد إشارات مرجعية بعد';

  @override
  String get noBookmarksHelp =>
      'اضغط على أيقونة الإشارة المرجعية في أي آية أثناء القراءة لحفظها هنا.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get arabicFont => 'الخط العربي';

  @override
  String get language => 'لغة التطبيق';

  @override
  String get systemDefault => 'لغة النظام';

  @override
  String get recitation => 'التلاوة';

  @override
  String get recitationHelp =>
      'يُبث الصوت آية بآية من everyayah.com. اضغط تشغيل على أي آية أو \"تشغيل السورة\" في رأس السورة.';

  @override
  String get reading => 'القراءة';

  @override
  String get wordByWordSettingSubtitle =>
      'عرض كل كلمة مع نطقها ومعناها (تُنزّل مرة لكل سورة)';

  @override
  String get defaultView => 'العرض الافتراضي';

  @override
  String get viewTranslation => 'ترجمة';

  @override
  String get viewMushafBook => 'مصحف';

  @override
  String get languages => 'اللغات';

  @override
  String get arabicOnlyTapToAdd => 'عربي فقط — اضغط لإضافة ترجمات';

  @override
  String translationsAvailable(int count, int languages) {
    return 'تتوفر $count ترجمة بـ $languages لغة. تُنزّل كل منها عند فتح السورة لأول مرة وتُحفظ دون اتصال.';
  }

  @override
  String get storage => 'التخزين';

  @override
  String get offlinePacks => 'حزم دون اتصال';

  @override
  String get offlinePacksSubtitle => 'تنزيل الترجمات وكلمة بكلمة للقرآن كاملًا';

  @override
  String get clearDownloadedData => 'مسح البيانات المنزّلة';

  @override
  String cachedDownloads(int count) {
    return '$count سورة منزّلة';
  }

  @override
  String get clearDownloadedDataQuestion => 'مسح البيانات المنزّلة؟';

  @override
  String get clearDownloadedDataBody =>
      'ستُنزّل الترجمات وبيانات كلمة بكلمة مجددًا عند الحاجة. تبقى الإشارات المرجعية والإعدادات.';

  @override
  String get downloadedDataCleared => 'تم مسح البيانات المنزّلة';

  @override
  String get about => 'حول';

  @override
  String get versionBuiltWith => 'الإصدار 1.0.0 · مبني بـ Flutter';

  @override
  String get credits =>
      'النص العربي: مصحف تنزيل برسم عثماني. الترجمات والنطق: Al Quran Cloud. كلمة بكلمة والتفسير: Quran.com. التلاوة: EveryAyah.com. الحديث: fawazahmed0/hadith-api. الخطوط: أميري وأميري قرآن (رخصة SIL).';

  @override
  String selectedOfMax(int selected, int max) {
    return '$selected من $max محددة';
  }

  @override
  String get searchLanguageOrTranslator => 'ابحث عن لغة أو مترجم';

  @override
  String nTranslations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ترجمات',
      one: 'ترجمة واحدة',
    );
    return '$_temp0';
  }

  @override
  String nSelected(int count) {
    return '$count محددة';
  }

  @override
  String get rightToLeftScript => 'كتابة من اليمين إلى اليسار';

  @override
  String translationLimit(int max) {
    return 'يمكنك عرض $max ترجمات كحد أقصى في آن واحد. أزل واحدة أولًا.';
  }

  @override
  String get offlineIntro =>
      'النص العربي والنطق الإنجليزي وثلاث ترجمات إنجليزية متاحة دائمًا دون اتصال. نزّل الباقي مرة واقرأ في أي مكان.';

  @override
  String get selectedTranslations => 'الترجمات المحددة';

  @override
  String get allSelectedBundled => 'جميع الترجمات المحددة مضمّنة في التطبيق.';

  @override
  String surahDownloadsSaved(int done, int total) {
    return '$done من $total سورة محفوظة';
  }

  @override
  String wordByWordPack(String language) {
    return 'كلمة بكلمة ($language)';
  }

  @override
  String surahsSavedSize(int done) {
    return '$done من 114 سورة محفوظة · نحو 8 ميغابايت';
  }

  @override
  String get tafsirSavedAutomatically =>
      'يُحفظ التفسير تلقائيًا لكل آية تفتحها.';

  @override
  String get downloadEverything => 'تنزيل كل ما هو محدد';

  @override
  String bundledEditions(String names) {
    return 'الإصدارات المضمّنة: $names.';
  }

  @override
  String get everythingOffline => 'كل ما هو محدد متاح بالفعل دون اتصال.';

  @override
  String downloadDone(int count) {
    return 'تم. حُفظ $count تنزيلًا للاستخدام دون اتصال.';
  }

  @override
  String downloadDoneWithFailures(int failed) {
    return 'اكتمل مع فشل $failed تنزيلًا (تحقق من الاتصال وأعد المحاولة).';
  }

  @override
  String downloadCancelled(int done, int total) {
    return 'أُلغي بعد $done من $total.';
  }

  @override
  String get starting => 'جارٍ البدء…';

  @override
  String get memorize => 'الحفظ';

  @override
  String memorizeHeader(String surah, int from, int to, int done, int total) {
    return '$surah · الآيات $from–$to · $done/$total محفوظة';
  }

  @override
  String get changeRange => 'تغيير النطاق';

  @override
  String wordsRevealed(int revealed, int total) {
    return '$revealed / $total كلمة';
  }

  @override
  String get nextWord => 'الكلمة التالية';

  @override
  String get revealAll => 'إظهار الكل';

  @override
  String get hideAll => 'إخفاء الكل';

  @override
  String get transliteration => 'النطق اللاتيني';

  @override
  String get translation => 'الترجمة';

  @override
  String get memorized => 'محفوظة';

  @override
  String get markAsMemorized => 'تحديد كمحفوظة';

  @override
  String get listenAndRepeat => 'استمع وكرّر';

  @override
  String get repeatEachAyah => 'تكرار كل آية';

  @override
  String get loopTheRange => 'تكرار النطاق';

  @override
  String playRange(int from, int to) {
    return 'تشغيل $from–$to';
  }

  @override
  String get thisAyah => 'هذه الآية';

  @override
  String get ayahRange => 'نطاق الآيات';

  @override
  String fromToOf(int from, int to, int total) {
    return 'من $from إلى $to من $total';
  }

  @override
  String get readingPlan => 'خطة القراءة';

  @override
  String get goalReached => 'تحقق الهدف، ما شاء الله!';

  @override
  String moreAyahsToGoal(int count) {
    return 'بقي $count آية لتحقيق هدفك';
  }

  @override
  String dayStreak(int days) {
    return 'سلسلة $days يوم';
  }

  @override
  String get dailyGoal => 'الهدف اليومي';

  @override
  String ayahsPerDay(int count) {
    return '$count آية يوميًا';
  }

  @override
  String get khatmIn30Days => '208 (ختم في 30 يومًا)';

  @override
  String get last7Days => 'آخر 7 أيام';

  @override
  String get ayahsRead => 'آيات مقروءة';

  @override
  String get activeDays => 'أيام نشطة';

  @override
  String get quranRead => 'من القرآن';

  @override
  String get khatmPlan => 'خطة الختم';

  @override
  String get khatmPlanHelp =>
      'أكمل القرآن كاملًا وفق جدول. سنخبرك بالآية التي يجب الوصول إليها كل يوم.';

  @override
  String nDays(int n) {
    return '$n يومًا';
  }

  @override
  String get startFromFatiha => 'البدء من الفاتحة';

  @override
  String get fromTheBeginning => 'من البداية';

  @override
  String get fromWhereYouAre => 'من موضعك الحالي';

  @override
  String aboutAyahsADay(int count) {
    return 'نحو $count آية يوميًا';
  }

  @override
  String get startPlan => 'بدء الخطة';

  @override
  String get endPlan => 'إنهاء الخطة';

  @override
  String planStatusLine(int day, int days, String date, int perDay) {
    return 'اليوم $day من $days · ينتهي $date · $perDay آية/يوم';
  }

  @override
  String get onTrack => 'أنت على المسار الصحيح.';

  @override
  String onTrackAhead(int count) {
    return 'أنت على المسار الصحيح، متقدم بـ $count آية.';
  }

  @override
  String catchUp(int count) {
    return 'اقرأ $count آية إضافية اليوم للحاق بالخطة.';
  }

  @override
  String todaysTarget(String surah, String key) {
    return 'هدف اليوم: $surah $key';
  }

  @override
  String get continueReadingButton => 'متابعة القراءة';

  @override
  String get hadith => 'الحديث';

  @override
  String get hadithIntro =>
      'الكتب الستة وموطأ مالك وثلاثة من الأربعينيات، بالعربية مع الترجمة. يُنزّل كل باب مرة ويبقى دون اتصال.';

  @override
  String hadithsChapters(int hadiths, int chapters) {
    return '$hadiths حديث · $chapters باب';
  }

  @override
  String couldNotLoadHadithBooks(String error) {
    return 'تعذّر تحميل كتب الحديث: $error';
  }

  @override
  String get findAChapter => 'ابحث عن باب';

  @override
  String hadithsRange(int first, int last) {
    return 'الأحاديث $first–$last';
  }

  @override
  String chapterN(int n) {
    return 'الباب $n';
  }

  @override
  String get chapterNeedsInternet =>
      'يحتاج هذا الباب إلى اتصال بالإنترنت في المرة الأولى.';

  @override
  String searchHadithsInChapter(int count) {
    return 'ابحث في $count حديثًا في هذا الباب';
  }

  @override
  String get previousChapter => 'الباب السابق';

  @override
  String get nextChapter => 'الباب التالي';

  @override
  String get hadithCopied => 'تم نسخ الحديث';

  @override
  String get prayerTimes => 'مواقيت الصلاة';

  @override
  String get prayerTimesForMasjid => 'مواقيت الصلاة لمسجدك';

  @override
  String get prayerIntro =>
      'أدخل العنوان الكامل للمسجد أو الرمز البريدي. يُحوَّل إلى إحداثيات دقيقة ومنطقته الزمنية، ثم تُولَّد مواقيت الصلاة والإقامة والجمعة بطريقة الحساب التي تختارها.';

  @override
  String get setUpMasjid => 'إعداد مسجد من عنوانه';

  @override
  String get useMyLocation => 'استخدام موقعي الحالي';

  @override
  String get methodsList =>
      'طرق الحساب: ISNA، رابطة العالم الإسلامي، الهيئة المصرية، كراتشي، أم القرى، الخليج، الكويت، قطر، سنغافورة، ديانت، UOIF، روسيا، طهران والجعفري. العصر: شافعي/مالكي/حنبلي أو حنفي.';

  @override
  String couldNotGetLocation(String error) {
    return 'تعذّر تحديد موقعك: $error';
  }

  @override
  String get monthlyTimetable => 'جدول الشهر';

  @override
  String get shareToday => 'مشاركة مواقيت اليوم';

  @override
  String get editMasjid => 'تعديل المسجد';

  @override
  String get addAnotherMasjid => 'إضافة مسجد آخر';

  @override
  String get removeMasjid => 'إزالة المسجد';

  @override
  String removeMasjidQuestion(String name) {
    return 'إزالة $name؟';
  }

  @override
  String get removeMasjidBody =>
      'سيُحذف عنوانه وإعدادات الحساب ومواقيت الإقامة والجمعة.';

  @override
  String nextPrayerIn(String prayer, String time, String duration) {
    return '$prayer في $time · بعد $duration';
  }

  @override
  String get fajrTomorrow => 'الفجر (غدًا)';

  @override
  String get jumuah => 'الجمعة';

  @override
  String get noJumuahSet => 'لم تُحدد صلوات جمعة. عدّل المسجد لإضافتها.';

  @override
  String khutbahAt(String time) {
    return 'الخطبة $time';
  }

  @override
  String iqamaAt(String time) {
    return 'الإقامة $time';
  }

  @override
  String timesFootnote(String lat, String lng, String tz) {
    return 'تُحسب المواقيت فلكيًا للإحداثيات $lat، $lng في منطقة $tz مقرّبة إلى الدقيقة. التاريخ الهجري محسوب وقد يختلف يومًا عن الرؤية المحلية.';
  }

  @override
  String qiblaDegrees(int degrees) {
    return 'القبلة $degrees°';
  }

  @override
  String get asrShafii => 'العصر شافعي';

  @override
  String get asrHanafi => 'العصر حنفي';

  @override
  String get fajr => 'الفجر';

  @override
  String get sunrise => 'الشروق';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String get addMasjid => 'إضافة مسجد';

  @override
  String get masjid => 'المسجد';

  @override
  String get masjidName => 'اسم المسجد';

  @override
  String get enterAName => 'أدخل اسمًا';

  @override
  String get address => 'العنوان';

  @override
  String get streetAddress => 'الشارع';

  @override
  String get city => 'المدينة';

  @override
  String get stateProvince => 'الولاية / المحافظة';

  @override
  String get postalCode => 'الرمز البريدي';

  @override
  String get countryCode => 'رمز الدولة (US, GB, FR…)';

  @override
  String get findLocation => 'تحديد الموقع';

  @override
  String get deviceGps => 'GPS الجهاز';

  @override
  String get coordinatesAndTimeZone => 'الإحداثيات والمنطقة الزمنية';

  @override
  String get setAutomatically => 'تُضبط تلقائيًا من العنوان';

  @override
  String get latitude => 'خط العرض';

  @override
  String get longitude => 'خط الطول';

  @override
  String get ianaTimeZone => 'المنطقة الزمنية IANA (مثل Europe/London)';

  @override
  String get calculation => 'الحساب';

  @override
  String get calculationMethod => 'طريقة الحساب';

  @override
  String get asrShafiiFull => 'العصر: شافعي / مالكي / حنبلي';

  @override
  String get asrHanafiFull => 'العصر: حنفي';

  @override
  String get dhuhrAfterZawal => 'الظهر: دقائق بعد الزوال';

  @override
  String get maghribAfterSunset => 'المغرب: دقائق بعد الغروب';

  @override
  String get fineTune => 'ضبط دقيق لكل صلاة (دقائق)';

  @override
  String get hijriAdjustment => 'تعديل التاريخ الهجري (أيام)';

  @override
  String get iqama => 'الإقامة';

  @override
  String get jumuahServices => 'صلوات الجمعة';

  @override
  String get addJumuahTime => 'إضافة وقت الجمعة';

  @override
  String get addAnotherService => 'إضافة صلاة أخرى';

  @override
  String get saveMasjid => 'حفظ المسجد';

  @override
  String get none => 'لا شيء';

  @override
  String get fixed => 'ثابت';

  @override
  String get plusMinutes => '+ دقائق';

  @override
  String get khutbahPicker => 'الخطبة…';

  @override
  String get jumuahLabelHint => 'وصف (اللغة، القاعة، الخطيب)';

  @override
  String get enterZipOrCity => 'أدخل على الأقل الرمز البريدي أو المدينة.';

  @override
  String get lookingUpAddress => 'جارٍ البحث عن العنوان…';

  @override
  String get noMatchTryCountry =>
      'لا توجد نتيجة. جرّب إضافة المدينة ورمز الدولة من حرفين (مثل US أو GB أو FR).';

  @override
  String get chooseLocation => 'اختر الموقع الصحيح:';

  @override
  String lookupFailed(String error) {
    return 'فشل البحث: $error';
  }

  @override
  String get resolvingTimeZone => 'جارٍ تحديد المنطقة الزمنية…';

  @override
  String located(String name) {
    return 'تم التحديد: $name';
  }

  @override
  String timeZoneLookupFailed(String error) {
    return 'ضُبطت الإحداثيات لكن فشل تحديد المنطقة الزمنية ($error). أدخل منطقة IANA مثل America/New_York.';
  }

  @override
  String get gettingPosition => 'جارٍ تحديد موقعك…';

  @override
  String couldNotUseDevice(String error) {
    return 'تعذّر استخدام موقع الجهاز: $error';
  }

  @override
  String get findLocationFirst =>
      'اضغط \"تحديد الموقع\" أولًا لضبط الإحداثيات والمنطقة الزمنية.';

  @override
  String get setUpMasjidFirst => 'أعدّ مسجدًا أولًا.';

  @override
  String get hideIqama => 'إخفاء الإقامة';

  @override
  String get showIqama => 'إظهار الإقامة';

  @override
  String get copyAsCsv => 'نسخ كـ CSV';

  @override
  String get csvCopied => 'تم نسخ CSV — الصقه في Excel أو Sheets';

  @override
  String get shareAsText => 'مشاركة كنص';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get date => 'التاريخ';

  @override
  String get mushafLayout => 'التخطيط';

  @override
  String get layoutAutomatic => 'تلقائي';

  @override
  String get layoutScroll => 'صفحة واحدة، تمرير للأسفل';

  @override
  String get layoutFlip => 'صفحة واحدة، تقليب';

  @override
  String get layoutBook => 'صفحتان، تقليب';

  @override
  String get playThisPage => 'تشغيل هذه الصفحة';

  @override
  String get goToPage => 'الانتقال إلى صفحة';

  @override
  String get goTo => 'الانتقال إلى';

  @override
  String get pageRange => 'الصفحة (1–604)';

  @override
  String get previousPage => 'الصفحة السابقة';

  @override
  String get nextPage => 'الصفحة التالية';

  @override
  String pageJuz(int page, int juz) {
    return 'الصفحة $page · الجزء $juz';
  }

  @override
  String get library => 'المكتبة';

  @override
  String get openBook => 'فتح الكتاب';

  @override
  String get tableOfContents => 'الفهرس';

  @override
  String chapterPage(int chapter, int page, int total) {
    return 'الباب $chapter · الصفحة $page / $total';
  }

  @override
  String get listView => 'عرض القائمة';

  @override
  String get downloadPdf => 'تنزيل PDF';

  @override
  String get downloadChapterPdf => 'تنزيل هذا الباب بصيغة PDF';

  @override
  String get downloadBookPdf => 'تنزيل الكتاب كاملًا بصيغة PDF';

  @override
  String preparingPdf(int done, int total) {
    return 'جارٍ جلب الأبواب… $done / $total';
  }

  @override
  String get renderingPdf => 'جارٍ إنشاء ملف PDF…';

  @override
  String pdfFailed(String error) {
    return 'تعذّر إنشاء ملف PDF: $error';
  }

  @override
  String hadithsCount(int count) {
    return '$count حديث';
  }

  @override
  String byAuthor(String author) {
    return 'تأليف $author';
  }

  @override
  String get reciteAndCheck => 'تسميع وتصحيح';

  @override
  String get reciteFromHere => 'التسميع من هنا';

  @override
  String get reciteSubtitle => 'سمّع من حفظك؛ يستمع التطبيق ويعلّم كل كلمة';

  @override
  String ayahRangeLabel(int from, int to) {
    return 'الآيات $from–$to';
  }

  @override
  String get accuracy => 'الدقة';

  @override
  String get matchedWords => 'صحيحة';

  @override
  String get wrongWords => 'خطأ';

  @override
  String get missedWords => 'ساقطة';

  @override
  String wordsReached(int reached, int total) {
    return 'تمت تلاوة $reached من $total كلمة';
  }

  @override
  String get listening => 'جارٍ الاستماع…';

  @override
  String get waitingForSpeech => 'في انتظار الصوت…';

  @override
  String get tapMicToStart => 'اضغط الميكروفون وابدأ التسميع';

  @override
  String get heard => 'المسموع';

  @override
  String get notInPassage => 'كلمات ليست في المقطع';

  @override
  String get hideText => 'إخفاء النص (للحفظ)';

  @override
  String get showText => 'إظهار النص';

  @override
  String get hint => 'تلميح';

  @override
  String get reset => 'إعادة';

  @override
  String get playThisAyah => 'تشغيل هذه الآية';

  @override
  String get speechUnavailable =>
      'التعرف على الكلام غير متاح. اسمح بالوصول إلى الميكروفون أو استخدم متصفح Chrome على الويب.';

  @override
  String get reciteHelp =>
      'سمّع بوضوح وبوتيرة ثابتة. يعمل التعرف بشكل أفضل في مكان هادئ؛ الكلمات الصحيحة تصبح خضراء، والزلات برتقالية، والساقطة حمراء.';

  @override
  String get qibla => 'القبلة';

  @override
  String get qiblaBearing => 'اتجاه القبلة من الشمال الحقيقي';

  @override
  String get qiblaNeedsLocation =>
      'تُحسب القبلة من موقعك. استخدم GPS جهازك أو أعدّ مسجدًا أولًا.';

  @override
  String distanceToMakkah(int km) {
    return '$km كم إلى مكة';
  }

  @override
  String headingDegrees(int degrees) {
    return 'الاتجاه $degrees°';
  }

  @override
  String get facingQibla => 'أنت متجه إلى القبلة';

  @override
  String get compassWaiting =>
      'في انتظار البوصلة… حرّك الهاتف على شكل الرقم 8 للمعايرة.';

  @override
  String get compassUnavailable =>
      'لا توجد بوصلة في هذا الجهاز: استخدم بوصلة أو خريطة واتجه نحو الزاوية أعلاه.';

  @override
  String turnToQibla(String direction, int degrees) {
    return 'استدر إلى $direction بمقدار $degrees°';
  }

  @override
  String get left => 'اليسار';

  @override
  String get right => 'اليمين';

  @override
  String get qiblaHelp =>
      'أبقِ الهاتف مستويًا وبعيدًا عن المغناطيس والمعادن. علامة الكعبة على القرص تشير إلى القبلة، والسهم في الأعلى هو اتجاهك.';

  @override
  String get adhan => 'الأذان';

  @override
  String get adhanIntro =>
      'استمع إلى الأذان بأصوات مؤذنين مختلفين، ونزّل أي تسجيل، واختر الأذان الافتراضي لمواقيت صلاتك.';

  @override
  String get adhanCredits =>
      'التسجيلات من مجموعتي \"adhans\" و\"azan-alafasy\" في أرشيف الإنترنت.';

  @override
  String downloaded(String name) {
    return 'تم تنزيل $name';
  }

  @override
  String downloadFailed(String error) {
    return 'فشل التنزيل: $error';
  }

  @override
  String get downloadSurahAudio => 'تنزيل صوت السورة للاستماع دون اتصال';

  @override
  String get downloadAyahAudio => 'تنزيل صوت هذه الآية (MP3)';

  @override
  String get offlineAudioNativeOnly =>
      'يُحفظ الصوت دون اتصال في تطبيقات الجوال وسطح المكتب؛ على الويب نزّل الآيات منفردة.';

  @override
  String surahAudioSaved(String surah) {
    return 'حُفظت $surah للاستماع دون اتصال';
  }

  @override
  String get downloadForOffline => 'تنزيل للقراءة دون اتصال';

  @override
  String savedForOffline(String name) {
    return 'حُفظ $name للقراءة دون اتصال';
  }

  @override
  String get playAdhan => 'تشغيل الأذان';

  @override
  String adhanForNext(String prayer) {
    return 'أذان $prayer';
  }

  @override
  String get chooseAdhan => 'اختيار الأذان';

  @override
  String get pageAnimation => 'حركة الصفحات';

  @override
  String get animationCurl => 'طيّ الورقة';

  @override
  String get animationFlip => 'قلب البطاقة';

  @override
  String get animationSlide => 'انزلاق';

  @override
  String get animationFade => 'تلاشٍ';

  @override
  String get highlight => 'تمييز';

  @override
  String get removeHighlight => 'إزالة التمييز';

  @override
  String get note => 'ملاحظة';

  @override
  String get noteHint => 'اكتب تأملك أو تذكيرك لهذه الآية…';

  @override
  String get noteSaved => 'تم حفظ الملاحظة';

  @override
  String get noteHelp =>
      'تبقى الملاحظات على هذا الجهاز. تظهر الآيات المميزة ملوّنة في صفحات المصحف.';

  @override
  String get continuous => 'متابعة تلقائية';

  @override
  String get repeatEach => 'تكرار';

  @override
  String get verseDetails => 'تفاصيل الآية';
}
