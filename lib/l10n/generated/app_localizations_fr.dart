// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Quran+';

  @override
  String get navRead => 'Lire';

  @override
  String get navHadith => 'Hadith';

  @override
  String get navPrayer => 'Prière';

  @override
  String get navSaved => 'Favoris';

  @override
  String get navSettings => 'Réglages';

  @override
  String get search => 'Rechercher';

  @override
  String get searchTheQuran => 'Rechercher dans le Coran';

  @override
  String get cancel => 'Annuler';

  @override
  String get open => 'Ouvrir';

  @override
  String get apply => 'Appliquer';

  @override
  String get save => 'Enregistrer';

  @override
  String get retry => 'Réessayer';

  @override
  String get copy => 'Copier';

  @override
  String get share => 'Partager';

  @override
  String get clear => 'Effacer';

  @override
  String get remove => 'Supprimer';

  @override
  String get download => 'Télécharger';

  @override
  String get more => 'Plus';

  @override
  String get back => 'Retour';

  @override
  String get loading => 'Chargement…';

  @override
  String get couldNotLoadQuran => 'Impossible de charger les données du Coran.';

  @override
  String get continueReading => 'CONTINUER LA LECTURE';

  @override
  String get startReading => 'COMMENCER LA LECTURE';

  @override
  String ayahOfJuzPage(int ayah, int total, int juz, int page) {
    return 'Verset $ayah sur $total · Juz $juz · Page $page';
  }

  @override
  String get verseOfTheDay => 'VERSET DU JOUR';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String dailyGoalTapToStartPlan(int goal) {
    return 'Objectif quotidien $goal versets · touchez pour démarrer un plan de khatm';
  }

  @override
  String khatmOnTrack(int day, int days) {
    return 'Plan de khatm : dans les temps · jour $day/$days';
  }

  @override
  String khatmBehind(int behind, int day, int days) {
    return 'Plan de khatm : $behind versets de retard · jour $day/$days';
  }

  @override
  String get findSurahHint => 'Trouver une sourate par nom, sens ou numéro';

  @override
  String get tabSurah => 'Sourate';

  @override
  String get tabJuz => 'Juz';

  @override
  String get tabPage => 'Page';

  @override
  String get noSurahMatches =>
      'Aucune sourate ne correspond à votre recherche.';

  @override
  String surahSubtitle(String meaning, int count, String type) {
    return '$meaning · $count versets · $type';
  }

  @override
  String get meccan => 'Mecquoise';

  @override
  String get medinan => 'Médinoise';

  @override
  String juzN(int n) {
    return 'Juz $n';
  }

  @override
  String juzStartsAt(String surah, int ayah, int count) {
    return 'Commence à $surah, verset $ayah · $count versets';
  }

  @override
  String get jumpToSurah => 'Aller à une sourate';

  @override
  String pageN(int n) {
    return 'Page $n';
  }

  @override
  String get backToSurahs => 'Retour aux sourates';

  @override
  String get openMushafHere => 'Ouvrir le Mushaf à cette sourate';

  @override
  String get translations => 'Traductions';

  @override
  String get readingSettings => 'Réglages de lecture';

  @override
  String get playSurah => 'Écouter la sourate';

  @override
  String get pauseRecitation => 'Mettre en pause';

  @override
  String get memorizeThisSurah => 'Mémoriser cette sourate';

  @override
  String get openInMushaf => 'Ouvrir dans le Mushaf';

  @override
  String juzPage(int juz, int page) {
    return 'Juz $juz · Page $page';
  }

  @override
  String get wordByWord => 'Mot à mot';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get bookmark => 'Marquer';

  @override
  String get removeBookmark => 'Retirer le marque-page';

  @override
  String get bookmarkThisAyah => 'Marquer ce verset';

  @override
  String get play => 'Lecture';

  @override
  String get pause => 'Pause';

  @override
  String get playFromThisAyah => 'Écouter à partir de ce verset';

  @override
  String get sajdahAyah => 'Verset de prosternation (sajda)';

  @override
  String couldNotLoad(String name) {
    return 'Impossible de charger $name';
  }

  @override
  String wordByWordOffline(String error) {
    return 'Mot à mot indisponible hors ligne ($error)';
  }

  @override
  String ayahN(int n) {
    return 'Verset $n';
  }

  @override
  String get wordByWordSubtitle => 'Translittération et sens de chaque mot';

  @override
  String get tafsirSubtitle => 'Commentaire d\'Ibn Kathir et d\'autres';

  @override
  String get playRecitationFromHere => 'Écouter la récitation à partir d\'ici';

  @override
  String get memorizeFromHere => 'Mémoriser à partir d\'ici';

  @override
  String get memorizeSubtitle =>
      'Masquer les mots, les révéler un à un, répéter la récitation';

  @override
  String get ayahCopied => 'Verset copié';

  @override
  String wordN(int n) {
    return 'Mot $n';
  }

  @override
  String get wordByWordNeedsInternet =>
      'Le mot à mot nécessite une connexion Internet la première fois.';

  @override
  String get tafsirNeedsInternet =>
      'Le tafsir nécessite une connexion Internet la première fois.';

  @override
  String get viaQuranCom => 'via Quran.com';

  @override
  String get reciter => 'Récitateur';

  @override
  String get arabicSize => 'Taille de l\'arabe';

  @override
  String get translationSize => 'Taille de la traduction';

  @override
  String get amiriQuran => 'Amiri Quran';

  @override
  String get amiriNaskh => 'Amiri Naskh';

  @override
  String get showTransliteration => 'Afficher la translittération';

  @override
  String get showTransliterationSubtitle =>
      'Prononciation en lettres latines sous chaque verset';

  @override
  String get wordByWordMode => 'Mode mot à mot';

  @override
  String get wordByWordModeSubtitle =>
      'Chaque mot avec sa translittération et son sens';

  @override
  String get wordMeaningsLanguage => 'Langue du sens des mots';

  @override
  String get tapAyahHint =>
      'Touchez un verset pour la traduction, la translittération, le tafsir et le mot à mot.';

  @override
  String get previousAyah => 'Verset précédent';

  @override
  String get nextAyah => 'Verset suivant';

  @override
  String get stop => 'Arrêter';

  @override
  String get loop => 'boucle';

  @override
  String get searchHint => 'Arabe, translittération ou anglais…';

  @override
  String get searchWholeQuran => 'Rechercher dans tout le Coran';

  @override
  String get searchHelp =>
      'Saisissez de l\'arabe (avec ou sans harakat), une phrase translittérée ou un mot anglais. Les résultats ouvrent le verset dans le lecteur.';

  @override
  String noAyahMatches(String query) {
    return 'Aucun verset ne correspond à « $query »';
  }

  @override
  String resultsCount(String count) {
    return '$count résultats';
  }

  @override
  String get savedAyahs => 'Versets enregistrés';

  @override
  String get noBookmarksYet => 'Aucun marque-page';

  @override
  String get noBookmarksHelp =>
      'Touchez l\'icône marque-page sur un verset pendant la lecture pour l\'enregistrer ici.';

  @override
  String get settings => 'Réglages';

  @override
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get arabicFont => 'Police arabe';

  @override
  String get language => 'Langue de l\'application';

  @override
  String get systemDefault => 'Langue du système';

  @override
  String get recitation => 'Récitation';

  @override
  String get recitationHelp =>
      'L\'audio est diffusé verset par verset depuis everyayah.com. Touchez lecture sur un verset ou « Écouter la sourate » dans l\'en-tête.';

  @override
  String get reading => 'Lecture';

  @override
  String get wordByWordSettingSubtitle =>
      'Afficher chaque mot avec sa translittération et son sens (téléchargé une fois par sourate)';

  @override
  String get defaultView => 'Vue par défaut';

  @override
  String get viewTranslation => 'Traduction';

  @override
  String get viewMushafBook => 'Mushaf';

  @override
  String get languages => 'Langues';

  @override
  String get arabicOnlyTapToAdd =>
      'Arabe seul — touchez pour ajouter des traductions';

  @override
  String translationsAvailable(int count, int languages) {
    return '$count traductions en $languages langues sont disponibles. Chacune est téléchargée à la première ouverture d\'une sourate et conservée hors ligne.';
  }

  @override
  String get storage => 'Stockage';

  @override
  String get offlinePacks => 'Packs hors ligne';

  @override
  String get offlinePacksSubtitle =>
      'Télécharger les traductions et le mot à mot pour tout le Coran';

  @override
  String get clearDownloadedData => 'Effacer les données téléchargées';

  @override
  String cachedDownloads(int count) {
    return '$count sourates téléchargées';
  }

  @override
  String get clearDownloadedDataQuestion =>
      'Effacer les données téléchargées ?';

  @override
  String get clearDownloadedDataBody =>
      'Les traductions et le mot à mot seront retéléchargés au besoin. Les marque-pages et réglages sont conservés.';

  @override
  String get downloadedDataCleared => 'Données téléchargées effacées';

  @override
  String get about => 'À propos';

  @override
  String get versionBuiltWith => 'Version 1.0.0 · Réalisé avec Flutter';

  @override
  String get credits =>
      'Texte arabe : édition Tanzil Uthmani. Traductions et translittération : Al Quran Cloud. Mot à mot et tafsir : Quran.com. Récitation : EveryAyah.com. Hadith : fawazahmed0/hadith-api. Polices : Amiri et Amiri Quran (licence SIL).';

  @override
  String selectedOfMax(int selected, int max) {
    return '$selected sur $max sélectionnées';
  }

  @override
  String get searchLanguageOrTranslator =>
      'Rechercher une langue ou un traducteur';

  @override
  String nTranslations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count traductions',
      one: '1 traduction',
    );
    return '$_temp0';
  }

  @override
  String nSelected(int count) {
    return '$count sélectionnées';
  }

  @override
  String get rightToLeftScript => 'Écriture de droite à gauche';

  @override
  String translationLimit(int max) {
    return 'Vous pouvez afficher au plus $max traductions à la fois. Retirez-en une d\'abord.';
  }

  @override
  String get offlineIntro =>
      'Le texte arabe, la translittération anglaise et trois traductions anglaises sont toujours hors ligne. Téléchargez le reste une fois et lisez partout.';

  @override
  String get selectedTranslations => 'Traductions sélectionnées';

  @override
  String get allSelectedBundled =>
      'Toutes les traductions sélectionnées sont incluses dans l\'application.';

  @override
  String surahDownloadsSaved(int done, int total) {
    return '$done sur $total sourates enregistrées';
  }

  @override
  String wordByWordPack(String language) {
    return 'Mot à mot ($language)';
  }

  @override
  String surahsSavedSize(int done) {
    return '$done sur 114 sourates enregistrées · environ 8 Mo';
  }

  @override
  String get tafsirSavedAutomatically =>
      'Le tafsir est enregistré automatiquement pour chaque verset ouvert.';

  @override
  String get downloadEverything => 'Tout télécharger';

  @override
  String bundledEditions(String names) {
    return 'Éditions incluses : $names.';
  }

  @override
  String get everythingOffline =>
      'Tout ce qui est sélectionné est déjà disponible hors ligne.';

  @override
  String downloadDone(int count) {
    return 'Terminé. $count téléchargements enregistrés pour le hors ligne.';
  }

  @override
  String downloadDoneWithFailures(int failed) {
    return 'Terminé avec $failed échecs (vérifiez la connexion et relancez).';
  }

  @override
  String downloadCancelled(int done, int total) {
    return 'Annulé après $done sur $total.';
  }

  @override
  String get starting => 'Démarrage…';

  @override
  String get memorize => 'Mémoriser';

  @override
  String memorizeHeader(String surah, int from, int to, int done, int total) {
    return '$surah · Versets $from–$to · $done/$total mémorisés';
  }

  @override
  String get changeRange => 'Changer la plage';

  @override
  String wordsRevealed(int revealed, int total) {
    return '$revealed / $total mots';
  }

  @override
  String get nextWord => 'Mot suivant';

  @override
  String get revealAll => 'Tout révéler';

  @override
  String get hideAll => 'Tout masquer';

  @override
  String get transliteration => 'Translittération';

  @override
  String get translation => 'Traduction';

  @override
  String get memorized => 'Mémorisé';

  @override
  String get markAsMemorized => 'Marquer comme mémorisé';

  @override
  String get listenAndRepeat => 'Écouter et répéter';

  @override
  String get repeatEachAyah => 'Répéter chaque verset';

  @override
  String get loopTheRange => 'Boucler la plage';

  @override
  String playRange(int from, int to) {
    return 'Écouter $from–$to';
  }

  @override
  String get thisAyah => 'Ce verset';

  @override
  String get ayahRange => 'Plage de versets';

  @override
  String fromToOf(int from, int to, int total) {
    return 'De $from à $to sur $total';
  }

  @override
  String get readingPlan => 'Plan de lecture';

  @override
  String get goalReached => 'Objectif atteint, macha\'Allah !';

  @override
  String moreAyahsToGoal(int count) {
    return 'Encore $count versets pour atteindre votre objectif';
  }

  @override
  String dayStreak(int days) {
    return 'Série de $days jours';
  }

  @override
  String get dailyGoal => 'Objectif quotidien';

  @override
  String ayahsPerDay(int count) {
    return '$count versets par jour';
  }

  @override
  String get khatmIn30Days => '208 (khatm en 30 jours)';

  @override
  String get last7Days => '7 derniers jours';

  @override
  String get ayahsRead => 'Versets lus';

  @override
  String get activeDays => 'Jours actifs';

  @override
  String get quranRead => 'Coran lu';

  @override
  String get khatmPlan => 'Plan de khatm';

  @override
  String get khatmPlanHelp =>
      'Terminez tout le Coran selon un calendrier. Nous vous indiquerons le verset à atteindre chaque jour.';

  @override
  String nDays(int n) {
    return '$n jours';
  }

  @override
  String get startFromFatiha => 'Commencer à Al-Fatiha';

  @override
  String get fromTheBeginning => 'Depuis le début';

  @override
  String get fromWhereYouAre => 'Depuis votre position actuelle';

  @override
  String aboutAyahsADay(int count) {
    return 'Environ $count versets par jour';
  }

  @override
  String get startPlan => 'Démarrer le plan';

  @override
  String get endPlan => 'Terminer le plan';

  @override
  String planStatusLine(int day, int days, String date, int perDay) {
    return 'Jour $day sur $days · fin le $date · $perDay versets/jour';
  }

  @override
  String get onTrack => 'Vous êtes dans les temps.';

  @override
  String onTrackAhead(int count) {
    return 'Vous êtes dans les temps, $count versets d\'avance.';
  }

  @override
  String catchUp(int count) {
    return 'Lisez $count versets de plus aujourd\'hui pour rattraper.';
  }

  @override
  String todaysTarget(String surah, String key) {
    return 'Objectif du jour : $surah $key';
  }

  @override
  String get continueReadingButton => 'Continuer la lecture';

  @override
  String get hadith => 'Hadith';

  @override
  String get hadithIntro =>
      'Les six recueils canoniques, le Muwatta de Malik et trois recueils de quarante hadiths, en arabe avec traduction. Chaque chapitre est téléchargé une fois et reste hors ligne.';

  @override
  String hadithsChapters(int hadiths, int chapters) {
    return '$hadiths hadiths · $chapters chapitres';
  }

  @override
  String couldNotLoadHadithBooks(String error) {
    return 'Impossible de charger les recueils : $error';
  }

  @override
  String get findAChapter => 'Trouver un chapitre';

  @override
  String hadithsRange(int first, int last) {
    return 'Hadiths $first–$last';
  }

  @override
  String chapterN(int n) {
    return 'Chapitre $n';
  }

  @override
  String get chapterNeedsInternet =>
      'Ce chapitre nécessite une connexion Internet la première fois.';

  @override
  String searchHadithsInChapter(int count) {
    return 'Rechercher parmi $count hadiths de ce chapitre';
  }

  @override
  String get previousChapter => 'Chapitre précédent';

  @override
  String get nextChapter => 'Chapitre suivant';

  @override
  String get hadithCopied => 'Hadith copié';

  @override
  String get prayerTimes => 'Horaires de prière';

  @override
  String get prayerTimesForMasjid => 'Horaires de prière pour votre mosquée';

  @override
  String get prayerIntro =>
      'Saisissez l\'adresse complète ou le code postal de la mosquée. Elle est géolocalisée avec précision avec son fuseau horaire, puis les horaires de prière, d\'iqama et de Jumu\'ah sont générés selon la méthode de calcul choisie.';

  @override
  String get setUpMasjid => 'Configurer une mosquée à partir de son adresse';

  @override
  String get useMyLocation => 'Utiliser ma position actuelle';

  @override
  String get methodsList =>
      'Méthodes de calcul : ISNA, Ligue islamique mondiale, Égypte, Karachi, Umm al-Qura, Golfe, Koweït, Qatar, Singapour, Diyanet, UOIF, Russie, Téhéran et Jafari. Asr : shafiite/malikite/hanbalite ou hanafite.';

  @override
  String couldNotGetLocation(String error) {
    return 'Impossible d\'obtenir votre position : $error';
  }

  @override
  String get monthlyTimetable => 'Calendrier mensuel';

  @override
  String get shareToday => 'Partager aujourd\'hui';

  @override
  String get editMasjid => 'Modifier la mosquée';

  @override
  String get addAnotherMasjid => 'Ajouter une autre mosquée';

  @override
  String get removeMasjid => 'Supprimer la mosquée';

  @override
  String removeMasjidQuestion(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get removeMasjidBody =>
      'Son adresse, ses réglages de calcul, ses horaires d\'iqama et de Jumu\'ah seront supprimés.';

  @override
  String nextPrayerIn(String prayer, String time, String duration) {
    return '$prayer à $time · dans $duration';
  }

  @override
  String get fajrTomorrow => 'Fajr (demain)';

  @override
  String get jumuah => 'Jumu\'ah';

  @override
  String get noJumuahSet =>
      'Aucune prière du vendredi définie. Modifiez la mosquée pour en ajouter.';

  @override
  String khutbahAt(String time) {
    return 'Khutba $time';
  }

  @override
  String iqamaAt(String time) {
    return 'Iqama $time';
  }

  @override
  String timesFootnote(String lat, String lng, String tz) {
    return 'Horaires calculés astronomiquement pour $lat, $lng dans le fuseau $tz, arrondis à la minute. La date hégirienne est calculée et peut différer d\'un jour de l\'observation locale.';
  }

  @override
  String qiblaDegrees(int degrees) {
    return 'Qibla $degrees°';
  }

  @override
  String get asrShafii => 'Asr shafiite';

  @override
  String get asrHanafi => 'Asr hanafite';

  @override
  String get fajr => 'Fajr';

  @override
  String get sunrise => 'Lever du soleil';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get addMasjid => 'Ajouter une mosquée';

  @override
  String get masjid => 'Mosquée';

  @override
  String get masjidName => 'Nom de la mosquée';

  @override
  String get enterAName => 'Saisissez un nom';

  @override
  String get address => 'Adresse';

  @override
  String get streetAddress => 'Rue';

  @override
  String get city => 'Ville';

  @override
  String get stateProvince => 'Région / Province';

  @override
  String get postalCode => 'Code postal';

  @override
  String get countryCode => 'Code pays (US, GB, FR…)';

  @override
  String get findLocation => 'Localiser';

  @override
  String get deviceGps => 'GPS de l\'appareil';

  @override
  String get coordinatesAndTimeZone => 'Coordonnées et fuseau horaire';

  @override
  String get setAutomatically => 'Définis automatiquement d\'après l\'adresse';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get ianaTimeZone => 'Fuseau IANA (ex. Europe/Paris)';

  @override
  String get calculation => 'Calcul';

  @override
  String get calculationMethod => 'Méthode de calcul';

  @override
  String get asrShafiiFull => 'Asr : shafiite / malikite / hanbalite';

  @override
  String get asrHanafiFull => 'Asr : hanafite';

  @override
  String get dhuhrAfterZawal => 'Dhuhr : minutes après le zénith';

  @override
  String get maghribAfterSunset => 'Maghrib : minutes après le coucher';

  @override
  String get fineTune => 'Ajuster chaque prière (minutes)';

  @override
  String get hijriAdjustment => 'Ajustement de la date hégirienne (jours)';

  @override
  String get iqama => 'Iqama';

  @override
  String get jumuahServices => 'Prières du vendredi';

  @override
  String get addJumuahTime => 'Ajouter un horaire de Jumu\'ah';

  @override
  String get addAnotherService => 'Ajouter une autre prière';

  @override
  String get saveMasjid => 'Enregistrer la mosquée';

  @override
  String get none => 'Aucune';

  @override
  String get fixed => 'Fixe';

  @override
  String get plusMinutes => '+ min';

  @override
  String get khutbahPicker => 'Khutba…';

  @override
  String get jumuahLabelHint => 'Libellé (langue, salle, imam)';

  @override
  String get enterZipOrCity =>
      'Saisissez au moins un code postal ou une ville.';

  @override
  String get lookingUpAddress => 'Recherche de l\'adresse…';

  @override
  String get noMatchTryCountry =>
      'Aucun résultat. Ajoutez la ville et un code pays à 2 lettres (ex. US, GB, FR).';

  @override
  String get chooseLocation => 'Choisissez le bon emplacement :';

  @override
  String lookupFailed(String error) {
    return 'Échec de la recherche : $error';
  }

  @override
  String get resolvingTimeZone => 'Détermination du fuseau horaire…';

  @override
  String located(String name) {
    return 'Localisé : $name';
  }

  @override
  String timeZoneLookupFailed(String error) {
    return 'Coordonnées définies, mais échec du fuseau horaire ($error). Saisissez un fuseau IANA comme Europe/Paris.';
  }

  @override
  String get gettingPosition => 'Obtention de votre position…';

  @override
  String couldNotUseDevice(String error) {
    return 'Impossible d\'utiliser la position de l\'appareil : $error';
  }

  @override
  String get findLocationFirst =>
      'Touchez « Localiser » d\'abord pour définir les coordonnées et le fuseau horaire.';

  @override
  String get setUpMasjidFirst => 'Configurez d\'abord une mosquée.';

  @override
  String get hideIqama => 'Masquer l\'iqama';

  @override
  String get showIqama => 'Afficher l\'iqama';

  @override
  String get copyAsCsv => 'Copier en CSV';

  @override
  String get csvCopied => 'CSV copié — collez-le dans Excel ou Sheets';

  @override
  String get shareAsText => 'Partager en texte';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get date => 'Date';

  @override
  String get mushafLayout => 'Mise en page';

  @override
  String get layoutAutomatic => 'Automatique';

  @override
  String get layoutScroll => 'Une page, défilement vertical';

  @override
  String get layoutFlip => 'Une page, feuilleter';

  @override
  String get layoutBook => 'Deux pages, feuilleter';

  @override
  String get playThisPage => 'Écouter cette page';

  @override
  String get goToPage => 'Aller à la page';

  @override
  String get goTo => 'Aller à';

  @override
  String get pageRange => 'Page (1–604)';

  @override
  String get previousPage => 'Page précédente';

  @override
  String get nextPage => 'Page suivante';

  @override
  String pageJuz(int page, int juz) {
    return 'Page $page · Juz $juz';
  }

  @override
  String get library => 'Bibliothèque';

  @override
  String get openBook => 'Ouvrir le livre';

  @override
  String get tableOfContents => 'Sommaire';

  @override
  String chapterPage(int chapter, int page, int total) {
    return 'Chapitre $chapter · Page $page / $total';
  }

  @override
  String get listView => 'Vue liste';

  @override
  String get downloadPdf => 'Télécharger en PDF';

  @override
  String get downloadChapterPdf => 'Télécharger ce chapitre en PDF';

  @override
  String get downloadBookPdf => 'Télécharger tout le livre en PDF';

  @override
  String preparingPdf(int done, int total) {
    return 'Récupération des chapitres… $done / $total';
  }

  @override
  String get renderingPdf => 'Génération du PDF…';

  @override
  String pdfFailed(String error) {
    return 'Impossible de créer le PDF : $error';
  }

  @override
  String hadithsCount(int count) {
    return '$count hadiths';
  }

  @override
  String byAuthor(String author) {
    return 'par $author';
  }

  @override
  String get reciteAndCheck => 'Réciter et vérifier';

  @override
  String get reciteFromHere => 'Réciter à partir d\'ici';

  @override
  String get reciteSubtitle =>
      'Récitez de mémoire ; l\'application écoute et note chaque mot';

  @override
  String ayahRangeLabel(int from, int to) {
    return 'Versets $from–$to';
  }

  @override
  String get accuracy => 'précision';

  @override
  String get matchedWords => 'justes';

  @override
  String get wrongWords => 'erronés';

  @override
  String get missedWords => 'omis';

  @override
  String wordsReached(int reached, int total) {
    return '$reached mots sur $total récités';
  }

  @override
  String get listening => 'Écoute…';

  @override
  String get waitingForSpeech => 'En attente de la voix…';

  @override
  String get tapMicToStart => 'Touchez le micro et commencez à réciter';

  @override
  String get heard => 'Entendu';

  @override
  String get notInPassage => 'Mots absents du passage';

  @override
  String get hideText => 'Masquer le texte (mémorisation)';

  @override
  String get showText => 'Afficher le texte';

  @override
  String get hint => 'Indice';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get playThisAyah => 'Écouter ce verset';

  @override
  String get speechUnavailable =>
      'La reconnaissance vocale n\'est pas disponible. Autorisez le micro ou utilisez Chrome sur le web.';

  @override
  String get reciteHelp =>
      'Récitez clairement et à un rythme régulier, dans un endroit calme ; les mots justes passent au vert, les écarts en orange, les mots omis en rouge.';

  @override
  String get qibla => 'Qibla';

  @override
  String get qiblaBearing => 'Cap de la Qibla depuis le nord vrai';

  @override
  String get qiblaNeedsLocation =>
      'La Qibla est calculée à partir de votre position. Utilisez le GPS ou configurez d\'abord une mosquée.';

  @override
  String distanceToMakkah(int km) {
    return '$km km jusqu\'à La Mecque';
  }

  @override
  String headingDegrees(int degrees) {
    return 'Cap $degrees°';
  }

  @override
  String get facingQibla => 'Vous faites face à la Qibla';

  @override
  String get compassWaiting =>
      'En attente de la boussole… décrivez un huit avec le téléphone pour l\'étalonner.';

  @override
  String get compassUnavailable =>
      'Pas de boussole sur cet appareil : utilisez une boussole ou une carte et tournez-vous vers le cap ci-dessus.';

  @override
  String turnToQibla(String direction, int degrees) {
    return 'Tournez à $direction de $degrees°';
  }

  @override
  String get left => 'gauche';

  @override
  String get right => 'droite';

  @override
  String get qiblaHelp =>
      'Gardez le téléphone à plat, loin des aimants et du métal. Le repère Kaaba indique la Qibla ; la flèche en haut est votre direction.';

  @override
  String get adhan => 'Adhan';

  @override
  String get adhanIntro =>
      'Écoutez l\'appel à la prière par différents muezzins, téléchargez un enregistrement et choisissez celui par défaut pour vos horaires.';

  @override
  String get adhanCredits =>
      'Enregistrements issus des collections « adhans » et « azan-alafasy » de l\'Internet Archive.';

  @override
  String downloaded(String name) {
    return '$name téléchargé';
  }

  @override
  String downloadFailed(String error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String get downloadSurahAudio =>
      'Télécharger l\'audio de la sourate (hors ligne)';

  @override
  String get downloadAyahAudio => 'Télécharger l\'audio de ce verset (MP3)';

  @override
  String get offlineAudioNativeOnly =>
      'L\'audio hors ligne est conservé dans les applications mobiles et bureau ; sur le web, téléchargez verset par verset.';

  @override
  String surahAudioSaved(String surah) {
    return '$surah enregistrée pour l\'écoute hors ligne';
  }

  @override
  String get downloadForOffline => 'Télécharger pour lire hors ligne';

  @override
  String savedForOffline(String name) {
    return '$name enregistré pour la lecture hors ligne';
  }

  @override
  String get playAdhan => 'Écouter l\'adhan';

  @override
  String adhanForNext(String prayer) {
    return 'Adhan de $prayer';
  }

  @override
  String get chooseAdhan => 'Choisir l\'adhan';

  @override
  String get pageAnimation => 'Animation des pages';

  @override
  String get animationCurl => 'Pli de page';

  @override
  String get animationFlip => 'Retournement';

  @override
  String get animationSlide => 'Glissement';

  @override
  String get animationFade => 'Fondu';

  @override
  String get highlight => 'Surligner';

  @override
  String get removeHighlight => 'Retirer le surlignage';

  @override
  String get note => 'Note';

  @override
  String get noteHint => 'Écrivez votre réflexion ou rappel pour ce verset…';

  @override
  String get noteSaved => 'Note enregistrée';

  @override
  String get noteHelp =>
      'Les notes restent sur cet appareil. Les versets surlignés sont colorés sur les pages du Mushaf.';

  @override
  String get continuous => 'Lecture continue';

  @override
  String get repeatEach => 'Répéter';

  @override
  String get verseDetails => 'Détails du verset';

  @override
  String get zoomIn => 'Agrandir';

  @override
  String get zoomOut => 'Réduire';

  @override
  String get fitPage => 'Ajuster à la page';

  @override
  String get shareEmbed => 'Partager et intégrer';

  @override
  String get websiteWidget => 'Widget du site et écran TV';

  @override
  String get widgetLinks => 'Liens publics';

  @override
  String get embedCode => 'Code d’intégration';

  @override
  String get openLink => 'Ouvrir';

  @override
  String get linkCopied => 'Lien copié';

  @override
  String get codeCopied => 'Code d’intégration copié';

  @override
  String get combinedWidget => 'Widget combiné (quotidien + vendredi)';

  @override
  String get dailyWidget => 'Widget des prières quotidiennes';

  @override
  String get jumuahWidget => 'Widget de la prière du vendredi';

  @override
  String get compactWidget => 'Widget compact';

  @override
  String get tvDisplay => 'Affichage TV';

  @override
  String get darkWidget => 'Widget sombre';

  @override
  String get embedHelp =>
      'Collez le code d’intégration sur le site de votre mosquée ou partagez un lien. Le lien contient l’emplacement, la méthode, les iqamas et les horaires du vendredi : recopiez-le après toute modification. Ajoutez ?theme=dark ou &scale=120, &lang=ar à n’importe quel lien.';

  @override
  String get preview => 'Aperçu';

  @override
  String get adhanHeader => 'Adhan';

  @override
  String get poweredBy => 'Propulsé par Quran+';

  @override
  String get invalidWidgetLink =>
      'Ce lien de widget est invalide ou incomplet.';

  @override
  String get micDenied =>
      'L’accès au microphone a été refusé. Autorisez-le pour ce site dans le navigateur ou les réglages, puis réessayez.';

  @override
  String get noSpeechYet =>
      'Rien entendu pour l’instant. Récitez clairement, près du microphone ; les mots s’affichent ici au fur et à mesure.';

  @override
  String get speechNotice => 'Avis de reconnaissance';

  @override
  String get speechTip =>
      'Les mots corrects passent en vert, les erreurs en rouge avec un son et une vibration ; continuez après une erreur, le correcteur vous suit.';

  @override
  String get strictMode => 'Strict';

  @override
  String get lenientMode => 'Tolérant';

  @override
  String get strictHelp =>
      'Mode strict : un mot n’est compté juste que si chaque lettre correspond. Les voyelles (harakat) et le tajwid ne peuvent pas être vérifiés : la reconnaissance vocale ne renvoie que les lettres.';
}
