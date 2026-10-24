// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Quran+';

  @override
  String get navRead => 'Read';

  @override
  String get navHadith => 'Hadith';

  @override
  String get navPrayer => 'Prayer';

  @override
  String get navSaved => 'Saved';

  @override
  String get navSettings => 'Settings';

  @override
  String get search => 'Search';

  @override
  String get searchTheQuran => 'Search the Quran';

  @override
  String get cancel => 'Cancel';

  @override
  String get open => 'Open';

  @override
  String get apply => 'Apply';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get clear => 'Clear';

  @override
  String get remove => 'Remove';

  @override
  String get download => 'Download';

  @override
  String get more => 'More';

  @override
  String get back => 'Back';

  @override
  String get loading => 'Loading…';

  @override
  String get couldNotLoadQuran => 'Could not load the Quran data.';

  @override
  String get continueReading => 'CONTINUE READING';

  @override
  String get startReading => 'START READING';

  @override
  String ayahOfJuzPage(int ayah, int total, int juz, int page) {
    return 'Ayah $ayah of $total · Juz $juz · Page $page';
  }

  @override
  String get verseOfTheDay => 'VERSE OF THE DAY';

  @override
  String get today => 'Today';

  @override
  String dailyGoalTapToStartPlan(int goal) {
    return 'Daily goal $goal ayahs · tap to start a khatm plan';
  }

  @override
  String khatmOnTrack(int day, int days) {
    return 'Khatm plan: on track · day $day/$days';
  }

  @override
  String khatmBehind(int behind, int day, int days) {
    return 'Khatm plan: $behind ayahs behind · day $day/$days';
  }

  @override
  String get findSurahHint => 'Find a surah by name, meaning or number';

  @override
  String get tabSurah => 'Surah';

  @override
  String get tabJuz => 'Juz';

  @override
  String get tabPage => 'Page';

  @override
  String get noSurahMatches => 'No surah matches your search.';

  @override
  String surahSubtitle(String meaning, int count, String type) {
    return '$meaning · $count ayahs · $type';
  }

  @override
  String get meccan => 'Meccan';

  @override
  String get medinan => 'Medinan';

  @override
  String juzN(int n) {
    return 'Juz $n';
  }

  @override
  String juzStartsAt(String surah, int ayah, int count) {
    return 'Starts at $surah, ayah $ayah · $count ayahs';
  }

  @override
  String get jumpToSurah => 'Jump to surah';

  @override
  String pageN(int n) {
    return 'Page $n';
  }

  @override
  String get backToSurahs => 'Back to surahs';

  @override
  String get openMushafHere => 'Open the Mushaf book at this surah';

  @override
  String get translations => 'Translations';

  @override
  String get readingSettings => 'Reading settings';

  @override
  String get playSurah => 'Play surah';

  @override
  String get pauseRecitation => 'Pause recitation';

  @override
  String get memorizeThisSurah => 'Memorize this surah';

  @override
  String get openInMushaf => 'Open in Mushaf book';

  @override
  String juzPage(int juz, int page) {
    return 'Juz $juz · Page $page';
  }

  @override
  String get wordByWord => 'Word by word';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get bookmark => 'Bookmark';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get bookmarkThisAyah => 'Bookmark this ayah';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get playFromThisAyah => 'Play from this ayah';

  @override
  String get sajdahAyah => 'Sajdah (prostration) ayah';

  @override
  String couldNotLoad(String name) {
    return 'Could not load $name';
  }

  @override
  String wordByWordOffline(String error) {
    return 'Word-by-word unavailable offline ($error)';
  }

  @override
  String ayahN(int n) {
    return 'Ayah $n';
  }

  @override
  String get wordByWordSubtitle => 'Transliteration and meaning of every word';

  @override
  String get tafsirSubtitle => 'Commentary from Ibn Kathir and others';

  @override
  String get playRecitationFromHere => 'Play recitation from here';

  @override
  String get memorizeFromHere => 'Memorize from here';

  @override
  String get memorizeSubtitle =>
      'Hide words, reveal one by one, loop the recitation';

  @override
  String get ayahCopied => 'Ayah copied';

  @override
  String wordN(int n) {
    return 'Word $n';
  }

  @override
  String get wordByWordNeedsInternet =>
      'Word-by-word data needs an internet connection the first time.';

  @override
  String get tafsirNeedsInternet =>
      'Tafsir needs an internet connection the first time.';

  @override
  String get viaQuranCom => 'via Quran.com';

  @override
  String get reciter => 'Reciter';

  @override
  String get arabicSize => 'Arabic size';

  @override
  String get translationSize => 'Translation size';

  @override
  String get amiriQuran => 'Amiri Quran';

  @override
  String get amiriNaskh => 'Amiri Naskh';

  @override
  String get showTransliteration => 'Show transliteration';

  @override
  String get showTransliterationSubtitle =>
      'Latin-script pronunciation under each ayah';

  @override
  String get wordByWordMode => 'Word-by-word mode';

  @override
  String get wordByWordModeSubtitle =>
      'Every word with its transliteration and meaning';

  @override
  String get wordMeaningsLanguage => 'Word meanings language';

  @override
  String get tapAyahHint =>
      'Tap any ayah for translation, transliteration, tafsir and word-by-word.';

  @override
  String get previousAyah => 'Previous ayah';

  @override
  String get nextAyah => 'Next ayah';

  @override
  String get stop => 'Stop';

  @override
  String get loop => 'loop';

  @override
  String get searchHint => 'Arabic, transliteration or English…';

  @override
  String get searchWholeQuran => 'Search the whole Quran';

  @override
  String get searchHelp =>
      'Type Arabic (with or without harakat), a transliterated phrase, or an English word. Results open the ayah in the reader.';

  @override
  String noAyahMatches(String query) {
    return 'No ayah matches \"$query\"';
  }

  @override
  String resultsCount(String count) {
    return '$count results';
  }

  @override
  String get savedAyahs => 'Saved ayahs';

  @override
  String get noBookmarksYet => 'No bookmarks yet';

  @override
  String get noBookmarksHelp =>
      'Tap the bookmark icon on any ayah while reading to save it here.';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get arabicFont => 'Arabic font';

  @override
  String get language => 'App language';

  @override
  String get systemDefault => 'System default';

  @override
  String get recitation => 'Recitation';

  @override
  String get recitationHelp =>
      'Audio streams verse by verse from everyayah.com. Tap play on any ayah, or \"Play surah\" in the surah header.';

  @override
  String get reading => 'Reading';

  @override
  String get wordByWordSettingSubtitle =>
      'Show each word with its transliteration and meaning (downloads once per surah)';

  @override
  String get defaultView => 'Default view';

  @override
  String get viewTranslation => 'Translation';

  @override
  String get viewMushafBook => 'Mushaf book';

  @override
  String get languages => 'Languages';

  @override
  String get arabicOnlyTapToAdd => 'Arabic only — tap to add translations';

  @override
  String translationsAvailable(int count, int languages) {
    return '$count translations in $languages languages are available. Each one is downloaded the first time you open a surah and kept offline.';
  }

  @override
  String get storage => 'Storage';

  @override
  String get offlinePacks => 'Offline packs';

  @override
  String get offlinePacksSubtitle =>
      'Download translations and word-by-word for the whole Quran';

  @override
  String get clearDownloadedData => 'Clear downloaded data';

  @override
  String cachedDownloads(int count) {
    return '$count cached surah downloads';
  }

  @override
  String get clearDownloadedDataQuestion => 'Clear downloaded data?';

  @override
  String get clearDownloadedDataBody =>
      'Translations and word-by-word data will be downloaded again when needed. Bookmarks and settings are kept.';

  @override
  String get downloadedDataCleared => 'Downloaded data cleared';

  @override
  String get about => 'About';

  @override
  String get versionBuiltWith => 'Version 1.0.0 · Built with Flutter';

  @override
  String get credits =>
      'Arabic text: Tanzil Uthmani edition. Translations and transliteration: Al Quran Cloud. Word-by-word and tafsir: Quran.com. Recitation: EveryAyah.com. Hadith: fawazahmed0/hadith-api. Fonts: Amiri & Amiri Quran (SIL Open Font License).';

  @override
  String selectedOfMax(int selected, int max) {
    return '$selected of $max selected';
  }

  @override
  String get searchLanguageOrTranslator => 'Search a language or translator';

  @override
  String nTranslations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count translations',
      one: '1 translation',
    );
    return '$_temp0';
  }

  @override
  String nSelected(int count) {
    return '$count selected';
  }

  @override
  String get rightToLeftScript => 'Right-to-left script';

  @override
  String translationLimit(int max) {
    return 'You can show up to $max translations at once. Remove one first.';
  }

  @override
  String get offlineIntro =>
      'The Arabic text, English transliteration and three English translations are always offline. Download the rest once and read anywhere.';

  @override
  String get selectedTranslations => 'Selected translations';

  @override
  String get allSelectedBundled =>
      'All selected translations are bundled with the app.';

  @override
  String surahDownloadsSaved(int done, int total) {
    return '$done of $total surah downloads saved';
  }

  @override
  String wordByWordPack(String language) {
    return 'Word by word ($language)';
  }

  @override
  String surahsSavedSize(int done) {
    return '$done of 114 surahs saved · about 8 MB';
  }

  @override
  String get tafsirSavedAutomatically =>
      'Tafsir is saved automatically for every ayah you open.';

  @override
  String get downloadEverything => 'Download everything selected';

  @override
  String bundledEditions(String names) {
    return 'Bundled editions: $names.';
  }

  @override
  String get everythingOffline =>
      'Everything selected is already available offline.';

  @override
  String downloadDone(int count) {
    return 'Done. $count downloads saved for offline use.';
  }

  @override
  String downloadDoneWithFailures(int failed) {
    return 'Done with $failed failed downloads (check your connection and run again).';
  }

  @override
  String downloadCancelled(int done, int total) {
    return 'Cancelled after $done of $total.';
  }

  @override
  String get starting => 'Starting…';

  @override
  String get memorize => 'Memorize';

  @override
  String memorizeHeader(String surah, int from, int to, int done, int total) {
    return '$surah · Ayahs $from–$to · $done/$total memorized';
  }

  @override
  String get changeRange => 'Change range';

  @override
  String wordsRevealed(int revealed, int total) {
    return '$revealed / $total words';
  }

  @override
  String get nextWord => 'Next word';

  @override
  String get revealAll => 'Reveal all';

  @override
  String get hideAll => 'Hide all';

  @override
  String get transliteration => 'Transliteration';

  @override
  String get translation => 'Translation';

  @override
  String get memorized => 'Memorized';

  @override
  String get markAsMemorized => 'Mark as memorized';

  @override
  String get listenAndRepeat => 'Listen & repeat';

  @override
  String get repeatEachAyah => 'Repeat each ayah';

  @override
  String get loopTheRange => 'Loop the range';

  @override
  String playRange(int from, int to) {
    return 'Play $from–$to';
  }

  @override
  String get thisAyah => 'This ayah';

  @override
  String get ayahRange => 'Ayah range';

  @override
  String fromToOf(int from, int to, int total) {
    return 'From $from to $to of $total';
  }

  @override
  String get readingPlan => 'Reading plan';

  @override
  String get goalReached => 'Goal reached, mashaAllah!';

  @override
  String moreAyahsToGoal(int count) {
    return '$count more ayahs to reach your goal';
  }

  @override
  String dayStreak(int days) {
    return '$days-day streak';
  }

  @override
  String get dailyGoal => 'Daily goal';

  @override
  String ayahsPerDay(int count) {
    return '$count ayahs per day';
  }

  @override
  String get khatmIn30Days => '208 (khatm in 30 days)';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get ayahsRead => 'Ayahs read';

  @override
  String get activeDays => 'Active days';

  @override
  String get quranRead => 'Quran read';

  @override
  String get khatmPlan => 'Khatm plan';

  @override
  String get khatmPlanHelp =>
      'Finish the whole Quran on a schedule. We will tell you the ayah to reach each day.';

  @override
  String nDays(int n) {
    return '$n days';
  }

  @override
  String get startFromFatiha => 'Start from Al-Fatiha';

  @override
  String get fromTheBeginning => 'From the beginning';

  @override
  String get fromWhereYouAre => 'From where you are now';

  @override
  String aboutAyahsADay(int count) {
    return 'About $count ayahs a day';
  }

  @override
  String get startPlan => 'Start plan';

  @override
  String get endPlan => 'End plan';

  @override
  String planStatusLine(int day, int days, String date, int perDay) {
    return 'Day $day of $days · ends $date · $perDay ayahs/day';
  }

  @override
  String get onTrack => 'You are on track.';

  @override
  String onTrackAhead(int count) {
    return 'You are on track, $count ayahs ahead.';
  }

  @override
  String catchUp(int count) {
    return 'Read $count more ayahs today to catch up.';
  }

  @override
  String todaysTarget(String surah, String key) {
    return 'Today\'s target: $surah $key';
  }

  @override
  String get continueReadingButton => 'Continue reading';

  @override
  String get hadith => 'Hadith';

  @override
  String get hadithIntro =>
      'The six canonical collections, Muwatta Malik and three forty-hadith collections, with Arabic and translation. Each chapter downloads once and stays offline.';

  @override
  String hadithsChapters(int hadiths, int chapters) {
    return '$hadiths hadiths · $chapters chapters';
  }

  @override
  String couldNotLoadHadithBooks(String error) {
    return 'Could not load hadith books: $error';
  }

  @override
  String get findAChapter => 'Find a chapter';

  @override
  String hadithsRange(int first, int last) {
    return 'Hadiths $first–$last';
  }

  @override
  String chapterN(int n) {
    return 'Chapter $n';
  }

  @override
  String get chapterNeedsInternet =>
      'This chapter needs an internet connection the first time.';

  @override
  String searchHadithsInChapter(int count) {
    return 'Search $count hadiths in this chapter';
  }

  @override
  String get previousChapter => 'Previous chapter';

  @override
  String get nextChapter => 'Next chapter';

  @override
  String get hadithCopied => 'Hadith copied';

  @override
  String get prayerTimes => 'Prayer times';

  @override
  String get prayerTimesForMasjid => 'Prayer times for your masjid';

  @override
  String get prayerIntro =>
      'Enter the masjid\'s full address or ZIP code. It is geocoded to precise coordinates and its time zone, then daily prayer, iqama and Jumu\'ah times are generated with the calculation method you choose.';

  @override
  String get setUpMasjid => 'Set up a masjid from its address';

  @override
  String get useMyLocation => 'Use my current location';

  @override
  String get methodsList =>
      'Calculation methods: ISNA, Muslim World League, Egyptian, Karachi, Umm al-Qura, Gulf, Kuwait, Qatar, Singapore, Diyanet, UOIF, Russia, Tehran and Jafari. Asr: Shafi\'i/Maliki/Hanbali or Hanafi.';

  @override
  String couldNotGetLocation(String error) {
    return 'Could not get your location: $error';
  }

  @override
  String get monthlyTimetable => 'Monthly timetable';

  @override
  String get shareToday => 'Share today';

  @override
  String get editMasjid => 'Edit masjid';

  @override
  String get addAnotherMasjid => 'Add another masjid';

  @override
  String get removeMasjid => 'Remove masjid';

  @override
  String removeMasjidQuestion(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeMasjidBody =>
      'Its address, calculation settings, iqama and Jumu\'ah times will be deleted.';

  @override
  String nextPrayerIn(String prayer, String time, String duration) {
    return '$prayer at $time · in $duration';
  }

  @override
  String get fajrTomorrow => 'Fajr (tomorrow)';

  @override
  String get jumuah => 'Jumu\'ah';

  @override
  String get noJumuahSet =>
      'No Jumu\'ah services set. Edit the masjid to add them.';

  @override
  String khutbahAt(String time) {
    return 'Khutbah $time';
  }

  @override
  String iqamaAt(String time) {
    return 'Iqama $time';
  }

  @override
  String timesFootnote(String lat, String lng, String tz) {
    return 'Times are computed astronomically for $lat, $lng in the $tz zone, rounded to the minute. Hijri date is calculated and may differ by a day from local moon sighting.';
  }

  @override
  String qiblaDegrees(int degrees) {
    return 'Qibla $degrees°';
  }

  @override
  String get asrShafii => 'Asr Shafi\'i';

  @override
  String get asrHanafi => 'Asr Hanafi';

  @override
  String get fajr => 'Fajr';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get addMasjid => 'Add masjid';

  @override
  String get masjid => 'Masjid';

  @override
  String get masjidName => 'Masjid name';

  @override
  String get enterAName => 'Enter a name';

  @override
  String get address => 'Address';

  @override
  String get streetAddress => 'Street address';

  @override
  String get city => 'City';

  @override
  String get stateProvince => 'State / Province';

  @override
  String get postalCode => 'ZIP / Postal code';

  @override
  String get countryCode => 'Country code (US, GB, FR…)';

  @override
  String get findLocation => 'Find location';

  @override
  String get deviceGps => 'Device GPS';

  @override
  String get coordinatesAndTimeZone => 'Coordinates & time zone';

  @override
  String get setAutomatically => 'Set automatically from the address';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get ianaTimeZone => 'IANA time zone (e.g. Europe/London)';

  @override
  String get calculation => 'Calculation';

  @override
  String get calculationMethod => 'Calculation method';

  @override
  String get asrShafiiFull => 'Asr: Shafi\'i / Maliki / Hanbali';

  @override
  String get asrHanafiFull => 'Asr: Hanafi';

  @override
  String get dhuhrAfterZawal => 'Dhuhr: minutes after zawal';

  @override
  String get maghribAfterSunset => 'Maghrib: minutes after sunset';

  @override
  String get fineTune => 'Fine-tune each prayer (minutes)';

  @override
  String get hijriAdjustment => 'Hijri date adjustment (days)';

  @override
  String get iqama => 'Iqama';

  @override
  String get jumuahServices => 'Jumu\'ah services';

  @override
  String get addJumuahTime => 'Add Jumu\'ah time';

  @override
  String get addAnotherService => 'Add another service';

  @override
  String get saveMasjid => 'Save masjid';

  @override
  String get none => 'None';

  @override
  String get fixed => 'Fixed';

  @override
  String get plusMinutes => '+ min';

  @override
  String get khutbahPicker => 'Khutbah…';

  @override
  String get jumuahLabelHint => 'Label (language, hall, khateeb)';

  @override
  String get enterZipOrCity => 'Enter at least a ZIP / postal code or a city.';

  @override
  String get lookingUpAddress => 'Looking up the address…';

  @override
  String get noMatchTryCountry =>
      'No match. Try adding the city and a 2-letter country code (e.g. US, GB, FR).';

  @override
  String get chooseLocation => 'Choose the correct location:';

  @override
  String lookupFailed(String error) {
    return 'Lookup failed: $error';
  }

  @override
  String get resolvingTimeZone => 'Resolving time zone…';

  @override
  String located(String name) {
    return 'Located: $name';
  }

  @override
  String timeZoneLookupFailed(String error) {
    return 'Coordinates set, but time zone lookup failed ($error). Enter an IANA zone such as America/New_York.';
  }

  @override
  String get gettingPosition => 'Getting your position…';

  @override
  String couldNotUseDevice(String error) {
    return 'Could not use device location: $error';
  }

  @override
  String get findLocationFirst =>
      'Tap \"Find location\" first so the coordinates and time zone are set.';

  @override
  String get setUpMasjidFirst => 'Set up a masjid first.';

  @override
  String get hideIqama => 'Hide iqama';

  @override
  String get showIqama => 'Show iqama';

  @override
  String get copyAsCsv => 'Copy as CSV';

  @override
  String get csvCopied => 'CSV copied — paste into Excel or Sheets';

  @override
  String get shareAsText => 'Share as text';

  @override
  String get thisMonth => 'This month';

  @override
  String get date => 'Date';

  @override
  String get mushafLayout => 'Layout';

  @override
  String get layoutAutomatic => 'Automatic';

  @override
  String get layoutScroll => 'Single page, scroll down';

  @override
  String get layoutFlip => 'Single page, flip';

  @override
  String get layoutBook => 'Two pages, flip';

  @override
  String get playThisPage => 'Play this page';

  @override
  String get goToPage => 'Go to page';

  @override
  String get goTo => 'Go to';

  @override
  String get pageRange => 'Page (1–604)';

  @override
  String get previousPage => 'Previous page';

  @override
  String get nextPage => 'Next page';

  @override
  String pageJuz(int page, int juz) {
    return 'Page $page · Juz $juz';
  }
}
