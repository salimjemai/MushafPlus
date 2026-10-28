// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mushaf+';

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
      'Arabic text: Tanzil Uthmani edition. Translations and transliteration: Al Quran Cloud. Word-by-word and tafsir: Quran.com. Recitation: EveryAyah.com. Hadith: fawazahmed0/hadith-api. Fonts: Amiri & Amiri Quran (SIL Open Font License). Voice model: derived from tarteel-ai/whisper-base-ar-quran (Apache-2.0, fine-tuned from OpenAI Whisper), run on-device with transformers.js and ONNX Runtime (Apache-2.0).';

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

  @override
  String get library => 'Library';

  @override
  String get openBook => 'Open book';

  @override
  String get tableOfContents => 'Contents';

  @override
  String chapterPage(int chapter, int page, int total) {
    return 'Chapter $chapter · Page $page / $total';
  }

  @override
  String get listView => 'List view';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get downloadChapterPdf => 'Download this chapter as PDF';

  @override
  String get downloadBookPdf => 'Download the whole book as PDF';

  @override
  String preparingPdf(int done, int total) {
    return 'Fetching chapters… $done / $total';
  }

  @override
  String get renderingPdf => 'Rendering the PDF…';

  @override
  String pdfFailed(String error) {
    return 'Could not create the PDF: $error';
  }

  @override
  String hadithsCount(int count) {
    return '$count hadiths';
  }

  @override
  String byAuthor(String author) {
    return 'by $author';
  }

  @override
  String get reciteAndCheck => 'Recite & check';

  @override
  String get reciteFromHere => 'Recite from here';

  @override
  String get reciteSubtitle =>
      'Recite from memory; the app listens and marks each word';

  @override
  String ayahRangeLabel(int from, int to) {
    return 'Ayahs $from–$to';
  }

  @override
  String get accuracy => 'accuracy';

  @override
  String get matchedWords => 'correct';

  @override
  String get wrongWords => 'wrong';

  @override
  String get missedWords => 'missed';

  @override
  String wordsReached(int reached, int total) {
    return '$reached of $total words recited';
  }

  @override
  String get listening => 'Listening…';

  @override
  String get waitingForSpeech => 'Waiting for speech…';

  @override
  String get tapMicToStart => 'Tap the microphone and start reciting';

  @override
  String get heard => 'Heard';

  @override
  String get notInPassage => 'Words not in the passage';

  @override
  String get hideText => 'Hide the text (memorisation)';

  @override
  String get showText => 'Show the text';

  @override
  String get hint => 'Hint';

  @override
  String get reset => 'Reset';

  @override
  String get playThisAyah => 'Play this ayah';

  @override
  String get speechUnavailable =>
      'Speech recognition is not available. Allow microphone access, or use Chrome on the web.';

  @override
  String get reciteHelp =>
      'Recite clearly and at a steady pace. Recognition works best in a quiet room; correct words turn green, wrong words red (with a buzz), skipped words orange. Keep going after a slip and the checker follows you.';

  @override
  String get qibla => 'Qibla';

  @override
  String get qiblaBearing => 'Qibla bearing from true north';

  @override
  String get qiblaNeedsLocation =>
      'The Qibla is computed from your location. Use your device\'s GPS, or set up a masjid first.';

  @override
  String distanceToMakkah(int km) {
    return '$km km to Makkah';
  }

  @override
  String headingDegrees(int degrees) {
    return 'Heading $degrees°';
  }

  @override
  String get facingQibla => 'You are facing the Qibla';

  @override
  String get compassWaiting =>
      'Waiting for the compass… move your phone in a figure of eight to calibrate.';

  @override
  String get compassUnavailable =>
      'No compass on this device: hold a compass or map and turn to the bearing above.';

  @override
  String turnToQibla(String direction, int degrees) {
    return 'Turn $direction by $degrees°';
  }

  @override
  String get left => 'left';

  @override
  String get right => 'right';

  @override
  String get qiblaHelp =>
      'Keep the phone flat and away from magnets or metal. The Kaaba marker on the dial shows the Qibla; the arrow at the top is where you are facing.';

  @override
  String get adhan => 'Adhan';

  @override
  String get adhanIntro =>
      'Listen to the call to prayer from different muezzins, download any recording, and choose the default used for your prayer times.';

  @override
  String get adhanCredits =>
      'Recordings from Wikimedia Commons under CC0 and CC BY-SA 4.0, converted to MP3; tap a credit line to open the original file and its licence.';

  @override
  String downloaded(String name) {
    return 'Downloaded $name';
  }

  @override
  String downloadFailed(String error) {
    return 'Download failed: $error';
  }

  @override
  String get downloadSurahAudio => 'Download surah audio for offline';

  @override
  String get downloadAyahAudio => 'Download this ayah\'s audio (MP3)';

  @override
  String get offlineAudioNativeOnly =>
      'Offline audio is kept in the mobile and desktop apps; on the web, download single ayahs.';

  @override
  String surahAudioSaved(String surah) {
    return '$surah saved for offline listening';
  }

  @override
  String get downloadForOffline => 'Download for offline reading';

  @override
  String savedForOffline(String name) {
    return '$name saved for offline reading';
  }

  @override
  String get playAdhan => 'Play adhan';

  @override
  String adhanForNext(String prayer) {
    return 'Adhan for $prayer';
  }

  @override
  String get chooseAdhan => 'Choose adhan';

  @override
  String get pageAnimation => 'Page animation';

  @override
  String get animationCurl => 'Page curl';

  @override
  String get animationFlip => 'Card flip';

  @override
  String get animationSlide => 'Slide';

  @override
  String get animationFade => 'Fade';

  @override
  String get highlight => 'Highlight';

  @override
  String get removeHighlight => 'Remove highlight';

  @override
  String get note => 'Note';

  @override
  String get noteHint => 'Write your reflection or reminder for this ayah…';

  @override
  String get noteSaved => 'Note saved';

  @override
  String get noteHelp =>
      'Notes stay on this device. Highlighted ayahs are coloured on the Mushaf pages.';

  @override
  String get continuous => 'Auto-continue';

  @override
  String get repeatEach => 'Repeat';

  @override
  String get verseDetails => 'Verse details';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get fitPage => 'Fit to page';

  @override
  String get shareEmbed => 'Share & embed';

  @override
  String get websiteWidget => 'Website widget & TV display';

  @override
  String get widgetLinks => 'Public links';

  @override
  String get embedCode => 'Embed code';

  @override
  String get openLink => 'Open';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get codeCopied => 'Embed code copied';

  @override
  String get combinedWidget => 'Combined widget (daily + Friday)';

  @override
  String get dailyWidget => 'Daily prayer widget';

  @override
  String get jumuahWidget => 'Friday prayer widget';

  @override
  String get compactWidget => 'Compact widget';

  @override
  String get tvDisplay => 'TV display';

  @override
  String get darkWidget => 'Dark widget';

  @override
  String get embedHelp =>
      'Paste the embed code into your masjid website, or share a link. The link itself carries this masjid’s location, method, iqama and Jumu’ah settings, so copy it again after you change them. Add ?theme=dark or &scale=120, &lang=ar to any link.';

  @override
  String get preview => 'Preview';

  @override
  String get adhanHeader => 'Adhan';

  @override
  String get poweredBy => 'Powered by Mushaf+';

  @override
  String get invalidWidgetLink => 'This widget link is invalid or incomplete.';

  @override
  String get micDenied =>
      'Microphone access was denied. Allow it for this site in the browser or system settings, then try again.';

  @override
  String get noSpeechYet =>
      'Nothing heard yet. Recite clearly, close to the microphone. Words appear here as they are recognised.';

  @override
  String get speechNotice => 'Recognition notice';

  @override
  String get speechTip =>
      'Correct words turn green, wrong words red with a buzz and a vibration; keep reciting after a slip and the checker follows you.';

  @override
  String get strictMode => 'Strict';

  @override
  String get lenientMode => 'Lenient';

  @override
  String get strictHelp =>
      'Strict mode: a word counts only when every letter matches. Vowel marks (harakat) and tajweed cannot be checked: speech recognition returns the letters only.';

  @override
  String get tjHamzatWasl => 'Hamzat al-wasl';

  @override
  String get tjSilent => 'Silent letter';

  @override
  String get tjLaamShamsiyyah => 'Sun lam';

  @override
  String get tjMaddNormal => 'Natural madd';

  @override
  String get tjMaddPermissible => 'Permissible madd';

  @override
  String get tjMaddNecessary => 'Necessary madd';

  @override
  String get tjQalqalah => 'Qalqalah';

  @override
  String get tjMaddObligatory => 'Obligatory madd';

  @override
  String get tjIkhfaShafawi => 'Labial ikhfa';

  @override
  String get tjIkhfa => 'Ikhfa';

  @override
  String get tjIdghamShafawi => 'Labial idgham';

  @override
  String get tjIqlab => 'Iqlab';

  @override
  String get tjIdghamGhunnah => 'Idgham with ghunnah';

  @override
  String get tjIdghamNoGhunnah => 'Idgham without ghunnah';

  @override
  String get tjIdghamMutajanisayn => 'Idgham of similar letters';

  @override
  String get tjIdghamMutaqaribayn => 'Idgham of close letters';

  @override
  String get tjGhunnah => 'Ghunnah';

  @override
  String get tjdHamzatWasl =>
      'A connecting hamzah at the start of a word. It is pronounced only when you begin with that word; when joining from the previous word it is silent, so read straight through it.';

  @override
  String get tjdSilent =>
      'A letter written in the mushaf but not pronounced, such as the alif after the plural waw. Skip it in recitation.';

  @override
  String get tjdLaamShamsiyyah =>
      'The lam of the definite article before a sun letter is not pronounced: double the sun letter instead, as in ٱلشَّمْس → ash-shams.';

  @override
  String get tjdMaddNormal =>
      'A natural lengthening: hold the long vowel for two counts, no more and no less.';

  @override
  String get tjdMaddPermissible =>
      'A lengthening where a madd letter meets a hamzah in the next word, or a stop creates a sukun. Hold it two, four or six counts, but stay consistent through the recitation.';

  @override
  String get tjdMaddNecessary =>
      'A lengthening required by an original sukun or a shaddah after the madd letter, including the opening letters of surahs. Hold it six counts.';

  @override
  String get tjdQalqalah =>
      'An echoing bounce on the letters ق ط ب ج د when they carry a sukun. Release the letter with a slight rebound, stronger when stopping on it.';

  @override
  String get tjdMaddObligatory =>
      'A madd letter followed by a hamzah in the same word. Hold it four to five counts.';

  @override
  String get tjdIkhfaShafawi =>
      'A meem with sukun before ب: close the lips lightly and hide the meem with a nasal sound of two counts.';

  @override
  String get tjdIkhfa =>
      'A nun with sukun or tanwin before one of the fifteen ikhfa letters: hide the nun with a nasal sound of two counts, with the tongue ready for the next letter.';

  @override
  String get tjdIdghamShafawi =>
      'A meem with sukun before another meem: merge them into one doubled meem with a nasal sound of two counts.';

  @override
  String get tjdIqlab =>
      'A nun with sukun or tanwin before ب changes into a meem, hidden with a nasal sound of two counts and lightly closed lips.';

  @override
  String get tjdIdghamGhunnah =>
      'A nun with sukun or tanwin before ي ن م و at the start of the next word merges into that letter, with a nasal sound of two counts.';

  @override
  String get tjdIdghamNoGhunnah =>
      'A nun with sukun or tanwin before ل or ر merges completely into that letter, with no nasal sound.';

  @override
  String get tjdIdghamMutajanisayn =>
      'Two letters from the same point of articulation, the first with sukun, merge into one doubled letter, as in قَد تَّبَيَّنَ.';

  @override
  String get tjdIdghamMutaqaribayn =>
      'Two letters from close points of articulation, the first with sukun, merge into the second, as in قُل رَّبِّ.';

  @override
  String get tjdGhunnah =>
      'A nasal resonance held for two counts on a meem or nun with shaddah.';

  @override
  String get tjgMadd => 'Prolongation (madd)';

  @override
  String get tjgNunTanwin => 'Nun sakinah and tanwin';

  @override
  String get tjgMeemSakinah => 'Meem sakinah';

  @override
  String get tjgGhunnah => 'Ghunnah';

  @override
  String get tjgQalqalah => 'Qalqalah';

  @override
  String get tjgLam => 'Lam';

  @override
  String get tjgSilent => 'Silent letters';

  @override
  String get tjgIdghamAdjacent => 'Merging of adjacent letters';

  @override
  String get tajweed => 'Tajweed';

  @override
  String get tajweedColors => 'Tajweed colours';

  @override
  String get tajweedColorsSubtitle =>
      'Colour the letters of the Mushaf and reader by tajweed rule';

  @override
  String get tajweedGuide => 'Tajweed guide';

  @override
  String get tajweedLegend => 'Tajweed colour legend';

  @override
  String get seeGuide => 'Full guide';

  @override
  String get tajweedIntro =>
      'Tajweed is reciting each letter from its place of articulation with its proper qualities: lengthening where there is madd, nasal sound where there is ghunnah, hiding, merging and bouncing where the rules call for it. The Mushaf colours every letter that carries a rule; tap any word to see which rules apply to it and how to recite it. Rules follow riwayat Hafs an Asim.';

  @override
  String get rulesInThisWord => 'Tajweed in this word';

  @override
  String get noRulesInWord =>
      'No tajweed rule is marked on this word: recite its letters plainly from their places of articulation.';

  @override
  String get wordTab => 'Word';

  @override
  String wordOfN(int n, int total) {
    return 'Word $n of $total';
  }

  @override
  String get playWord => 'Play word';

  @override
  String get example => 'Example';

  @override
  String get triggerLetters => 'Letters';

  @override
  String countsValue(String n) {
    return '$n counts';
  }

  @override
  String tuhfaRef(String lines) {
    return 'Tuhfat al-Atfal, lines $lines';
  }

  @override
  String jazariyyahRef(String lines) {
    return 'al-Jazariyyah, lines $lines';
  }

  @override
  String get tajweedSource =>
      'Rules and colouring follow the alquran.cloud tajweed guide (riwayat Hafs, Tanzil Uthmani text) and the KFGQPC colour scheme used by quran.com. Line references point to Tuhfat al-Atfal and al-Muqaddimah al-Jazariyyah.';

  @override
  String get fullScreen => 'Full screen';

  @override
  String get exitFullScreen => 'Exit full screen';

  @override
  String get playbackSpeed => 'Speed';

  @override
  String get chooseReciter => 'Choose a reciter';

  @override
  String get approximateLocation =>
      'Only the area (postal code or city) was found, so the coordinates are its centre. If you know the exact coordinates, enter them below.';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String pdfReady(String size) {
    return 'PDF ready ($size)';
  }

  @override
  String get openPdf => 'Open';

  @override
  String get savePdf => 'Save';

  @override
  String get offlineSavedBody =>
      'The book is stored on this device in the current hadith language and opens without internet from the library. Download it again after switching language.';

  @override
  String get adhkar => 'Adhkar';

  @override
  String get hisnAlMuslim => 'Hisn al-Muslim';

  @override
  String get hisnAlMuslimSubtitle =>
      'Fortress of the Muslim · supplications from the Quran and Sunnah';

  @override
  String get adhkarIntro =>
      'Daily remembrances and supplications from Hisn al-Muslim by Sa‘id al-Qahtani, with repeat counters and audio.';

  @override
  String repeatProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get playChapter => 'Play chapter';

  @override
  String get resetCounters => 'Reset counters';

  @override
  String get adhkarLanguageNote =>
      'Translations come from hisnmuslim.com and exist in English and Arabic only.';

  @override
  String get findAdhkar => 'Find a chapter…';

  @override
  String get morning => 'Morning';

  @override
  String get evening => 'Evening';

  @override
  String get sleep => 'Sleep';

  @override
  String get afterPrayer => 'After prayer';

  @override
  String get allDone => 'All done';

  @override
  String timesN(int n) {
    return '×$n';
  }

  @override
  String get readAloud => 'Read aloud';

  @override
  String get stopReading => 'Stop reading';

  @override
  String get ttsUnavailable =>
      'No voice for this language is installed on this device. Hadith are read with the device’s text-to-speech voices.';

  @override
  String get homeSearchHint =>
      'Search the Quran — a surah, an ayah, a word or a phrase. Arabic with or without harakat, transliteration (insan, bismillah), English meaning, or a surah name or number…';

  @override
  String get countryLabel => 'Country';

  @override
  String get region => 'Region';

  @override
  String get changeRegion => 'tap to change';

  @override
  String get detectRegion => 'Detect';

  @override
  String get regionHelp =>
      'Pre-fills the country for masjids and picks the usual prayer calculation for that country.';

  @override
  String regionSetTo(String name) {
    return 'Region set to $name. Tap the flag to change it.';
  }

  @override
  String get regionNotDetected =>
      'Could not detect your country. Choose it from the list.';

  @override
  String get findCountry => 'Find a country…';

  @override
  String get myPrayerTimes => 'My prayer times';

  @override
  String get masjidsTab => 'Masjids';

  @override
  String get enterMyCity => 'Enter my city';

  @override
  String get orEnterCity => 'or enter your city';

  @override
  String get editLocation => 'Edit location';

  @override
  String get personalIntro =>
      'Prayer times for where you are: allow your precise location, or type your city. The calculation method follows your country and can be changed.';

  @override
  String get masjidAdminHint =>
      'Masjid administrators: set up the masjid itself, with iqama and Jumu’ah times and website widgets, under the Masjids tab after creating a profile.';

  @override
  String get masjidAdminGate =>
      'Masjid profiles carry iqama times, Jumu’ah services and public widgets, so they are tied to a named administrator. Create your profile (name and email, kept on this device) to set one up.';

  @override
  String get createProfile => 'Create profile';

  @override
  String get profile => 'Profile';

  @override
  String get profileIntro =>
      'Your name and email identify you as the administrator of the masjids you set up. They stay on this device.';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get masjidRole => 'Role at the masjid (optional)';

  @override
  String get masjidRoleHint => 'Imam, board member, volunteer…';

  @override
  String get removeProfile => 'Remove profile';

  @override
  String get reminders => 'Reminders';

  @override
  String get remindersOn => 'On · tap to adjust';

  @override
  String get remindersOff => 'Off · prayer times, adhkar, daily ayah';

  @override
  String get remindersSettingsSubtitle =>
      'Prayer times with adhan, morning and evening adhkar, daily ayah or dhikr';

  @override
  String get prayerReminders => 'Prayer time reminders';

  @override
  String prayerRemindersSubtitle(String adhan) {
    return 'Each prayer; opening the reminder plays $adhan';
  }

  @override
  String get remindBefore => 'Remind';

  @override
  String get atPrayerTime => 'At prayer time';

  @override
  String minutesBefore(int n) {
    return '$n min before';
  }

  @override
  String get adhkarReminders => 'Adhkar reminders';

  @override
  String get adhkarRemindersSubtitle =>
      'Morning adhkar after Fajr, evening adhkar after Asr, sleep adhkar one hour after Isha';

  @override
  String get dailyReminder => 'Ayah or dhikr of the day';

  @override
  String get dailyReminderSubtitle => 'A random ayah or dhikr once a day';

  @override
  String get reminderTime => 'Time';

  @override
  String get nextReminders => 'Upcoming';

  @override
  String get notificationsWebNote =>
      'In a browser, reminders appear only while Mushaf+ is open in a tab. Install the Android or iOS app for reminders that work with the app closed.';

  @override
  String get notificationsDenied =>
      'Notifications are blocked for Mushaf+ in the system settings.';

  @override
  String get setLocationFirst => 'Set your prayer location first';

  @override
  String get adhanOnNotification =>
      'Prayer reminders use the system sound; opening one plays your chosen adhan in full.';

  @override
  String prayerInMinutes(String prayer, int n) {
    return '$prayer in $n minutes';
  }

  @override
  String timeForPrayer(String prayer) {
    return 'Time for $prayer';
  }

  @override
  String get timeAdhkarMorning => 'Morning adhkar';

  @override
  String get timeAdhkarEvening => 'Evening adhkar';

  @override
  String get timeAdhkarSleep => 'Sleep adhkar';

  @override
  String get adhkarMorningBody =>
      'Start the day with the morning remembrances.';

  @override
  String get adhkarEveningBody => 'The evening remembrances, before the night.';

  @override
  String get adhkarSleepBody => 'The remembrances before sleep.';

  @override
  String get ayahOfTheDayNotif => 'Ayah of the day';

  @override
  String get dhikrOfTheDay => 'Dhikr of the day';

  @override
  String get memorizeCard => 'Memorize & recite';

  @override
  String get memorizeCardSubtitle =>
      'Hide the words, reveal them one by one, then recite and let the app check you.';

  @override
  String get town => 'Town / City';

  @override
  String get suburb => 'Suburb';

  @override
  String get province => 'Province';

  @override
  String get zip => 'ZIP code';

  @override
  String get postcode => 'Postcode';

  @override
  String get regionOptional => 'Region (optional)';

  @override
  String get postalOptional => 'Postal code (optional)';

  @override
  String get bundledAlways =>
      'The Quran text, tajweed colours, transliteration, three English translations, the hadith index and Hisn al-Muslim are built in and always work offline.';

  @override
  String get downloadTextPacks => 'Download all text packs';

  @override
  String get textPacks => 'Text';

  @override
  String get audioPacks => 'Audio';

  @override
  String tafsirPack(String name) {
    return 'Tafsir · $name';
  }

  @override
  String hadithPack(String lang) {
    return 'Hadith books ($lang)';
  }

  @override
  String chaptersSaved(int done, int total) {
    return '$done / $total chapters saved';
  }

  @override
  String get adhanPack => 'Adhan recordings';

  @override
  String get adhkarAudioPack => 'Hisn al-Muslim audio';

  @override
  String reciterPack(String name) {
    return 'Full recitation · $name';
  }

  @override
  String filesSaved(int done, int total) {
    return '$done / $total files saved';
  }

  @override
  String approxSize(String size) {
    return 'about $size';
  }

  @override
  String get offlinePromptTitle => 'Use Mushaf+ offline?';

  @override
  String get offlinePromptBody =>
      'Download translations, word meanings, tafsir and the hadith books now (about 60 MB) so everything works without a connection. Audio packs can be added later under Settings → Offline packs.';

  @override
  String get downloadNow => 'Download now';

  @override
  String get later => 'Later';

  @override
  String get offlineAutoTitle => 'Mushaf+ works fully offline';

  @override
  String get offlineAutoBody =>
      'The app will now download everything it needs so it works with no connection: translations, word meanings, tafsir, the hadith books, the adhan recordings and the Hisn al-Muslim audio (about 200 MB). It runs in the background; you can keep reading. Wi-Fi is recommended.';

  @override
  String includeFullRecitation(String name) {
    return 'Full recitation by $name';
  }

  @override
  String get includeFullRecitationHint =>
      'About 700 MB. You can also add it later under Settings → Offline packs.';

  @override
  String get continueLabel => 'Continue';

  @override
  String offlineSyncing(int percent) {
    return 'Downloading for offline use · $percent%';
  }

  @override
  String get offlineAutoIntro =>
      'Mushaf+ downloads everything it needs in the background so it works with no connection. Each pack below shows what is stored; tap one to fetch what is missing.';

  @override
  String get resumeOfflineDownload => 'Download everything missing';

  @override
  String get wifiOnly => 'Audio on Wi-Fi only';

  @override
  String get wifiOnlyHint =>
      'On cellular data only the small text packs download by themselves.';

  @override
  String get waitingForWifi =>
      'Text packs are saved. Audio packs will download when you are on Wi-Fi (or tap the button above to download now).';

  @override
  String get watchNoPlace => 'Set a prayer location to see prayer times.';

  @override
  String inDuration(String duration) {
    return 'in $duration';
  }

  @override
  String get tasbih => 'Tasbih';

  @override
  String get tapToCount => 'Tap to count, hold to reset';

  @override
  String get useLocationShort => 'Use my location';

  @override
  String get supportTitle => 'Support Mushaf+';

  @override
  String get supportSubtitle =>
      'A voluntary contribution keeps the app free, open and ad-free.';

  @override
  String get supportIntro =>
      'Mushaf+ is free, has no ads and never will. If it helps you, a voluntary contribution covers the servers, audio hosting and store fees and lets us keep building.';

  @override
  String get tipJarIntro =>
      'Choose a tip. It unlocks nothing: everything in Mushaf+ stays free for everyone.';

  @override
  String get tipThanks =>
      'JazakAllahu khairan. Thank you for supporting Mushaf+!';

  @override
  String get tipUnavailable =>
      'Tips are not available right now. Please try again later.';

  @override
  String get donateIntro => 'Choose how you would like to contribute.';

  @override
  String get donateComingSoon =>
      'Donation options are being set up. Thank you for your patience, and for using Mushaf+.';

  @override
  String get bankTransfer => 'Bank transfer';

  @override
  String get copied => 'Copied';

  @override
  String get supportFootnote =>
      'Contributions are voluntary gifts to the developer, not purchases, and are not tax-deductible.';

  @override
  String get recognitionEngine => 'Recognition engine';

  @override
  String get engineBrowser => 'Browser';

  @override
  String get engineBrowserDesc => 'Fast, letters only';

  @override
  String get engineVoiceModel => 'Mushaf+ voice model';

  @override
  String get engineVoiceModelDesc =>
      '150 MB one-time download, marks vowel mistakes';

  @override
  String get engineVoiceModelHelp =>
      'The Mushaf+ voice model downloads about 150 MB once, then runs on this device inside the browser. It checks vowel marks (harakat) as well as letters. Needs a recent Chrome, Edge or Safari.';

  @override
  String get voiceModelDownloadTitle => 'Download the Mushaf+ voice model?';

  @override
  String voiceModelDownloadBody(int size) {
    return 'About $size MB, downloaded once and kept on this device. Recognition then runs in your browser and nothing you recite leaves your device.';
  }

  @override
  String voiceModelDownloading(int done, int total) {
    return 'Downloading the voice model… $done of $total MB';
  }

  @override
  String get voiceModelPreparing => 'Preparing the voice model…';

  @override
  String get voiceModelFailed => 'The voice model could not be loaded.';

  @override
  String get voiceModelSlow =>
      'No graphics acceleration in this browser: results may lag by several seconds.';

  @override
  String get usingBrowserEngine => 'Using the browser engine for now.';

  @override
  String get vowelSlips => 'vowel slips';

  @override
  String get letterErrors => 'letter errors';

  @override
  String reciteSummary(int correct, int vowel, int letter) {
    return '$correct correct · $vowel vowel slips · $letter letter errors';
  }

  @override
  String get feedbackDisclaimer =>
      'Automatic feedback can be wrong; it does not replace a teacher.';

  @override
  String vowelSlipLine(String heard, String letter, String expected) {
    return 'Heard $heard on $letter, expected $expected';
  }

  @override
  String get wordCorrect => 'Correct';

  @override
  String get wordVowelSlip => 'Vowel slip';

  @override
  String get wordWrong => 'Wrong word';

  @override
  String get wordMissed => 'Skipped';

  @override
  String get wordPending => 'Not reached yet';

  @override
  String get markFatha => 'fatha';

  @override
  String get markDamma => 'damma';

  @override
  String get markKasra => 'kasra';

  @override
  String get markSukun => 'sukun';

  @override
  String get markShadda => 'shadda';

  @override
  String get markFathatan => 'fathatan';

  @override
  String get markDammatan => 'dammatan';

  @override
  String get markKasratan => 'kasratan';

  @override
  String get markNone => 'no mark';

  @override
  String get markNoShadda => 'no shadda';

  @override
  String get voiceModelHelp =>
      'The Mushaf+ voice model also checks vowel marks (harakat): a vowel slip shows in amber. Tap any word for details.';

  @override
  String get playRecitation => 'Play recitation';

  @override
  String get addressLookupCredit =>
      'Address lookup: © OpenStreetMap contributors (ODbL), Open-Meteo geocoding (CC BY 4.0), Zippopotam.';

  @override
  String get dataSourcesLicences => 'Data sources & licences';

  @override
  String get dataSourcesLicencesHint =>
      'Where the texts, audio and maps come from, and their terms';

  @override
  String get openSourceLicences => 'Open-source licences';

  @override
  String recordingCredit(String author, String license) {
    return 'Recording: $author · $license · Wikimedia Commons';
  }
}
