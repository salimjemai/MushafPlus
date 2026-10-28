import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('id'),
    Locale('tr'),
    Locale('ur')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mushaf+'**
  String get appTitle;

  /// No description provided for @navRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get navRead;

  /// No description provided for @navHadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get navHadith;

  /// No description provided for @navPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get navPrayer;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchTheQuran.
  ///
  /// In en, this message translates to:
  /// **'Search the Quran'**
  String get searchTheQuran;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @couldNotLoadQuran.
  ///
  /// In en, this message translates to:
  /// **'Could not load the Quran data.'**
  String get couldNotLoadQuran;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE READING'**
  String get continueReading;

  /// No description provided for @startReading.
  ///
  /// In en, this message translates to:
  /// **'START READING'**
  String get startReading;

  /// No description provided for @ayahOfJuzPage.
  ///
  /// In en, this message translates to:
  /// **'Ayah {ayah} of {total} · Juz {juz} · Page {page}'**
  String ayahOfJuzPage(int ayah, int total, int juz, int page);

  /// No description provided for @verseOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'VERSE OF THE DAY'**
  String get verseOfTheDay;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @dailyGoalTapToStartPlan.
  ///
  /// In en, this message translates to:
  /// **'Daily goal {goal} ayahs · tap to start a khatm plan'**
  String dailyGoalTapToStartPlan(int goal);

  /// No description provided for @khatmOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Khatm plan: on track · day {day}/{days}'**
  String khatmOnTrack(int day, int days);

  /// No description provided for @khatmBehind.
  ///
  /// In en, this message translates to:
  /// **'Khatm plan: {behind} ayahs behind · day {day}/{days}'**
  String khatmBehind(int behind, int day, int days);

  /// No description provided for @findSurahHint.
  ///
  /// In en, this message translates to:
  /// **'Find a surah by name, meaning or number'**
  String get findSurahHint;

  /// No description provided for @tabSurah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get tabSurah;

  /// No description provided for @tabJuz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get tabJuz;

  /// No description provided for @tabPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get tabPage;

  /// No description provided for @noSurahMatches.
  ///
  /// In en, this message translates to:
  /// **'No surah matches your search.'**
  String get noSurahMatches;

  /// No description provided for @surahSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{meaning} · {count} ayahs · {type}'**
  String surahSubtitle(String meaning, int count, String type);

  /// No description provided for @meccan.
  ///
  /// In en, this message translates to:
  /// **'Meccan'**
  String get meccan;

  /// No description provided for @medinan.
  ///
  /// In en, this message translates to:
  /// **'Medinan'**
  String get medinan;

  /// No description provided for @juzN.
  ///
  /// In en, this message translates to:
  /// **'Juz {n}'**
  String juzN(int n);

  /// No description provided for @juzStartsAt.
  ///
  /// In en, this message translates to:
  /// **'Starts at {surah}, ayah {ayah} · {count} ayahs'**
  String juzStartsAt(String surah, int ayah, int count);

  /// No description provided for @jumpToSurah.
  ///
  /// In en, this message translates to:
  /// **'Jump to surah'**
  String get jumpToSurah;

  /// No description provided for @pageN.
  ///
  /// In en, this message translates to:
  /// **'Page {n}'**
  String pageN(int n);

  /// No description provided for @backToSurahs.
  ///
  /// In en, this message translates to:
  /// **'Back to surahs'**
  String get backToSurahs;

  /// No description provided for @openMushafHere.
  ///
  /// In en, this message translates to:
  /// **'Open the Mushaf book at this surah'**
  String get openMushafHere;

  /// No description provided for @translations.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get translations;

  /// No description provided for @readingSettings.
  ///
  /// In en, this message translates to:
  /// **'Reading settings'**
  String get readingSettings;

  /// No description provided for @playSurah.
  ///
  /// In en, this message translates to:
  /// **'Play surah'**
  String get playSurah;

  /// No description provided for @pauseRecitation.
  ///
  /// In en, this message translates to:
  /// **'Pause recitation'**
  String get pauseRecitation;

  /// No description provided for @memorizeThisSurah.
  ///
  /// In en, this message translates to:
  /// **'Memorize this surah'**
  String get memorizeThisSurah;

  /// No description provided for @openInMushaf.
  ///
  /// In en, this message translates to:
  /// **'Open in Mushaf book'**
  String get openInMushaf;

  /// No description provided for @juzPage.
  ///
  /// In en, this message translates to:
  /// **'Juz {juz} · Page {page}'**
  String juzPage(int juz, int page);

  /// No description provided for @wordByWord.
  ///
  /// In en, this message translates to:
  /// **'Word by word'**
  String get wordByWord;

  /// No description provided for @tafsir.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get tafsir;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// No description provided for @bookmarkThisAyah.
  ///
  /// In en, this message translates to:
  /// **'Bookmark this ayah'**
  String get bookmarkThisAyah;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @playFromThisAyah.
  ///
  /// In en, this message translates to:
  /// **'Play from this ayah'**
  String get playFromThisAyah;

  /// No description provided for @sajdahAyah.
  ///
  /// In en, this message translates to:
  /// **'Sajdah (prostration) ayah'**
  String get sajdahAyah;

  /// No description provided for @couldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load {name}'**
  String couldNotLoad(String name);

  /// No description provided for @wordByWordOffline.
  ///
  /// In en, this message translates to:
  /// **'Word-by-word unavailable offline ({error})'**
  String wordByWordOffline(String error);

  /// No description provided for @ayahN.
  ///
  /// In en, this message translates to:
  /// **'Ayah {n}'**
  String ayahN(int n);

  /// No description provided for @wordByWordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transliteration and meaning of every word'**
  String get wordByWordSubtitle;

  /// No description provided for @tafsirSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Commentary from Ibn Kathir and others'**
  String get tafsirSubtitle;

  /// No description provided for @playRecitationFromHere.
  ///
  /// In en, this message translates to:
  /// **'Play recitation from here'**
  String get playRecitationFromHere;

  /// No description provided for @memorizeFromHere.
  ///
  /// In en, this message translates to:
  /// **'Memorize from here'**
  String get memorizeFromHere;

  /// No description provided for @memorizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide words, reveal one by one, loop the recitation'**
  String get memorizeSubtitle;

  /// No description provided for @ayahCopied.
  ///
  /// In en, this message translates to:
  /// **'Ayah copied'**
  String get ayahCopied;

  /// No description provided for @wordN.
  ///
  /// In en, this message translates to:
  /// **'Word {n}'**
  String wordN(int n);

  /// No description provided for @wordByWordNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Word-by-word data needs an internet connection the first time.'**
  String get wordByWordNeedsInternet;

  /// No description provided for @tafsirNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'Tafsir needs an internet connection the first time.'**
  String get tafsirNeedsInternet;

  /// No description provided for @viaQuranCom.
  ///
  /// In en, this message translates to:
  /// **'via Quran.com'**
  String get viaQuranCom;

  /// No description provided for @reciter.
  ///
  /// In en, this message translates to:
  /// **'Reciter'**
  String get reciter;

  /// No description provided for @arabicSize.
  ///
  /// In en, this message translates to:
  /// **'Arabic size'**
  String get arabicSize;

  /// No description provided for @translationSize.
  ///
  /// In en, this message translates to:
  /// **'Translation size'**
  String get translationSize;

  /// No description provided for @amiriQuran.
  ///
  /// In en, this message translates to:
  /// **'Amiri Quran'**
  String get amiriQuran;

  /// No description provided for @amiriNaskh.
  ///
  /// In en, this message translates to:
  /// **'Amiri Naskh'**
  String get amiriNaskh;

  /// No description provided for @showTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Show transliteration'**
  String get showTransliteration;

  /// No description provided for @showTransliterationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Latin-script pronunciation under each ayah'**
  String get showTransliterationSubtitle;

  /// No description provided for @wordByWordMode.
  ///
  /// In en, this message translates to:
  /// **'Word-by-word mode'**
  String get wordByWordMode;

  /// No description provided for @wordByWordModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every word with its transliteration and meaning'**
  String get wordByWordModeSubtitle;

  /// No description provided for @wordMeaningsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Word meanings language'**
  String get wordMeaningsLanguage;

  /// No description provided for @tapAyahHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any ayah for translation, transliteration, tafsir and word-by-word.'**
  String get tapAyahHint;

  /// No description provided for @previousAyah.
  ///
  /// In en, this message translates to:
  /// **'Previous ayah'**
  String get previousAyah;

  /// No description provided for @nextAyah.
  ///
  /// In en, this message translates to:
  /// **'Next ayah'**
  String get nextAyah;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @loop.
  ///
  /// In en, this message translates to:
  /// **'loop'**
  String get loop;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Arabic, transliteration or English…'**
  String get searchHint;

  /// No description provided for @searchWholeQuran.
  ///
  /// In en, this message translates to:
  /// **'Search the whole Quran'**
  String get searchWholeQuran;

  /// No description provided for @searchHelp.
  ///
  /// In en, this message translates to:
  /// **'Type Arabic (with or without harakat), a transliterated phrase, or an English word. Results open the ayah in the reader.'**
  String get searchHelp;

  /// No description provided for @noAyahMatches.
  ///
  /// In en, this message translates to:
  /// **'No ayah matches \"{query}\"'**
  String noAyahMatches(String query);

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCount(String count);

  /// No description provided for @savedAyahs.
  ///
  /// In en, this message translates to:
  /// **'Saved ayahs'**
  String get savedAyahs;

  /// No description provided for @noBookmarksYet.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get noBookmarksYet;

  /// No description provided for @noBookmarksHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark icon on any ayah while reading to save it here.'**
  String get noBookmarksHelp;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @arabicFont.
  ///
  /// In en, this message translates to:
  /// **'Arabic font'**
  String get arabicFont;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @recitation.
  ///
  /// In en, this message translates to:
  /// **'Recitation'**
  String get recitation;

  /// No description provided for @recitationHelp.
  ///
  /// In en, this message translates to:
  /// **'Audio streams verse by verse from everyayah.com. Tap play on any ayah, or \"Play surah\" in the surah header.'**
  String get recitationHelp;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @wordByWordSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show each word with its transliteration and meaning (downloads once per surah)'**
  String get wordByWordSettingSubtitle;

  /// No description provided for @defaultView.
  ///
  /// In en, this message translates to:
  /// **'Default view'**
  String get defaultView;

  /// No description provided for @viewTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get viewTranslation;

  /// No description provided for @viewMushafBook.
  ///
  /// In en, this message translates to:
  /// **'Mushaf book'**
  String get viewMushafBook;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @arabicOnlyTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Arabic only — tap to add translations'**
  String get arabicOnlyTapToAdd;

  /// No description provided for @translationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} translations in {languages} languages are available. Each one is downloaded the first time you open a surah and kept offline.'**
  String translationsAvailable(int count, int languages);

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @offlinePacks.
  ///
  /// In en, this message translates to:
  /// **'Offline packs'**
  String get offlinePacks;

  /// No description provided for @offlinePacksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download translations and word-by-word for the whole Quran'**
  String get offlinePacksSubtitle;

  /// No description provided for @clearDownloadedData.
  ///
  /// In en, this message translates to:
  /// **'Clear downloaded data'**
  String get clearDownloadedData;

  /// No description provided for @cachedDownloads.
  ///
  /// In en, this message translates to:
  /// **'{count} cached surah downloads'**
  String cachedDownloads(int count);

  /// No description provided for @clearDownloadedDataQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear downloaded data?'**
  String get clearDownloadedDataQuestion;

  /// No description provided for @clearDownloadedDataBody.
  ///
  /// In en, this message translates to:
  /// **'Translations and word-by-word data will be downloaded again when needed. Bookmarks and settings are kept.'**
  String get clearDownloadedDataBody;

  /// No description provided for @downloadedDataCleared.
  ///
  /// In en, this message translates to:
  /// **'Downloaded data cleared'**
  String get downloadedDataCleared;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @versionBuiltWith.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 · Built with Flutter'**
  String get versionBuiltWith;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Arabic text: Tanzil Uthmani edition. Translations and transliteration: Al Quran Cloud. Word-by-word and tafsir: Quran.com. Recitation: EveryAyah.com. Hadith: fawazahmed0/hadith-api. Fonts: Amiri & Amiri Quran (SIL Open Font License). Voice model: derived from tarteel-ai/whisper-base-ar-quran (Apache-2.0, fine-tuned from OpenAI Whisper), run on-device with transformers.js and ONNX Runtime (Apache-2.0).'**
  String get credits;

  /// No description provided for @selectedOfMax.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {max} selected'**
  String selectedOfMax(int selected, int max);

  /// No description provided for @searchLanguageOrTranslator.
  ///
  /// In en, this message translates to:
  /// **'Search a language or translator'**
  String get searchLanguageOrTranslator;

  /// No description provided for @nTranslations.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 translation} other{{count} translations}}'**
  String nTranslations(int count);

  /// No description provided for @nSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String nSelected(int count);

  /// No description provided for @rightToLeftScript.
  ///
  /// In en, this message translates to:
  /// **'Right-to-left script'**
  String get rightToLeftScript;

  /// No description provided for @translationLimit.
  ///
  /// In en, this message translates to:
  /// **'You can show up to {max} translations at once. Remove one first.'**
  String translationLimit(int max);

  /// No description provided for @offlineIntro.
  ///
  /// In en, this message translates to:
  /// **'The Arabic text, English transliteration and three English translations are always offline. Download the rest once and read anywhere.'**
  String get offlineIntro;

  /// No description provided for @selectedTranslations.
  ///
  /// In en, this message translates to:
  /// **'Selected translations'**
  String get selectedTranslations;

  /// No description provided for @allSelectedBundled.
  ///
  /// In en, this message translates to:
  /// **'All selected translations are bundled with the app.'**
  String get allSelectedBundled;

  /// No description provided for @surahDownloadsSaved.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} surah downloads saved'**
  String surahDownloadsSaved(int done, int total);

  /// No description provided for @wordByWordPack.
  ///
  /// In en, this message translates to:
  /// **'Word by word ({language})'**
  String wordByWordPack(String language);

  /// No description provided for @surahsSavedSize.
  ///
  /// In en, this message translates to:
  /// **'{done} of 114 surahs saved · about 8 MB'**
  String surahsSavedSize(int done);

  /// No description provided for @tafsirSavedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Tafsir is saved automatically for every ayah you open.'**
  String get tafsirSavedAutomatically;

  /// No description provided for @downloadEverything.
  ///
  /// In en, this message translates to:
  /// **'Download everything selected'**
  String get downloadEverything;

  /// No description provided for @bundledEditions.
  ///
  /// In en, this message translates to:
  /// **'Bundled editions: {names}.'**
  String bundledEditions(String names);

  /// No description provided for @everythingOffline.
  ///
  /// In en, this message translates to:
  /// **'Everything selected is already available offline.'**
  String get everythingOffline;

  /// No description provided for @downloadDone.
  ///
  /// In en, this message translates to:
  /// **'Done. {count} downloads saved for offline use.'**
  String downloadDone(int count);

  /// No description provided for @downloadDoneWithFailures.
  ///
  /// In en, this message translates to:
  /// **'Done with {failed} failed downloads (check your connection and run again).'**
  String downloadDoneWithFailures(int failed);

  /// No description provided for @downloadCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled after {done} of {total}.'**
  String downloadCancelled(int done, int total);

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get starting;

  /// No description provided for @memorize.
  ///
  /// In en, this message translates to:
  /// **'Memorize'**
  String get memorize;

  /// No description provided for @memorizeHeader.
  ///
  /// In en, this message translates to:
  /// **'{surah} · Ayahs {from}–{to} · {done}/{total} memorized'**
  String memorizeHeader(String surah, int from, int to, int done, int total);

  /// No description provided for @changeRange.
  ///
  /// In en, this message translates to:
  /// **'Change range'**
  String get changeRange;

  /// No description provided for @wordsRevealed.
  ///
  /// In en, this message translates to:
  /// **'{revealed} / {total} words'**
  String wordsRevealed(int revealed, int total);

  /// No description provided for @nextWord.
  ///
  /// In en, this message translates to:
  /// **'Next word'**
  String get nextWord;

  /// No description provided for @revealAll.
  ///
  /// In en, this message translates to:
  /// **'Reveal all'**
  String get revealAll;

  /// No description provided for @hideAll.
  ///
  /// In en, this message translates to:
  /// **'Hide all'**
  String get hideAll;

  /// No description provided for @transliteration.
  ///
  /// In en, this message translates to:
  /// **'Transliteration'**
  String get transliteration;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @memorized.
  ///
  /// In en, this message translates to:
  /// **'Memorized'**
  String get memorized;

  /// No description provided for @markAsMemorized.
  ///
  /// In en, this message translates to:
  /// **'Mark as memorized'**
  String get markAsMemorized;

  /// No description provided for @listenAndRepeat.
  ///
  /// In en, this message translates to:
  /// **'Listen & repeat'**
  String get listenAndRepeat;

  /// No description provided for @repeatEachAyah.
  ///
  /// In en, this message translates to:
  /// **'Repeat each ayah'**
  String get repeatEachAyah;

  /// No description provided for @loopTheRange.
  ///
  /// In en, this message translates to:
  /// **'Loop the range'**
  String get loopTheRange;

  /// No description provided for @playRange.
  ///
  /// In en, this message translates to:
  /// **'Play {from}–{to}'**
  String playRange(int from, int to);

  /// No description provided for @thisAyah.
  ///
  /// In en, this message translates to:
  /// **'This ayah'**
  String get thisAyah;

  /// No description provided for @ayahRange.
  ///
  /// In en, this message translates to:
  /// **'Ayah range'**
  String get ayahRange;

  /// No description provided for @fromToOf.
  ///
  /// In en, this message translates to:
  /// **'From {from} to {to} of {total}'**
  String fromToOf(int from, int to, int total);

  /// No description provided for @readingPlan.
  ///
  /// In en, this message translates to:
  /// **'Reading plan'**
  String get readingPlan;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached, mashaAllah!'**
  String get goalReached;

  /// No description provided for @moreAyahsToGoal.
  ///
  /// In en, this message translates to:
  /// **'{count} more ayahs to reach your goal'**
  String moreAyahsToGoal(int count);

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak'**
  String dayStreak(int days);

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoal;

  /// No description provided for @ayahsPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs per day'**
  String ayahsPerDay(int count);

  /// No description provided for @khatmIn30Days.
  ///
  /// In en, this message translates to:
  /// **'208 (khatm in 30 days)'**
  String get khatmIn30Days;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @ayahsRead.
  ///
  /// In en, this message translates to:
  /// **'Ayahs read'**
  String get ayahsRead;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDays;

  /// No description provided for @quranRead.
  ///
  /// In en, this message translates to:
  /// **'Quran read'**
  String get quranRead;

  /// No description provided for @khatmPlan.
  ///
  /// In en, this message translates to:
  /// **'Khatm plan'**
  String get khatmPlan;

  /// No description provided for @khatmPlanHelp.
  ///
  /// In en, this message translates to:
  /// **'Finish the whole Quran on a schedule. We will tell you the ayah to reach each day.'**
  String get khatmPlanHelp;

  /// No description provided for @nDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String nDays(int n);

  /// No description provided for @startFromFatiha.
  ///
  /// In en, this message translates to:
  /// **'Start from Al-Fatiha'**
  String get startFromFatiha;

  /// No description provided for @fromTheBeginning.
  ///
  /// In en, this message translates to:
  /// **'From the beginning'**
  String get fromTheBeginning;

  /// No description provided for @fromWhereYouAre.
  ///
  /// In en, this message translates to:
  /// **'From where you are now'**
  String get fromWhereYouAre;

  /// No description provided for @aboutAyahsADay.
  ///
  /// In en, this message translates to:
  /// **'About {count} ayahs a day'**
  String aboutAyahsADay(int count);

  /// No description provided for @startPlan.
  ///
  /// In en, this message translates to:
  /// **'Start plan'**
  String get startPlan;

  /// No description provided for @endPlan.
  ///
  /// In en, this message translates to:
  /// **'End plan'**
  String get endPlan;

  /// No description provided for @planStatusLine.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {days} · ends {date} · {perDay} ayahs/day'**
  String planStatusLine(int day, int days, String date, int perDay);

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'You are on track.'**
  String get onTrack;

  /// No description provided for @onTrackAhead.
  ///
  /// In en, this message translates to:
  /// **'You are on track, {count} ayahs ahead.'**
  String onTrackAhead(int count);

  /// No description provided for @catchUp.
  ///
  /// In en, this message translates to:
  /// **'Read {count} more ayahs today to catch up.'**
  String catchUp(int count);

  /// No description provided for @todaysTarget.
  ///
  /// In en, this message translates to:
  /// **'Today\'s target: {surah} {key}'**
  String todaysTarget(String surah, String key);

  /// No description provided for @continueReadingButton.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get continueReadingButton;

  /// No description provided for @hadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get hadith;

  /// No description provided for @hadithIntro.
  ///
  /// In en, this message translates to:
  /// **'The six canonical collections, Muwatta Malik and three forty-hadith collections, with Arabic and translation. Each chapter downloads once and stays offline.'**
  String get hadithIntro;

  /// No description provided for @hadithsChapters.
  ///
  /// In en, this message translates to:
  /// **'{hadiths} hadiths · {chapters} chapters'**
  String hadithsChapters(int hadiths, int chapters);

  /// No description provided for @couldNotLoadHadithBooks.
  ///
  /// In en, this message translates to:
  /// **'Could not load hadith books: {error}'**
  String couldNotLoadHadithBooks(String error);

  /// No description provided for @findAChapter.
  ///
  /// In en, this message translates to:
  /// **'Find a chapter'**
  String get findAChapter;

  /// No description provided for @hadithsRange.
  ///
  /// In en, this message translates to:
  /// **'Hadiths {first}–{last}'**
  String hadithsRange(int first, int last);

  /// No description provided for @chapterN.
  ///
  /// In en, this message translates to:
  /// **'Chapter {n}'**
  String chapterN(int n);

  /// No description provided for @chapterNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'This chapter needs an internet connection the first time.'**
  String get chapterNeedsInternet;

  /// No description provided for @searchHadithsInChapter.
  ///
  /// In en, this message translates to:
  /// **'Search {count} hadiths in this chapter'**
  String searchHadithsInChapter(int count);

  /// No description provided for @previousChapter.
  ///
  /// In en, this message translates to:
  /// **'Previous chapter'**
  String get previousChapter;

  /// No description provided for @nextChapter.
  ///
  /// In en, this message translates to:
  /// **'Next chapter'**
  String get nextChapter;

  /// No description provided for @hadithCopied.
  ///
  /// In en, this message translates to:
  /// **'Hadith copied'**
  String get hadithCopied;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get prayerTimes;

  /// No description provided for @prayerTimesForMasjid.
  ///
  /// In en, this message translates to:
  /// **'Prayer times for your masjid'**
  String get prayerTimesForMasjid;

  /// No description provided for @prayerIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the masjid\'s full address or ZIP code. It is geocoded to precise coordinates and its time zone, then daily prayer, iqama and Jumu\'ah times are generated with the calculation method you choose.'**
  String get prayerIntro;

  /// No description provided for @setUpMasjid.
  ///
  /// In en, this message translates to:
  /// **'Set up a masjid from its address'**
  String get setUpMasjid;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useMyLocation;

  /// No description provided for @methodsList.
  ///
  /// In en, this message translates to:
  /// **'Calculation methods: ISNA, Muslim World League, Egyptian, Karachi, Umm al-Qura, Gulf, Kuwait, Qatar, Singapore, Diyanet, UOIF, Russia, Tehran and Jafari. Asr: Shafi\'i/Maliki/Hanbali or Hanafi.'**
  String get methodsList;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location: {error}'**
  String couldNotGetLocation(String error);

  /// No description provided for @monthlyTimetable.
  ///
  /// In en, this message translates to:
  /// **'Monthly timetable'**
  String get monthlyTimetable;

  /// No description provided for @shareToday.
  ///
  /// In en, this message translates to:
  /// **'Share today'**
  String get shareToday;

  /// No description provided for @editMasjid.
  ///
  /// In en, this message translates to:
  /// **'Edit masjid'**
  String get editMasjid;

  /// No description provided for @addAnotherMasjid.
  ///
  /// In en, this message translates to:
  /// **'Add another masjid'**
  String get addAnotherMasjid;

  /// No description provided for @removeMasjid.
  ///
  /// In en, this message translates to:
  /// **'Remove masjid'**
  String get removeMasjid;

  /// No description provided for @removeMasjidQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeMasjidQuestion(String name);

  /// No description provided for @removeMasjidBody.
  ///
  /// In en, this message translates to:
  /// **'Its address, calculation settings, iqama and Jumu\'ah times will be deleted.'**
  String get removeMasjidBody;

  /// No description provided for @nextPrayerIn.
  ///
  /// In en, this message translates to:
  /// **'{prayer} at {time} · in {duration}'**
  String nextPrayerIn(String prayer, String time, String duration);

  /// No description provided for @fajrTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Fajr (tomorrow)'**
  String get fajrTomorrow;

  /// No description provided for @jumuah.
  ///
  /// In en, this message translates to:
  /// **'Jumu\'ah'**
  String get jumuah;

  /// No description provided for @noJumuahSet.
  ///
  /// In en, this message translates to:
  /// **'No Jumu\'ah services set. Edit the masjid to add them.'**
  String get noJumuahSet;

  /// No description provided for @khutbahAt.
  ///
  /// In en, this message translates to:
  /// **'Khutbah {time}'**
  String khutbahAt(String time);

  /// No description provided for @iqamaAt.
  ///
  /// In en, this message translates to:
  /// **'Iqama {time}'**
  String iqamaAt(String time);

  /// No description provided for @timesFootnote.
  ///
  /// In en, this message translates to:
  /// **'Times are computed astronomically for {lat}, {lng} in the {tz} zone, rounded to the minute. Hijri date is calculated and may differ by a day from local moon sighting.'**
  String timesFootnote(String lat, String lng, String tz);

  /// No description provided for @qiblaDegrees.
  ///
  /// In en, this message translates to:
  /// **'Qibla {degrees}°'**
  String qiblaDegrees(int degrees);

  /// No description provided for @asrShafii.
  ///
  /// In en, this message translates to:
  /// **'Asr Shafi\'i'**
  String get asrShafii;

  /// No description provided for @asrHanafi.
  ///
  /// In en, this message translates to:
  /// **'Asr Hanafi'**
  String get asrHanafi;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @addMasjid.
  ///
  /// In en, this message translates to:
  /// **'Add masjid'**
  String get addMasjid;

  /// No description provided for @masjid.
  ///
  /// In en, this message translates to:
  /// **'Masjid'**
  String get masjid;

  /// No description provided for @masjidName.
  ///
  /// In en, this message translates to:
  /// **'Masjid name'**
  String get masjidName;

  /// No description provided for @enterAName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterAName;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get streetAddress;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @stateProvince.
  ///
  /// In en, this message translates to:
  /// **'State / Province'**
  String get stateProvince;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'ZIP / Postal code'**
  String get postalCode;

  /// No description provided for @countryCode.
  ///
  /// In en, this message translates to:
  /// **'Country code (US, GB, FR…)'**
  String get countryCode;

  /// No description provided for @findLocation.
  ///
  /// In en, this message translates to:
  /// **'Find location'**
  String get findLocation;

  /// No description provided for @deviceGps.
  ///
  /// In en, this message translates to:
  /// **'Device GPS'**
  String get deviceGps;

  /// No description provided for @coordinatesAndTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Coordinates & time zone'**
  String get coordinatesAndTimeZone;

  /// No description provided for @setAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Set automatically from the address'**
  String get setAutomatically;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @ianaTimeZone.
  ///
  /// In en, this message translates to:
  /// **'IANA time zone (e.g. Europe/London)'**
  String get ianaTimeZone;

  /// No description provided for @calculation.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get calculation;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get calculationMethod;

  /// No description provided for @asrShafiiFull.
  ///
  /// In en, this message translates to:
  /// **'Asr: Shafi\'i / Maliki / Hanbali'**
  String get asrShafiiFull;

  /// No description provided for @asrHanafiFull.
  ///
  /// In en, this message translates to:
  /// **'Asr: Hanafi'**
  String get asrHanafiFull;

  /// No description provided for @dhuhrAfterZawal.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr: minutes after zawal'**
  String get dhuhrAfterZawal;

  /// No description provided for @maghribAfterSunset.
  ///
  /// In en, this message translates to:
  /// **'Maghrib: minutes after sunset'**
  String get maghribAfterSunset;

  /// No description provided for @fineTune.
  ///
  /// In en, this message translates to:
  /// **'Fine-tune each prayer (minutes)'**
  String get fineTune;

  /// No description provided for @hijriAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Hijri date adjustment (days)'**
  String get hijriAdjustment;

  /// No description provided for @iqama.
  ///
  /// In en, this message translates to:
  /// **'Iqama'**
  String get iqama;

  /// No description provided for @jumuahServices.
  ///
  /// In en, this message translates to:
  /// **'Jumu\'ah services'**
  String get jumuahServices;

  /// No description provided for @addJumuahTime.
  ///
  /// In en, this message translates to:
  /// **'Add Jumu\'ah time'**
  String get addJumuahTime;

  /// No description provided for @addAnotherService.
  ///
  /// In en, this message translates to:
  /// **'Add another service'**
  String get addAnotherService;

  /// No description provided for @saveMasjid.
  ///
  /// In en, this message translates to:
  /// **'Save masjid'**
  String get saveMasjid;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixed;

  /// No description provided for @plusMinutes.
  ///
  /// In en, this message translates to:
  /// **'+ min'**
  String get plusMinutes;

  /// No description provided for @khutbahPicker.
  ///
  /// In en, this message translates to:
  /// **'Khutbah…'**
  String get khutbahPicker;

  /// No description provided for @jumuahLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Label (language, hall, khateeb)'**
  String get jumuahLabelHint;

  /// No description provided for @enterZipOrCity.
  ///
  /// In en, this message translates to:
  /// **'Enter at least a ZIP / postal code or a city.'**
  String get enterZipOrCity;

  /// No description provided for @lookingUpAddress.
  ///
  /// In en, this message translates to:
  /// **'Looking up the address…'**
  String get lookingUpAddress;

  /// No description provided for @noMatchTryCountry.
  ///
  /// In en, this message translates to:
  /// **'No match. Try adding the city and a 2-letter country code (e.g. US, GB, FR).'**
  String get noMatchTryCountry;

  /// No description provided for @chooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose the correct location:'**
  String get chooseLocation;

  /// No description provided for @lookupFailed.
  ///
  /// In en, this message translates to:
  /// **'Lookup failed: {error}'**
  String lookupFailed(String error);

  /// No description provided for @resolvingTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Resolving time zone…'**
  String get resolvingTimeZone;

  /// No description provided for @located.
  ///
  /// In en, this message translates to:
  /// **'Located: {name}'**
  String located(String name);

  /// No description provided for @timeZoneLookupFailed.
  ///
  /// In en, this message translates to:
  /// **'Coordinates set, but time zone lookup failed ({error}). Enter an IANA zone such as America/New_York.'**
  String timeZoneLookupFailed(String error);

  /// No description provided for @gettingPosition.
  ///
  /// In en, this message translates to:
  /// **'Getting your position…'**
  String get gettingPosition;

  /// No description provided for @couldNotUseDevice.
  ///
  /// In en, this message translates to:
  /// **'Could not use device location: {error}'**
  String couldNotUseDevice(String error);

  /// No description provided for @findLocationFirst.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Find location\" first so the coordinates and time zone are set.'**
  String get findLocationFirst;

  /// No description provided for @setUpMasjidFirst.
  ///
  /// In en, this message translates to:
  /// **'Set up a masjid first.'**
  String get setUpMasjidFirst;

  /// No description provided for @hideIqama.
  ///
  /// In en, this message translates to:
  /// **'Hide iqama'**
  String get hideIqama;

  /// No description provided for @showIqama.
  ///
  /// In en, this message translates to:
  /// **'Show iqama'**
  String get showIqama;

  /// No description provided for @copyAsCsv.
  ///
  /// In en, this message translates to:
  /// **'Copy as CSV'**
  String get copyAsCsv;

  /// No description provided for @csvCopied.
  ///
  /// In en, this message translates to:
  /// **'CSV copied — paste into Excel or Sheets'**
  String get csvCopied;

  /// No description provided for @shareAsText.
  ///
  /// In en, this message translates to:
  /// **'Share as text'**
  String get shareAsText;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @mushafLayout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get mushafLayout;

  /// No description provided for @layoutAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get layoutAutomatic;

  /// No description provided for @layoutScroll.
  ///
  /// In en, this message translates to:
  /// **'Single page, scroll down'**
  String get layoutScroll;

  /// No description provided for @layoutFlip.
  ///
  /// In en, this message translates to:
  /// **'Single page, flip'**
  String get layoutFlip;

  /// No description provided for @layoutBook.
  ///
  /// In en, this message translates to:
  /// **'Two pages, flip'**
  String get layoutBook;

  /// No description provided for @playThisPage.
  ///
  /// In en, this message translates to:
  /// **'Play this page'**
  String get playThisPage;

  /// No description provided for @goToPage.
  ///
  /// In en, this message translates to:
  /// **'Go to page'**
  String get goToPage;

  /// No description provided for @goTo.
  ///
  /// In en, this message translates to:
  /// **'Go to'**
  String get goTo;

  /// No description provided for @pageRange.
  ///
  /// In en, this message translates to:
  /// **'Page (1–604)'**
  String get pageRange;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// No description provided for @pageJuz.
  ///
  /// In en, this message translates to:
  /// **'Page {page} · Juz {juz}'**
  String pageJuz(int page, int juz);

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @openBook.
  ///
  /// In en, this message translates to:
  /// **'Open book'**
  String get openBook;

  /// No description provided for @tableOfContents.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get tableOfContents;

  /// No description provided for @chapterPage.
  ///
  /// In en, this message translates to:
  /// **'Chapter {chapter} · Page {page} / {total}'**
  String chapterPage(int chapter, int page, int total);

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get listView;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @downloadChapterPdf.
  ///
  /// In en, this message translates to:
  /// **'Download this chapter as PDF'**
  String get downloadChapterPdf;

  /// No description provided for @downloadBookPdf.
  ///
  /// In en, this message translates to:
  /// **'Download the whole book as PDF'**
  String get downloadBookPdf;

  /// No description provided for @preparingPdf.
  ///
  /// In en, this message translates to:
  /// **'Fetching chapters… {done} / {total}'**
  String preparingPdf(int done, int total);

  /// No description provided for @renderingPdf.
  ///
  /// In en, this message translates to:
  /// **'Rendering the PDF…'**
  String get renderingPdf;

  /// No description provided for @pdfFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the PDF: {error}'**
  String pdfFailed(String error);

  /// No description provided for @hadithsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} hadiths'**
  String hadithsCount(int count);

  /// No description provided for @byAuthor.
  ///
  /// In en, this message translates to:
  /// **'by {author}'**
  String byAuthor(String author);

  /// No description provided for @reciteAndCheck.
  ///
  /// In en, this message translates to:
  /// **'Recite & check'**
  String get reciteAndCheck;

  /// No description provided for @reciteFromHere.
  ///
  /// In en, this message translates to:
  /// **'Recite from here'**
  String get reciteFromHere;

  /// No description provided for @reciteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recite from memory; the app listens and marks each word'**
  String get reciteSubtitle;

  /// No description provided for @ayahRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Ayahs {from}–{to}'**
  String ayahRangeLabel(int from, int to);

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'accuracy'**
  String get accuracy;

  /// No description provided for @matchedWords.
  ///
  /// In en, this message translates to:
  /// **'correct'**
  String get matchedWords;

  /// No description provided for @wrongWords.
  ///
  /// In en, this message translates to:
  /// **'wrong'**
  String get wrongWords;

  /// No description provided for @missedWords.
  ///
  /// In en, this message translates to:
  /// **'missed'**
  String get missedWords;

  /// No description provided for @wordsReached.
  ///
  /// In en, this message translates to:
  /// **'{reached} of {total} words recited'**
  String wordsReached(int reached, int total);

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listening;

  /// No description provided for @waitingForSpeech.
  ///
  /// In en, this message translates to:
  /// **'Waiting for speech…'**
  String get waitingForSpeech;

  /// No description provided for @tapMicToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap the microphone and start reciting'**
  String get tapMicToStart;

  /// No description provided for @heard.
  ///
  /// In en, this message translates to:
  /// **'Heard'**
  String get heard;

  /// No description provided for @notInPassage.
  ///
  /// In en, this message translates to:
  /// **'Words not in the passage'**
  String get notInPassage;

  /// No description provided for @hideText.
  ///
  /// In en, this message translates to:
  /// **'Hide the text (memorisation)'**
  String get hideText;

  /// No description provided for @showText.
  ///
  /// In en, this message translates to:
  /// **'Show the text'**
  String get showText;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @playThisAyah.
  ///
  /// In en, this message translates to:
  /// **'Play this ayah'**
  String get playThisAyah;

  /// No description provided for @speechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not available. Allow microphone access, or use Chrome on the web.'**
  String get speechUnavailable;

  /// No description provided for @reciteHelp.
  ///
  /// In en, this message translates to:
  /// **'Recite clearly and at a steady pace. Recognition works best in a quiet room; correct words turn green, wrong words red (with a buzz), skipped words orange. Keep going after a slip and the checker follows you.'**
  String get reciteHelp;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @qiblaBearing.
  ///
  /// In en, this message translates to:
  /// **'Qibla bearing from true north'**
  String get qiblaBearing;

  /// No description provided for @qiblaNeedsLocation.
  ///
  /// In en, this message translates to:
  /// **'The Qibla is computed from your location. Use your device\'s GPS, or set up a masjid first.'**
  String get qiblaNeedsLocation;

  /// No description provided for @distanceToMakkah.
  ///
  /// In en, this message translates to:
  /// **'{km} km to Makkah'**
  String distanceToMakkah(int km);

  /// No description provided for @headingDegrees.
  ///
  /// In en, this message translates to:
  /// **'Heading {degrees}°'**
  String headingDegrees(int degrees);

  /// No description provided for @facingQibla.
  ///
  /// In en, this message translates to:
  /// **'You are facing the Qibla'**
  String get facingQibla;

  /// No description provided for @compassWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the compass… move your phone in a figure of eight to calibrate.'**
  String get compassWaiting;

  /// No description provided for @compassUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No compass on this device: hold a compass or map and turn to the bearing above.'**
  String get compassUnavailable;

  /// No description provided for @turnToQibla.
  ///
  /// In en, this message translates to:
  /// **'Turn {direction} by {degrees}°'**
  String turnToQibla(String direction, int degrees);

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get left;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'right'**
  String get right;

  /// No description provided for @qiblaHelp.
  ///
  /// In en, this message translates to:
  /// **'Keep the phone flat and away from magnets or metal. The Kaaba marker on the dial shows the Qibla; the arrow at the top is where you are facing.'**
  String get qiblaHelp;

  /// No description provided for @adhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get adhan;

  /// No description provided for @adhanIntro.
  ///
  /// In en, this message translates to:
  /// **'Listen to the call to prayer from different muezzins, download any recording, and choose the default used for your prayer times.'**
  String get adhanIntro;

  /// No description provided for @adhanCredits.
  ///
  /// In en, this message translates to:
  /// **'Recordings courtesy of the Internet Archive collections \"adhans\" and \"azan-alafasy\".'**
  String get adhanCredits;

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {name}'**
  String downloaded(String name);

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String downloadFailed(String error);

  /// No description provided for @downloadSurahAudio.
  ///
  /// In en, this message translates to:
  /// **'Download surah audio for offline'**
  String get downloadSurahAudio;

  /// No description provided for @downloadAyahAudio.
  ///
  /// In en, this message translates to:
  /// **'Download this ayah\'s audio (MP3)'**
  String get downloadAyahAudio;

  /// No description provided for @offlineAudioNativeOnly.
  ///
  /// In en, this message translates to:
  /// **'Offline audio is kept in the mobile and desktop apps; on the web, download single ayahs.'**
  String get offlineAudioNativeOnly;

  /// No description provided for @surahAudioSaved.
  ///
  /// In en, this message translates to:
  /// **'{surah} saved for offline listening'**
  String surahAudioSaved(String surah);

  /// No description provided for @downloadForOffline.
  ///
  /// In en, this message translates to:
  /// **'Download for offline reading'**
  String get downloadForOffline;

  /// No description provided for @savedForOffline.
  ///
  /// In en, this message translates to:
  /// **'{name} saved for offline reading'**
  String savedForOffline(String name);

  /// No description provided for @playAdhan.
  ///
  /// In en, this message translates to:
  /// **'Play adhan'**
  String get playAdhan;

  /// No description provided for @adhanForNext.
  ///
  /// In en, this message translates to:
  /// **'Adhan for {prayer}'**
  String adhanForNext(String prayer);

  /// No description provided for @chooseAdhan.
  ///
  /// In en, this message translates to:
  /// **'Choose adhan'**
  String get chooseAdhan;

  /// No description provided for @pageAnimation.
  ///
  /// In en, this message translates to:
  /// **'Page animation'**
  String get pageAnimation;

  /// No description provided for @animationCurl.
  ///
  /// In en, this message translates to:
  /// **'Page curl'**
  String get animationCurl;

  /// No description provided for @animationFlip.
  ///
  /// In en, this message translates to:
  /// **'Card flip'**
  String get animationFlip;

  /// No description provided for @animationSlide.
  ///
  /// In en, this message translates to:
  /// **'Slide'**
  String get animationSlide;

  /// No description provided for @animationFade.
  ///
  /// In en, this message translates to:
  /// **'Fade'**
  String get animationFade;

  /// No description provided for @highlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get highlight;

  /// No description provided for @removeHighlight.
  ///
  /// In en, this message translates to:
  /// **'Remove highlight'**
  String get removeHighlight;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Write your reflection or reminder for this ayah…'**
  String get noteHint;

  /// No description provided for @noteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved'**
  String get noteSaved;

  /// No description provided for @noteHelp.
  ///
  /// In en, this message translates to:
  /// **'Notes stay on this device. Highlighted ayahs are coloured on the Mushaf pages.'**
  String get noteHelp;

  /// No description provided for @continuous.
  ///
  /// In en, this message translates to:
  /// **'Auto-continue'**
  String get continuous;

  /// No description provided for @repeatEach.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatEach;

  /// No description provided for @verseDetails.
  ///
  /// In en, this message translates to:
  /// **'Verse details'**
  String get verseDetails;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @fitPage.
  ///
  /// In en, this message translates to:
  /// **'Fit to page'**
  String get fitPage;

  /// No description provided for @shareEmbed.
  ///
  /// In en, this message translates to:
  /// **'Share & embed'**
  String get shareEmbed;

  /// No description provided for @websiteWidget.
  ///
  /// In en, this message translates to:
  /// **'Website widget & TV display'**
  String get websiteWidget;

  /// No description provided for @widgetLinks.
  ///
  /// In en, this message translates to:
  /// **'Public links'**
  String get widgetLinks;

  /// No description provided for @embedCode.
  ///
  /// In en, this message translates to:
  /// **'Embed code'**
  String get embedCode;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Embed code copied'**
  String get codeCopied;

  /// No description provided for @combinedWidget.
  ///
  /// In en, this message translates to:
  /// **'Combined widget (daily + Friday)'**
  String get combinedWidget;

  /// No description provided for @dailyWidget.
  ///
  /// In en, this message translates to:
  /// **'Daily prayer widget'**
  String get dailyWidget;

  /// No description provided for @jumuahWidget.
  ///
  /// In en, this message translates to:
  /// **'Friday prayer widget'**
  String get jumuahWidget;

  /// No description provided for @compactWidget.
  ///
  /// In en, this message translates to:
  /// **'Compact widget'**
  String get compactWidget;

  /// No description provided for @tvDisplay.
  ///
  /// In en, this message translates to:
  /// **'TV display'**
  String get tvDisplay;

  /// No description provided for @darkWidget.
  ///
  /// In en, this message translates to:
  /// **'Dark widget'**
  String get darkWidget;

  /// No description provided for @embedHelp.
  ///
  /// In en, this message translates to:
  /// **'Paste the embed code into your masjid website, or share a link. The link itself carries this masjid’s location, method, iqama and Jumu’ah settings, so copy it again after you change them. Add ?theme=dark or &scale=120, &lang=ar to any link.'**
  String get embedHelp;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @adhanHeader.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get adhanHeader;

  /// No description provided for @poweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by Mushaf+'**
  String get poweredBy;

  /// No description provided for @invalidWidgetLink.
  ///
  /// In en, this message translates to:
  /// **'This widget link is invalid or incomplete.'**
  String get invalidWidgetLink;

  /// No description provided for @micDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone access was denied. Allow it for this site in the browser or system settings, then try again.'**
  String get micDenied;

  /// No description provided for @noSpeechYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing heard yet. Recite clearly, close to the microphone. Words appear here as they are recognised.'**
  String get noSpeechYet;

  /// No description provided for @speechNotice.
  ///
  /// In en, this message translates to:
  /// **'Recognition notice'**
  String get speechNotice;

  /// No description provided for @speechTip.
  ///
  /// In en, this message translates to:
  /// **'Correct words turn green, wrong words red with a buzz and a vibration; keep reciting after a slip and the checker follows you.'**
  String get speechTip;

  /// No description provided for @strictMode.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get strictMode;

  /// No description provided for @lenientMode.
  ///
  /// In en, this message translates to:
  /// **'Lenient'**
  String get lenientMode;

  /// No description provided for @strictHelp.
  ///
  /// In en, this message translates to:
  /// **'Strict mode: a word counts only when every letter matches. Vowel marks (harakat) and tajweed cannot be checked: speech recognition returns the letters only.'**
  String get strictHelp;

  /// No description provided for @tjHamzatWasl.
  ///
  /// In en, this message translates to:
  /// **'Hamzat al-wasl'**
  String get tjHamzatWasl;

  /// No description provided for @tjSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent letter'**
  String get tjSilent;

  /// No description provided for @tjLaamShamsiyyah.
  ///
  /// In en, this message translates to:
  /// **'Sun lam'**
  String get tjLaamShamsiyyah;

  /// No description provided for @tjMaddNormal.
  ///
  /// In en, this message translates to:
  /// **'Natural madd'**
  String get tjMaddNormal;

  /// No description provided for @tjMaddPermissible.
  ///
  /// In en, this message translates to:
  /// **'Permissible madd'**
  String get tjMaddPermissible;

  /// No description provided for @tjMaddNecessary.
  ///
  /// In en, this message translates to:
  /// **'Necessary madd'**
  String get tjMaddNecessary;

  /// No description provided for @tjQalqalah.
  ///
  /// In en, this message translates to:
  /// **'Qalqalah'**
  String get tjQalqalah;

  /// No description provided for @tjMaddObligatory.
  ///
  /// In en, this message translates to:
  /// **'Obligatory madd'**
  String get tjMaddObligatory;

  /// No description provided for @tjIkhfaShafawi.
  ///
  /// In en, this message translates to:
  /// **'Labial ikhfa'**
  String get tjIkhfaShafawi;

  /// No description provided for @tjIkhfa.
  ///
  /// In en, this message translates to:
  /// **'Ikhfa'**
  String get tjIkhfa;

  /// No description provided for @tjIdghamShafawi.
  ///
  /// In en, this message translates to:
  /// **'Labial idgham'**
  String get tjIdghamShafawi;

  /// No description provided for @tjIqlab.
  ///
  /// In en, this message translates to:
  /// **'Iqlab'**
  String get tjIqlab;

  /// No description provided for @tjIdghamGhunnah.
  ///
  /// In en, this message translates to:
  /// **'Idgham with ghunnah'**
  String get tjIdghamGhunnah;

  /// No description provided for @tjIdghamNoGhunnah.
  ///
  /// In en, this message translates to:
  /// **'Idgham without ghunnah'**
  String get tjIdghamNoGhunnah;

  /// No description provided for @tjIdghamMutajanisayn.
  ///
  /// In en, this message translates to:
  /// **'Idgham of similar letters'**
  String get tjIdghamMutajanisayn;

  /// No description provided for @tjIdghamMutaqaribayn.
  ///
  /// In en, this message translates to:
  /// **'Idgham of close letters'**
  String get tjIdghamMutaqaribayn;

  /// No description provided for @tjGhunnah.
  ///
  /// In en, this message translates to:
  /// **'Ghunnah'**
  String get tjGhunnah;

  /// No description provided for @tjdHamzatWasl.
  ///
  /// In en, this message translates to:
  /// **'A connecting hamzah at the start of a word. It is pronounced only when you begin with that word; when joining from the previous word it is silent, so read straight through it.'**
  String get tjdHamzatWasl;

  /// No description provided for @tjdSilent.
  ///
  /// In en, this message translates to:
  /// **'A letter written in the mushaf but not pronounced, such as the alif after the plural waw. Skip it in recitation.'**
  String get tjdSilent;

  /// No description provided for @tjdLaamShamsiyyah.
  ///
  /// In en, this message translates to:
  /// **'The lam of the definite article before a sun letter is not pronounced: double the sun letter instead, as in ٱلشَّمْس → ash-shams.'**
  String get tjdLaamShamsiyyah;

  /// No description provided for @tjdMaddNormal.
  ///
  /// In en, this message translates to:
  /// **'A natural lengthening: hold the long vowel for two counts, no more and no less.'**
  String get tjdMaddNormal;

  /// No description provided for @tjdMaddPermissible.
  ///
  /// In en, this message translates to:
  /// **'A lengthening where a madd letter meets a hamzah in the next word, or a stop creates a sukun. Hold it two, four or six counts, but stay consistent through the recitation.'**
  String get tjdMaddPermissible;

  /// No description provided for @tjdMaddNecessary.
  ///
  /// In en, this message translates to:
  /// **'A lengthening required by an original sukun or a shaddah after the madd letter, including the opening letters of surahs. Hold it six counts.'**
  String get tjdMaddNecessary;

  /// No description provided for @tjdQalqalah.
  ///
  /// In en, this message translates to:
  /// **'An echoing bounce on the letters ق ط ب ج د when they carry a sukun. Release the letter with a slight rebound, stronger when stopping on it.'**
  String get tjdQalqalah;

  /// No description provided for @tjdMaddObligatory.
  ///
  /// In en, this message translates to:
  /// **'A madd letter followed by a hamzah in the same word. Hold it four to five counts.'**
  String get tjdMaddObligatory;

  /// No description provided for @tjdIkhfaShafawi.
  ///
  /// In en, this message translates to:
  /// **'A meem with sukun before ب: close the lips lightly and hide the meem with a nasal sound of two counts.'**
  String get tjdIkhfaShafawi;

  /// No description provided for @tjdIkhfa.
  ///
  /// In en, this message translates to:
  /// **'A nun with sukun or tanwin before one of the fifteen ikhfa letters: hide the nun with a nasal sound of two counts, with the tongue ready for the next letter.'**
  String get tjdIkhfa;

  /// No description provided for @tjdIdghamShafawi.
  ///
  /// In en, this message translates to:
  /// **'A meem with sukun before another meem: merge them into one doubled meem with a nasal sound of two counts.'**
  String get tjdIdghamShafawi;

  /// No description provided for @tjdIqlab.
  ///
  /// In en, this message translates to:
  /// **'A nun with sukun or tanwin before ب changes into a meem, hidden with a nasal sound of two counts and lightly closed lips.'**
  String get tjdIqlab;

  /// No description provided for @tjdIdghamGhunnah.
  ///
  /// In en, this message translates to:
  /// **'A nun with sukun or tanwin before ي ن م و at the start of the next word merges into that letter, with a nasal sound of two counts.'**
  String get tjdIdghamGhunnah;

  /// No description provided for @tjdIdghamNoGhunnah.
  ///
  /// In en, this message translates to:
  /// **'A nun with sukun or tanwin before ل or ر merges completely into that letter, with no nasal sound.'**
  String get tjdIdghamNoGhunnah;

  /// No description provided for @tjdIdghamMutajanisayn.
  ///
  /// In en, this message translates to:
  /// **'Two letters from the same point of articulation, the first with sukun, merge into one doubled letter, as in قَد تَّبَيَّنَ.'**
  String get tjdIdghamMutajanisayn;

  /// No description provided for @tjdIdghamMutaqaribayn.
  ///
  /// In en, this message translates to:
  /// **'Two letters from close points of articulation, the first with sukun, merge into the second, as in قُل رَّبِّ.'**
  String get tjdIdghamMutaqaribayn;

  /// No description provided for @tjdGhunnah.
  ///
  /// In en, this message translates to:
  /// **'A nasal resonance held for two counts on a meem or nun with shaddah.'**
  String get tjdGhunnah;

  /// No description provided for @tjgMadd.
  ///
  /// In en, this message translates to:
  /// **'Prolongation (madd)'**
  String get tjgMadd;

  /// No description provided for @tjgNunTanwin.
  ///
  /// In en, this message translates to:
  /// **'Nun sakinah and tanwin'**
  String get tjgNunTanwin;

  /// No description provided for @tjgMeemSakinah.
  ///
  /// In en, this message translates to:
  /// **'Meem sakinah'**
  String get tjgMeemSakinah;

  /// No description provided for @tjgGhunnah.
  ///
  /// In en, this message translates to:
  /// **'Ghunnah'**
  String get tjgGhunnah;

  /// No description provided for @tjgQalqalah.
  ///
  /// In en, this message translates to:
  /// **'Qalqalah'**
  String get tjgQalqalah;

  /// No description provided for @tjgLam.
  ///
  /// In en, this message translates to:
  /// **'Lam'**
  String get tjgLam;

  /// No description provided for @tjgSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent letters'**
  String get tjgSilent;

  /// No description provided for @tjgIdghamAdjacent.
  ///
  /// In en, this message translates to:
  /// **'Merging of adjacent letters'**
  String get tjgIdghamAdjacent;

  /// No description provided for @tajweed.
  ///
  /// In en, this message translates to:
  /// **'Tajweed'**
  String get tajweed;

  /// No description provided for @tajweedColors.
  ///
  /// In en, this message translates to:
  /// **'Tajweed colours'**
  String get tajweedColors;

  /// No description provided for @tajweedColorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Colour the letters of the Mushaf and reader by tajweed rule'**
  String get tajweedColorsSubtitle;

  /// No description provided for @tajweedGuide.
  ///
  /// In en, this message translates to:
  /// **'Tajweed guide'**
  String get tajweedGuide;

  /// No description provided for @tajweedLegend.
  ///
  /// In en, this message translates to:
  /// **'Tajweed colour legend'**
  String get tajweedLegend;

  /// No description provided for @seeGuide.
  ///
  /// In en, this message translates to:
  /// **'Full guide'**
  String get seeGuide;

  /// No description provided for @tajweedIntro.
  ///
  /// In en, this message translates to:
  /// **'Tajweed is reciting each letter from its place of articulation with its proper qualities: lengthening where there is madd, nasal sound where there is ghunnah, hiding, merging and bouncing where the rules call for it. The Mushaf colours every letter that carries a rule; tap any word to see which rules apply to it and how to recite it. Rules follow riwayat Hafs an Asim.'**
  String get tajweedIntro;

  /// No description provided for @rulesInThisWord.
  ///
  /// In en, this message translates to:
  /// **'Tajweed in this word'**
  String get rulesInThisWord;

  /// No description provided for @noRulesInWord.
  ///
  /// In en, this message translates to:
  /// **'No tajweed rule is marked on this word: recite its letters plainly from their places of articulation.'**
  String get noRulesInWord;

  /// No description provided for @wordTab.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get wordTab;

  /// No description provided for @wordOfN.
  ///
  /// In en, this message translates to:
  /// **'Word {n} of {total}'**
  String wordOfN(int n, int total);

  /// No description provided for @playWord.
  ///
  /// In en, this message translates to:
  /// **'Play word'**
  String get playWord;

  /// No description provided for @example.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get example;

  /// No description provided for @triggerLetters.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get triggerLetters;

  /// No description provided for @countsValue.
  ///
  /// In en, this message translates to:
  /// **'{n} counts'**
  String countsValue(String n);

  /// No description provided for @tuhfaRef.
  ///
  /// In en, this message translates to:
  /// **'Tuhfat al-Atfal, lines {lines}'**
  String tuhfaRef(String lines);

  /// No description provided for @jazariyyahRef.
  ///
  /// In en, this message translates to:
  /// **'al-Jazariyyah, lines {lines}'**
  String jazariyyahRef(String lines);

  /// No description provided for @tajweedSource.
  ///
  /// In en, this message translates to:
  /// **'Rules and colouring follow the alquran.cloud tajweed guide (riwayat Hafs, Tanzil Uthmani text) and the KFGQPC colour scheme used by quran.com. Line references point to Tuhfat al-Atfal and al-Muqaddimah al-Jazariyyah.'**
  String get tajweedSource;

  /// No description provided for @fullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get fullScreen;

  /// No description provided for @exitFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Exit full screen'**
  String get exitFullScreen;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get playbackSpeed;

  /// No description provided for @chooseReciter.
  ///
  /// In en, this message translates to:
  /// **'Choose a reciter'**
  String get chooseReciter;

  /// No description provided for @approximateLocation.
  ///
  /// In en, this message translates to:
  /// **'Only the area (postal code or city) was found, so the coordinates are its centre. If you know the exact coordinates, enter them below.'**
  String get approximateLocation;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @pdfReady.
  ///
  /// In en, this message translates to:
  /// **'PDF ready ({size})'**
  String pdfReady(String size);

  /// No description provided for @openPdf.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openPdf;

  /// No description provided for @savePdf.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get savePdf;

  /// No description provided for @offlineSavedBody.
  ///
  /// In en, this message translates to:
  /// **'The book is stored on this device in the current hadith language and opens without internet from the library. Download it again after switching language.'**
  String get offlineSavedBody;

  /// No description provided for @adhkar.
  ///
  /// In en, this message translates to:
  /// **'Adhkar'**
  String get adhkar;

  /// No description provided for @hisnAlMuslim.
  ///
  /// In en, this message translates to:
  /// **'Hisn al-Muslim'**
  String get hisnAlMuslim;

  /// No description provided for @hisnAlMuslimSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fortress of the Muslim · supplications from the Quran and Sunnah'**
  String get hisnAlMuslimSubtitle;

  /// No description provided for @adhkarIntro.
  ///
  /// In en, this message translates to:
  /// **'Daily remembrances and supplications from Hisn al-Muslim by Sa‘id al-Qahtani, with repeat counters and audio.'**
  String get adhkarIntro;

  /// No description provided for @repeatProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String repeatProgress(int done, int total);

  /// No description provided for @playChapter.
  ///
  /// In en, this message translates to:
  /// **'Play chapter'**
  String get playChapter;

  /// No description provided for @resetCounters.
  ///
  /// In en, this message translates to:
  /// **'Reset counters'**
  String get resetCounters;

  /// No description provided for @adhkarLanguageNote.
  ///
  /// In en, this message translates to:
  /// **'Translations come from hisnmuslim.com and exist in English and Arabic only.'**
  String get adhkarLanguageNote;

  /// No description provided for @findAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Find a chapter…'**
  String get findAdhkar;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @afterPrayer.
  ///
  /// In en, this message translates to:
  /// **'After prayer'**
  String get afterPrayer;

  /// No description provided for @allDone.
  ///
  /// In en, this message translates to:
  /// **'All done'**
  String get allDone;

  /// No description provided for @timesN.
  ///
  /// In en, this message translates to:
  /// **'×{n}'**
  String timesN(int n);

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get readAloud;

  /// No description provided for @stopReading.
  ///
  /// In en, this message translates to:
  /// **'Stop reading'**
  String get stopReading;

  /// No description provided for @ttsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No voice for this language is installed on this device. Hadith are read with the device’s text-to-speech voices.'**
  String get ttsUnavailable;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search the Quran — a surah, an ayah, a word or a phrase. Arabic with or without harakat, transliteration (insan, bismillah), English meaning, or a surah name or number…'**
  String get homeSearchHint;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @changeRegion.
  ///
  /// In en, this message translates to:
  /// **'tap to change'**
  String get changeRegion;

  /// No description provided for @detectRegion.
  ///
  /// In en, this message translates to:
  /// **'Detect'**
  String get detectRegion;

  /// No description provided for @regionHelp.
  ///
  /// In en, this message translates to:
  /// **'Pre-fills the country for masjids and picks the usual prayer calculation for that country.'**
  String get regionHelp;

  /// No description provided for @regionSetTo.
  ///
  /// In en, this message translates to:
  /// **'Region set to {name}. Tap the flag to change it.'**
  String regionSetTo(String name);

  /// No description provided for @regionNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Could not detect your country. Choose it from the list.'**
  String get regionNotDetected;

  /// No description provided for @findCountry.
  ///
  /// In en, this message translates to:
  /// **'Find a country…'**
  String get findCountry;

  /// No description provided for @myPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'My prayer times'**
  String get myPrayerTimes;

  /// No description provided for @masjidsTab.
  ///
  /// In en, this message translates to:
  /// **'Masjids'**
  String get masjidsTab;

  /// No description provided for @enterMyCity.
  ///
  /// In en, this message translates to:
  /// **'Enter my city'**
  String get enterMyCity;

  /// No description provided for @orEnterCity.
  ///
  /// In en, this message translates to:
  /// **'or enter your city'**
  String get orEnterCity;

  /// No description provided for @editLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit location'**
  String get editLocation;

  /// No description provided for @personalIntro.
  ///
  /// In en, this message translates to:
  /// **'Prayer times for where you are: allow your precise location, or type your city. The calculation method follows your country and can be changed.'**
  String get personalIntro;

  /// No description provided for @masjidAdminHint.
  ///
  /// In en, this message translates to:
  /// **'Masjid administrators: set up the masjid itself, with iqama and Jumu’ah times and website widgets, under the Masjids tab after creating a profile.'**
  String get masjidAdminHint;

  /// No description provided for @masjidAdminGate.
  ///
  /// In en, this message translates to:
  /// **'Masjid profiles carry iqama times, Jumu’ah services and public widgets, so they are tied to a named administrator. Create your profile (name and email, kept on this device) to set one up.'**
  String get masjidAdminGate;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create profile'**
  String get createProfile;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileIntro.
  ///
  /// In en, this message translates to:
  /// **'Your name and email identify you as the administrator of the masjids you set up. They stay on this device.'**
  String get profileIntro;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @masjidRole.
  ///
  /// In en, this message translates to:
  /// **'Role at the masjid (optional)'**
  String get masjidRole;

  /// No description provided for @masjidRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Imam, board member, volunteer…'**
  String get masjidRoleHint;

  /// No description provided for @removeProfile.
  ///
  /// In en, this message translates to:
  /// **'Remove profile'**
  String get removeProfile;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @remindersOn.
  ///
  /// In en, this message translates to:
  /// **'On · tap to adjust'**
  String get remindersOn;

  /// No description provided for @remindersOff.
  ///
  /// In en, this message translates to:
  /// **'Off · prayer times, adhkar, daily ayah'**
  String get remindersOff;

  /// No description provided for @remindersSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer times with adhan, morning and evening adhkar, daily ayah or dhikr'**
  String get remindersSettingsSubtitle;

  /// No description provided for @prayerReminders.
  ///
  /// In en, this message translates to:
  /// **'Prayer time reminders'**
  String get prayerReminders;

  /// No description provided for @prayerRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each prayer; opening the reminder plays {adhan}'**
  String prayerRemindersSubtitle(String adhan);

  /// No description provided for @remindBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind'**
  String get remindBefore;

  /// No description provided for @atPrayerTime.
  ///
  /// In en, this message translates to:
  /// **'At prayer time'**
  String get atPrayerTime;

  /// No description provided for @minutesBefore.
  ///
  /// In en, this message translates to:
  /// **'{n} min before'**
  String minutesBefore(int n);

  /// No description provided for @adhkarReminders.
  ///
  /// In en, this message translates to:
  /// **'Adhkar reminders'**
  String get adhkarReminders;

  /// No description provided for @adhkarRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Morning adhkar after Fajr, evening adhkar after Asr, sleep adhkar one hour after Isha'**
  String get adhkarRemindersSubtitle;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Ayah or dhikr of the day'**
  String get dailyReminder;

  /// No description provided for @dailyReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A random ayah or dhikr once a day'**
  String get dailyReminderSubtitle;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderTime;

  /// No description provided for @nextReminders.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get nextReminders;

  /// No description provided for @notificationsWebNote.
  ///
  /// In en, this message translates to:
  /// **'In a browser, reminders appear only while Mushaf+ is open in a tab. Install the Android or iOS app for reminders that work with the app closed.'**
  String get notificationsWebNote;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked for Mushaf+ in the system settings.'**
  String get notificationsDenied;

  /// No description provided for @setLocationFirst.
  ///
  /// In en, this message translates to:
  /// **'Set your prayer location first'**
  String get setLocationFirst;

  /// No description provided for @adhanOnNotification.
  ///
  /// In en, this message translates to:
  /// **'Prayer reminders use the system sound; opening one plays your chosen adhan in full.'**
  String get adhanOnNotification;

  /// No description provided for @prayerInMinutes.
  ///
  /// In en, this message translates to:
  /// **'{prayer} in {n} minutes'**
  String prayerInMinutes(String prayer, int n);

  /// No description provided for @timeForPrayer.
  ///
  /// In en, this message translates to:
  /// **'Time for {prayer}'**
  String timeForPrayer(String prayer);

  /// No description provided for @timeAdhkarMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning adhkar'**
  String get timeAdhkarMorning;

  /// No description provided for @timeAdhkarEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening adhkar'**
  String get timeAdhkarEvening;

  /// No description provided for @timeAdhkarSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep adhkar'**
  String get timeAdhkarSleep;

  /// No description provided for @adhkarMorningBody.
  ///
  /// In en, this message translates to:
  /// **'Start the day with the morning remembrances.'**
  String get adhkarMorningBody;

  /// No description provided for @adhkarEveningBody.
  ///
  /// In en, this message translates to:
  /// **'The evening remembrances, before the night.'**
  String get adhkarEveningBody;

  /// No description provided for @adhkarSleepBody.
  ///
  /// In en, this message translates to:
  /// **'The remembrances before sleep.'**
  String get adhkarSleepBody;

  /// No description provided for @ayahOfTheDayNotif.
  ///
  /// In en, this message translates to:
  /// **'Ayah of the day'**
  String get ayahOfTheDayNotif;

  /// No description provided for @dhikrOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Dhikr of the day'**
  String get dhikrOfTheDay;

  /// No description provided for @memorizeCard.
  ///
  /// In en, this message translates to:
  /// **'Memorize & recite'**
  String get memorizeCard;

  /// No description provided for @memorizeCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide the words, reveal them one by one, then recite and let the app check you.'**
  String get memorizeCardSubtitle;

  /// No description provided for @town.
  ///
  /// In en, this message translates to:
  /// **'Town / City'**
  String get town;

  /// No description provided for @suburb.
  ///
  /// In en, this message translates to:
  /// **'Suburb'**
  String get suburb;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @zip.
  ///
  /// In en, this message translates to:
  /// **'ZIP code'**
  String get zip;

  /// No description provided for @postcode.
  ///
  /// In en, this message translates to:
  /// **'Postcode'**
  String get postcode;

  /// No description provided for @regionOptional.
  ///
  /// In en, this message translates to:
  /// **'Region (optional)'**
  String get regionOptional;

  /// No description provided for @postalOptional.
  ///
  /// In en, this message translates to:
  /// **'Postal code (optional)'**
  String get postalOptional;

  /// No description provided for @bundledAlways.
  ///
  /// In en, this message translates to:
  /// **'The Quran text, tajweed colours, transliteration, three English translations, the hadith index and Hisn al-Muslim are built in and always work offline.'**
  String get bundledAlways;

  /// No description provided for @downloadTextPacks.
  ///
  /// In en, this message translates to:
  /// **'Download all text packs'**
  String get downloadTextPacks;

  /// No description provided for @textPacks.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get textPacks;

  /// No description provided for @audioPacks.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audioPacks;

  /// No description provided for @tafsirPack.
  ///
  /// In en, this message translates to:
  /// **'Tafsir · {name}'**
  String tafsirPack(String name);

  /// No description provided for @hadithPack.
  ///
  /// In en, this message translates to:
  /// **'Hadith books ({lang})'**
  String hadithPack(String lang);

  /// No description provided for @chaptersSaved.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} chapters saved'**
  String chaptersSaved(int done, int total);

  /// No description provided for @adhanPack.
  ///
  /// In en, this message translates to:
  /// **'Adhan recordings'**
  String get adhanPack;

  /// No description provided for @adhkarAudioPack.
  ///
  /// In en, this message translates to:
  /// **'Hisn al-Muslim audio'**
  String get adhkarAudioPack;

  /// No description provided for @reciterPack.
  ///
  /// In en, this message translates to:
  /// **'Full recitation · {name}'**
  String reciterPack(String name);

  /// No description provided for @filesSaved.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} files saved'**
  String filesSaved(int done, int total);

  /// No description provided for @approxSize.
  ///
  /// In en, this message translates to:
  /// **'about {size}'**
  String approxSize(String size);

  /// No description provided for @offlinePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Use Mushaf+ offline?'**
  String get offlinePromptTitle;

  /// No description provided for @offlinePromptBody.
  ///
  /// In en, this message translates to:
  /// **'Download translations, word meanings, tafsir and the hadith books now (about 60 MB) so everything works without a connection. Audio packs can be added later under Settings → Offline packs.'**
  String get offlinePromptBody;

  /// No description provided for @downloadNow.
  ///
  /// In en, this message translates to:
  /// **'Download now'**
  String get downloadNow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @offlineAutoTitle.
  ///
  /// In en, this message translates to:
  /// **'Mushaf+ works fully offline'**
  String get offlineAutoTitle;

  /// No description provided for @offlineAutoBody.
  ///
  /// In en, this message translates to:
  /// **'The app will now download everything it needs so it works with no connection: translations, word meanings, tafsir, the hadith books, the adhan recordings and the Hisn al-Muslim audio (about 200 MB). It runs in the background; you can keep reading. Wi-Fi is recommended.'**
  String get offlineAutoBody;

  /// No description provided for @includeFullRecitation.
  ///
  /// In en, this message translates to:
  /// **'Full recitation by {name}'**
  String includeFullRecitation(String name);

  /// No description provided for @includeFullRecitationHint.
  ///
  /// In en, this message translates to:
  /// **'About 700 MB. You can also add it later under Settings → Offline packs.'**
  String get includeFullRecitationHint;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @offlineSyncing.
  ///
  /// In en, this message translates to:
  /// **'Downloading for offline use · {percent}%'**
  String offlineSyncing(int percent);

  /// No description provided for @offlineAutoIntro.
  ///
  /// In en, this message translates to:
  /// **'Mushaf+ downloads everything it needs in the background so it works with no connection. Each pack below shows what is stored; tap one to fetch what is missing.'**
  String get offlineAutoIntro;

  /// No description provided for @resumeOfflineDownload.
  ///
  /// In en, this message translates to:
  /// **'Download everything missing'**
  String get resumeOfflineDownload;

  /// No description provided for @wifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Audio on Wi-Fi only'**
  String get wifiOnly;

  /// No description provided for @wifiOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'On cellular data only the small text packs download by themselves.'**
  String get wifiOnlyHint;

  /// No description provided for @waitingForWifi.
  ///
  /// In en, this message translates to:
  /// **'Text packs are saved. Audio packs will download when you are on Wi-Fi (or tap the button above to download now).'**
  String get waitingForWifi;

  /// No description provided for @watchNoPlace.
  ///
  /// In en, this message translates to:
  /// **'Set a prayer location to see prayer times.'**
  String get watchNoPlace;

  /// No description provided for @inDuration.
  ///
  /// In en, this message translates to:
  /// **'in {duration}'**
  String inDuration(String duration);

  /// No description provided for @tasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbih;

  /// No description provided for @tapToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap to count, hold to reset'**
  String get tapToCount;

  /// No description provided for @useLocationShort.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useLocationShort;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Mushaf+'**
  String get supportTitle;

  /// No description provided for @supportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A voluntary contribution keeps the app free, open and ad-free.'**
  String get supportSubtitle;

  /// No description provided for @supportIntro.
  ///
  /// In en, this message translates to:
  /// **'Mushaf+ is free, has no ads and never will. If it helps you, a voluntary contribution covers the servers, audio hosting and store fees and lets us keep building.'**
  String get supportIntro;

  /// No description provided for @tipJarIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a tip. It unlocks nothing: everything in Mushaf+ stays free for everyone.'**
  String get tipJarIntro;

  /// No description provided for @tipThanks.
  ///
  /// In en, this message translates to:
  /// **'JazakAllahu khairan. Thank you for supporting Mushaf+!'**
  String get tipThanks;

  /// No description provided for @tipUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Tips are not available right now. Please try again later.'**
  String get tipUnavailable;

  /// No description provided for @donateIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose how you would like to contribute.'**
  String get donateIntro;

  /// No description provided for @donateComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Donation options are being set up. Thank you for your patience, and for using Mushaf+.'**
  String get donateComingSoon;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get bankTransfer;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @supportFootnote.
  ///
  /// In en, this message translates to:
  /// **'Contributions are voluntary gifts to the developer, not purchases, and are not tax-deductible.'**
  String get supportFootnote;

  /// No description provided for @recognitionEngine.
  ///
  /// In en, this message translates to:
  /// **'Recognition engine'**
  String get recognitionEngine;

  /// No description provided for @engineBrowser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get engineBrowser;

  /// No description provided for @engineBrowserDesc.
  ///
  /// In en, this message translates to:
  /// **'Fast, letters only'**
  String get engineBrowserDesc;

  /// No description provided for @engineVoiceModel.
  ///
  /// In en, this message translates to:
  /// **'Mushaf+ voice model'**
  String get engineVoiceModel;

  /// No description provided for @engineVoiceModelDesc.
  ///
  /// In en, this message translates to:
  /// **'150 MB one-time download, marks vowel mistakes'**
  String get engineVoiceModelDesc;

  /// No description provided for @engineVoiceModelHelp.
  ///
  /// In en, this message translates to:
  /// **'The Mushaf+ voice model downloads about 150 MB once, then runs on this device inside the browser. It checks vowel marks (harakat) as well as letters. Needs a recent Chrome, Edge or Safari.'**
  String get engineVoiceModelHelp;

  /// No description provided for @voiceModelDownloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Download the Mushaf+ voice model?'**
  String get voiceModelDownloadTitle;

  /// No description provided for @voiceModelDownloadBody.
  ///
  /// In en, this message translates to:
  /// **'About {size} MB, downloaded once and kept on this device. Recognition then runs in your browser and nothing you recite leaves your device.'**
  String voiceModelDownloadBody(int size);

  /// No description provided for @voiceModelDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading the voice model… {done} of {total} MB'**
  String voiceModelDownloading(int done, int total);

  /// No description provided for @voiceModelPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing the voice model…'**
  String get voiceModelPreparing;

  /// No description provided for @voiceModelFailed.
  ///
  /// In en, this message translates to:
  /// **'The voice model could not be loaded.'**
  String get voiceModelFailed;

  /// No description provided for @voiceModelSlow.
  ///
  /// In en, this message translates to:
  /// **'No graphics acceleration in this browser: results may lag by several seconds.'**
  String get voiceModelSlow;

  /// No description provided for @usingBrowserEngine.
  ///
  /// In en, this message translates to:
  /// **'Using the browser engine for now.'**
  String get usingBrowserEngine;

  /// No description provided for @vowelSlips.
  ///
  /// In en, this message translates to:
  /// **'vowel slips'**
  String get vowelSlips;

  /// No description provided for @letterErrors.
  ///
  /// In en, this message translates to:
  /// **'letter errors'**
  String get letterErrors;

  /// No description provided for @reciteSummary.
  ///
  /// In en, this message translates to:
  /// **'{correct} correct · {vowel} vowel slips · {letter} letter errors'**
  String reciteSummary(int correct, int vowel, int letter);

  /// No description provided for @feedbackDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Automatic feedback can be wrong; it does not replace a teacher.'**
  String get feedbackDisclaimer;

  /// No description provided for @vowelSlipLine.
  ///
  /// In en, this message translates to:
  /// **'Heard {heard} on {letter}, expected {expected}'**
  String vowelSlipLine(String heard, String letter, String expected);

  /// No description provided for @wordCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get wordCorrect;

  /// No description provided for @wordVowelSlip.
  ///
  /// In en, this message translates to:
  /// **'Vowel slip'**
  String get wordVowelSlip;

  /// No description provided for @wordWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong word'**
  String get wordWrong;

  /// No description provided for @wordMissed.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get wordMissed;

  /// No description provided for @wordPending.
  ///
  /// In en, this message translates to:
  /// **'Not reached yet'**
  String get wordPending;

  /// No description provided for @markFatha.
  ///
  /// In en, this message translates to:
  /// **'fatha'**
  String get markFatha;

  /// No description provided for @markDamma.
  ///
  /// In en, this message translates to:
  /// **'damma'**
  String get markDamma;

  /// No description provided for @markKasra.
  ///
  /// In en, this message translates to:
  /// **'kasra'**
  String get markKasra;

  /// No description provided for @markSukun.
  ///
  /// In en, this message translates to:
  /// **'sukun'**
  String get markSukun;

  /// No description provided for @markShadda.
  ///
  /// In en, this message translates to:
  /// **'shadda'**
  String get markShadda;

  /// No description provided for @markFathatan.
  ///
  /// In en, this message translates to:
  /// **'fathatan'**
  String get markFathatan;

  /// No description provided for @markDammatan.
  ///
  /// In en, this message translates to:
  /// **'dammatan'**
  String get markDammatan;

  /// No description provided for @markKasratan.
  ///
  /// In en, this message translates to:
  /// **'kasratan'**
  String get markKasratan;

  /// No description provided for @markNone.
  ///
  /// In en, this message translates to:
  /// **'no mark'**
  String get markNone;

  /// No description provided for @markNoShadda.
  ///
  /// In en, this message translates to:
  /// **'no shadda'**
  String get markNoShadda;

  /// No description provided for @voiceModelHelp.
  ///
  /// In en, this message translates to:
  /// **'The Mushaf+ voice model also checks vowel marks (harakat): a vowel slip shows in amber. Tap any word for details.'**
  String get voiceModelHelp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'en',
        'fr',
        'id',
        'tr',
        'ur'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
