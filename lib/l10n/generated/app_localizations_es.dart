// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mushaf+';

  @override
  String get navRead => 'Leer';

  @override
  String get navHadith => 'Hadiz';

  @override
  String get navPrayer => 'Oración';

  @override
  String get navSaved => 'Guardados';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get search => 'Buscar';

  @override
  String get searchTheQuran => 'Buscar en el Corán';

  @override
  String get cancel => 'Cancelar';

  @override
  String get open => 'Abrir';

  @override
  String get apply => 'Aplicar';

  @override
  String get save => 'Guardar';

  @override
  String get retry => 'Reintentar';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Compartir';

  @override
  String get clear => 'Borrar';

  @override
  String get remove => 'Quitar';

  @override
  String get download => 'Descargar';

  @override
  String get more => 'Más';

  @override
  String get back => 'Atrás';

  @override
  String get loading => 'Cargando…';

  @override
  String get couldNotLoadQuran => 'No se pudieron cargar los datos del Corán.';

  @override
  String get continueReading => 'CONTINUAR LEYENDO';

  @override
  String get startReading => 'EMPEZAR A LEER';

  @override
  String ayahOfJuzPage(int ayah, int total, int juz, int page) {
    return 'Aleya $ayah de $total · Yuz $juz · Página $page';
  }

  @override
  String get verseOfTheDay => 'ALEYA DEL DÍA';

  @override
  String get today => 'Hoy';

  @override
  String dailyGoalTapToStartPlan(int goal) {
    return 'Meta diaria $goal aleyas · toca para iniciar un plan de khatm';
  }

  @override
  String khatmOnTrack(int day, int days) {
    return 'Plan de khatm: al día · día $day/$days';
  }

  @override
  String khatmBehind(int behind, int day, int days) {
    return 'Plan de khatm: $behind aleyas de retraso · día $day/$days';
  }

  @override
  String get findSurahHint => 'Busca una sura por nombre, significado o número';

  @override
  String get tabSurah => 'Sura';

  @override
  String get tabJuz => 'Yuz';

  @override
  String get tabPage => 'Página';

  @override
  String get noSurahMatches => 'Ninguna sura coincide con tu búsqueda.';

  @override
  String surahSubtitle(String meaning, int count, String type) {
    return '$meaning · $count aleyas · $type';
  }

  @override
  String get meccan => 'Mecana';

  @override
  String get medinan => 'Medinense';

  @override
  String juzN(int n) {
    return 'Yuz $n';
  }

  @override
  String juzStartsAt(String surah, int ayah, int count) {
    return 'Empieza en $surah, aleya $ayah · $count aleyas';
  }

  @override
  String get jumpToSurah => 'Ir a la sura';

  @override
  String pageN(int n) {
    return 'Página $n';
  }

  @override
  String get backToSurahs => 'Volver a las suras';

  @override
  String get openMushafHere => 'Abrir el Mushaf en esta sura';

  @override
  String get translations => 'Traducciones';

  @override
  String get readingSettings => 'Ajustes de lectura';

  @override
  String get playSurah => 'Reproducir sura';

  @override
  String get pauseRecitation => 'Pausar recitación';

  @override
  String get memorizeThisSurah => 'Memorizar esta sura';

  @override
  String get openInMushaf => 'Abrir en el Mushaf';

  @override
  String juzPage(int juz, int page) {
    return 'Yuz $juz · Página $page';
  }

  @override
  String get wordByWord => 'Palabra por palabra';

  @override
  String get tafsir => 'Tafsir';

  @override
  String get bookmark => 'Marcador';

  @override
  String get removeBookmark => 'Quitar marcador';

  @override
  String get bookmarkThisAyah => 'Marcar esta aleya';

  @override
  String get play => 'Reproducir';

  @override
  String get pause => 'Pausa';

  @override
  String get playFromThisAyah => 'Reproducir desde esta aleya';

  @override
  String get sajdahAyah => 'Aleya de sayda (postración)';

  @override
  String couldNotLoad(String name) {
    return 'No se pudo cargar $name';
  }

  @override
  String wordByWordOffline(String error) {
    return 'Palabra por palabra no disponible sin conexión ($error)';
  }

  @override
  String ayahN(int n) {
    return 'Aleya $n';
  }

  @override
  String get wordByWordSubtitle =>
      'Transliteración y significado de cada palabra';

  @override
  String get tafsirSubtitle => 'Comentario de Ibn Kazir y otros';

  @override
  String get playRecitationFromHere => 'Reproducir la recitación desde aquí';

  @override
  String get memorizeFromHere => 'Memorizar desde aquí';

  @override
  String get memorizeSubtitle =>
      'Oculta las palabras, revélalas una a una, repite la recitación en bucle';

  @override
  String get ayahCopied => 'Aleya copiada';

  @override
  String wordN(int n) {
    return 'Palabra $n';
  }

  @override
  String get wordByWordNeedsInternet =>
      'Los datos palabra por palabra necesitan conexión a internet la primera vez.';

  @override
  String get tafsirNeedsInternet =>
      'El tafsir necesita conexión a internet la primera vez.';

  @override
  String get viaQuranCom => 'vía Quran.com';

  @override
  String get reciter => 'Recitador';

  @override
  String get arabicSize => 'Tamaño del árabe';

  @override
  String get translationSize => 'Tamaño de la traducción';

  @override
  String get amiriQuran => 'Amiri Quran';

  @override
  String get amiriNaskh => 'Amiri Naskh';

  @override
  String get showTransliteration => 'Mostrar transliteración';

  @override
  String get showTransliterationSubtitle =>
      'Pronunciación en alfabeto latino bajo cada aleya';

  @override
  String get wordByWordMode => 'Modo palabra por palabra';

  @override
  String get wordByWordModeSubtitle =>
      'Cada palabra con su transliteración y significado';

  @override
  String get wordMeaningsLanguage =>
      'Idioma de los significados de las palabras';

  @override
  String get tapAyahHint =>
      'Toca cualquier aleya para ver traducción, transliteración, tafsir y palabra por palabra.';

  @override
  String get previousAyah => 'Aleya anterior';

  @override
  String get nextAyah => 'Aleya siguiente';

  @override
  String get stop => 'Detener';

  @override
  String get loop => 'bucle';

  @override
  String get searchHint => 'Árabe, transliteración o inglés…';

  @override
  String get searchWholeQuran => 'Buscar en todo el Corán';

  @override
  String get searchHelp =>
      'Escribe en árabe (con o sin harakat), una frase transliterada o una palabra en inglés. Los resultados abren la aleya en el lector.';

  @override
  String noAyahMatches(String query) {
    return 'Ninguna aleya coincide con \"$query\"';
  }

  @override
  String resultsCount(String count) {
    return '$count resultados';
  }

  @override
  String get savedAyahs => 'Aleyas guardadas';

  @override
  String get noBookmarksYet => 'Aún no hay marcadores';

  @override
  String get noBookmarksHelp =>
      'Toca el icono de marcador en cualquier aleya mientras lees para guardarla aquí.';

  @override
  String get settings => 'Ajustes';

  @override
  String get appearance => 'Apariencia';

  @override
  String get theme => 'Tema';

  @override
  String get arabicFont => 'Fuente árabe';

  @override
  String get language => 'Idioma de la app';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get recitation => 'Recitación';

  @override
  String get recitationHelp =>
      'El audio se transmite aleya por aleya desde everyayah.com. Toca reproducir en cualquier aleya, o \"Reproducir sura\" en la cabecera de la sura.';

  @override
  String get reading => 'Lectura';

  @override
  String get wordByWordSettingSubtitle =>
      'Muestra cada palabra con su transliteración y significado (se descarga una vez por sura)';

  @override
  String get defaultView => 'Vista predeterminada';

  @override
  String get viewTranslation => 'Traducción';

  @override
  String get viewMushafBook => 'Mushaf';

  @override
  String get languages => 'Idiomas';

  @override
  String get arabicOnlyTapToAdd => 'Solo árabe — toca para añadir traducciones';

  @override
  String translationsAvailable(int count, int languages) {
    return 'Hay $count traducciones en $languages idiomas disponibles. Cada una se descarga la primera vez que abres una sura y se conserva sin conexión.';
  }

  @override
  String get storage => 'Almacenamiento';

  @override
  String get offlinePacks => 'Paquetes sin conexión';

  @override
  String get offlinePacksSubtitle =>
      'Descarga traducciones y palabra por palabra de todo el Corán';

  @override
  String get clearDownloadedData => 'Borrar datos descargados';

  @override
  String cachedDownloads(int count) {
    return '$count descargas de suras en caché';
  }

  @override
  String get clearDownloadedDataQuestion => '¿Borrar los datos descargados?';

  @override
  String get clearDownloadedDataBody =>
      'Las traducciones y los datos palabra por palabra se volverán a descargar cuando hagan falta. Los marcadores y los ajustes se conservan.';

  @override
  String get downloadedDataCleared => 'Datos descargados borrados';

  @override
  String get about => 'Acerca de';

  @override
  String get versionBuiltWith => 'Versión 1.0.0 · Hecho con Flutter';

  @override
  String get credits =>
      'Texto árabe: edición Tanzil Uthmani. Traducciones y transliteración: Al Quran Cloud. Palabra por palabra y tafsir: Quran.com. Recitación: EveryAyah.com. Hadiz: fawazahmed0/hadith-api. Fuentes: Amiri y Amiri Quran (SIL Open Font License). Modelo de voz: derivado de tarteel-ai/whisper-base-ar-quran (Apache-2.0, ajustado a partir de OpenAI Whisper), ejecutado en el dispositivo con transformers.js y ONNX Runtime (Apache-2.0).';

  @override
  String selectedOfMax(int selected, int max) {
    return '$selected de $max seleccionadas';
  }

  @override
  String get searchLanguageOrTranslator => 'Busca un idioma o traductor';

  @override
  String nTranslations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count traducciones',
      one: '1 traducción',
    );
    return '$_temp0';
  }

  @override
  String nSelected(int count) {
    return '$count seleccionadas';
  }

  @override
  String get rightToLeftScript => 'Escritura de derecha a izquierda';

  @override
  String translationLimit(int max) {
    return 'Puedes mostrar hasta $max traducciones a la vez. Quita una primero.';
  }

  @override
  String get offlineIntro =>
      'El texto árabe, la transliteración inglesa y tres traducciones al inglés están siempre sin conexión. Descarga el resto una vez y lee donde quieras.';

  @override
  String get selectedTranslations => 'Traducciones seleccionadas';

  @override
  String get allSelectedBundled =>
      'Todas las traducciones seleccionadas vienen incluidas en la app.';

  @override
  String surahDownloadsSaved(int done, int total) {
    return '$done de $total descargas de suras guardadas';
  }

  @override
  String wordByWordPack(String language) {
    return 'Palabra por palabra ($language)';
  }

  @override
  String surahsSavedSize(int done) {
    return '$done de 114 suras guardadas · unos 8 MB';
  }

  @override
  String get tafsirSavedAutomatically =>
      'El tafsir se guarda automáticamente para cada aleya que abres.';

  @override
  String get downloadEverything => 'Descargar todo lo seleccionado';

  @override
  String bundledEditions(String names) {
    return 'Ediciones incluidas: $names.';
  }

  @override
  String get everythingOffline =>
      'Todo lo seleccionado ya está disponible sin conexión.';

  @override
  String downloadDone(int count) {
    return 'Listo. $count descargas guardadas para uso sin conexión.';
  }

  @override
  String downloadDoneWithFailures(int failed) {
    return 'Terminado con $failed descargas fallidas (comprueba tu conexión y vuelve a intentarlo).';
  }

  @override
  String downloadCancelled(int done, int total) {
    return 'Cancelado tras $done de $total.';
  }

  @override
  String get starting => 'Iniciando…';

  @override
  String get memorize => 'Memorizar';

  @override
  String memorizeHeader(String surah, int from, int to, int done, int total) {
    return '$surah · Aleyas $from–$to · $done/$total memorizadas';
  }

  @override
  String get changeRange => 'Cambiar rango';

  @override
  String wordsRevealed(int revealed, int total) {
    return '$revealed / $total palabras';
  }

  @override
  String get nextWord => 'Siguiente palabra';

  @override
  String get revealAll => 'Mostrar todo';

  @override
  String get hideAll => 'Ocultar todo';

  @override
  String get transliteration => 'Transliteración';

  @override
  String get translation => 'Traducción';

  @override
  String get memorized => 'Memorizada';

  @override
  String get markAsMemorized => 'Marcar como memorizada';

  @override
  String get listenAndRepeat => 'Escuchar y repetir';

  @override
  String get repeatEachAyah => 'Repetir cada aleya';

  @override
  String get loopTheRange => 'Repetir el rango en bucle';

  @override
  String playRange(int from, int to) {
    return 'Reproducir $from–$to';
  }

  @override
  String get thisAyah => 'Esta aleya';

  @override
  String get ayahRange => 'Rango de aleyas';

  @override
  String fromToOf(int from, int to, int total) {
    return 'De $from a $to de $total';
  }

  @override
  String get readingPlan => 'Plan de lectura';

  @override
  String get goalReached => '¡Meta alcanzada, mashaAllah!';

  @override
  String moreAyahsToGoal(int count) {
    return '$count aleyas más para alcanzar tu meta';
  }

  @override
  String dayStreak(int days) {
    return 'Racha de $days días';
  }

  @override
  String get dailyGoal => 'Meta diaria';

  @override
  String ayahsPerDay(int count) {
    return '$count aleyas al día';
  }

  @override
  String get khatmIn30Days => '208 (khatm en 30 días)';

  @override
  String get last7Days => 'Últimos 7 días';

  @override
  String get ayahsRead => 'Aleyas leídas';

  @override
  String get activeDays => 'Días activos';

  @override
  String get quranRead => 'Corán leído';

  @override
  String get khatmPlan => 'Plan de khatm';

  @override
  String get khatmPlanHelp =>
      'Termina todo el Corán según un calendario. Te diremos la aleya a la que llegar cada día.';

  @override
  String nDays(int n) {
    return '$n días';
  }

  @override
  String get startFromFatiha => 'Empezar desde Al-Fátiha';

  @override
  String get fromTheBeginning => 'Desde el principio';

  @override
  String get fromWhereYouAre => 'Desde donde estás ahora';

  @override
  String aboutAyahsADay(int count) {
    return 'Unas $count aleyas al día';
  }

  @override
  String get startPlan => 'Iniciar plan';

  @override
  String get endPlan => 'Terminar plan';

  @override
  String planStatusLine(int day, int days, String date, int perDay) {
    return 'Día $day de $days · termina el $date · $perDay aleyas/día';
  }

  @override
  String get onTrack => 'Vas al día.';

  @override
  String onTrackAhead(int count) {
    return 'Vas al día, $count aleyas por delante.';
  }

  @override
  String catchUp(int count) {
    return 'Lee $count aleyas más hoy para ponerte al día.';
  }

  @override
  String todaysTarget(String surah, String key) {
    return 'Meta de hoy: $surah $key';
  }

  @override
  String get continueReadingButton => 'Continuar leyendo';

  @override
  String get hadith => 'Hadiz';

  @override
  String get hadithIntro =>
      'Las seis colecciones canónicas, el Muwatta de Málik y tres colecciones de cuarenta hadices, con árabe y traducción. Cada capítulo se descarga una vez y queda sin conexión.';

  @override
  String hadithsChapters(int hadiths, int chapters) {
    return '$hadiths hadices · $chapters capítulos';
  }

  @override
  String couldNotLoadHadithBooks(String error) {
    return 'No se pudieron cargar los libros de hadices: $error';
  }

  @override
  String get findAChapter => 'Buscar un capítulo';

  @override
  String hadithsRange(int first, int last) {
    return 'Hadices $first–$last';
  }

  @override
  String chapterN(int n) {
    return 'Capítulo $n';
  }

  @override
  String get chapterNeedsInternet =>
      'Este capítulo necesita conexión a internet la primera vez.';

  @override
  String searchHadithsInChapter(int count) {
    return 'Buscar entre los $count hadices de este capítulo';
  }

  @override
  String get previousChapter => 'Capítulo anterior';

  @override
  String get nextChapter => 'Capítulo siguiente';

  @override
  String get hadithCopied => 'Hadiz copiado';

  @override
  String get prayerTimes => 'Horarios de oración';

  @override
  String get prayerTimesForMasjid => 'Horarios de oración de tu mezquita';

  @override
  String get prayerIntro =>
      'Introduce la dirección completa o el código postal de la mezquita. Se geocodifica a coordenadas precisas y su zona horaria, y luego se generan los horarios diarios de oración, iqama y yumu\'ah con el método de cálculo que elijas.';

  @override
  String get setUpMasjid => 'Configurar una mezquita a partir de su dirección';

  @override
  String get useMyLocation => 'Usar mi ubicación actual';

  @override
  String get methodsList =>
      'Métodos de cálculo: ISNA, Liga Musulmana Mundial, Egipcio, Karachi, Umm al-Qura, Golfo, Kuwait, Catar, Singapur, Diyanet, UOIF, Rusia, Teherán y Yafari. Asr: shafi\'í/malikí/hanbalí o hanafí.';

  @override
  String couldNotGetLocation(String error) {
    return 'No se pudo obtener tu ubicación: $error';
  }

  @override
  String get monthlyTimetable => 'Horario mensual';

  @override
  String get shareToday => 'Compartir hoy';

  @override
  String get editMasjid => 'Editar mezquita';

  @override
  String get addAnotherMasjid => 'Añadir otra mezquita';

  @override
  String get removeMasjid => 'Quitar mezquita';

  @override
  String removeMasjidQuestion(String name) {
    return '¿Quitar $name?';
  }

  @override
  String get removeMasjidBody =>
      'Se eliminarán su dirección, los ajustes de cálculo y los horarios de iqama y yumu\'ah.';

  @override
  String nextPrayerIn(String prayer, String time, String duration) {
    return '$prayer a las $time · en $duration';
  }

  @override
  String get fajrTomorrow => 'Fajr (mañana)';

  @override
  String get jumuah => 'Yumu\'ah';

  @override
  String get noJumuahSet =>
      'No hay oraciones de yumu\'ah configuradas. Edita la mezquita para añadirlas.';

  @override
  String khutbahAt(String time) {
    return 'Jutba $time';
  }

  @override
  String iqamaAt(String time) {
    return 'Iqama $time';
  }

  @override
  String timesFootnote(String lat, String lng, String tz) {
    return 'Los horarios se calculan astronómicamente para $lat, $lng en la zona $tz, redondeados al minuto. La fecha hégira es calculada y puede diferir en un día del avistamiento local de la luna.';
  }

  @override
  String qiblaDegrees(int degrees) {
    return 'Qibla $degrees°';
  }

  @override
  String get asrShafii => 'Asr shafi\'í';

  @override
  String get asrHanafi => 'Asr hanafí';

  @override
  String get fajr => 'Fajr';

  @override
  String get sunrise => 'Salida del sol';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get addMasjid => 'Añadir mezquita';

  @override
  String get masjid => 'Mezquita';

  @override
  String get masjidName => 'Nombre de la mezquita';

  @override
  String get enterAName => 'Introduce un nombre';

  @override
  String get address => 'Dirección';

  @override
  String get streetAddress => 'Calle y número';

  @override
  String get city => 'Ciudad';

  @override
  String get stateProvince => 'Estado / Provincia';

  @override
  String get postalCode => 'Código postal';

  @override
  String get countryCode => 'Código de país (US, GB, ES…)';

  @override
  String get findLocation => 'Buscar ubicación';

  @override
  String get deviceGps => 'GPS del dispositivo';

  @override
  String get coordinatesAndTimeZone => 'Coordenadas y zona horaria';

  @override
  String get setAutomatically =>
      'Se establecen automáticamente a partir de la dirección';

  @override
  String get latitude => 'Latitud';

  @override
  String get longitude => 'Longitud';

  @override
  String get ianaTimeZone => 'Zona horaria IANA (p. ej. Europe/Madrid)';

  @override
  String get calculation => 'Cálculo';

  @override
  String get calculationMethod => 'Método de cálculo';

  @override
  String get asrShafiiFull => 'Asr: shafi\'í / malikí / hanbalí';

  @override
  String get asrHanafiFull => 'Asr: hanafí';

  @override
  String get dhuhrAfterZawal => 'Dhuhr: minutos después del zawal';

  @override
  String get maghribAfterSunset =>
      'Maghrib: minutos después de la puesta del sol';

  @override
  String get fineTune => 'Ajuste fino de cada oración (minutos)';

  @override
  String get hijriAdjustment => 'Ajuste de la fecha hégira (días)';

  @override
  String get iqama => 'Iqama';

  @override
  String get jumuahServices => 'Oraciones de yumu\'ah';

  @override
  String get addJumuahTime => 'Añadir horario de yumu\'ah';

  @override
  String get addAnotherService => 'Añadir otra oración';

  @override
  String get saveMasjid => 'Guardar mezquita';

  @override
  String get none => 'Ninguno';

  @override
  String get fixed => 'Fijo';

  @override
  String get plusMinutes => '+ min';

  @override
  String get khutbahPicker => 'Jutba…';

  @override
  String get jumuahLabelHint => 'Etiqueta (idioma, sala, jatib)';

  @override
  String get enterZipOrCity =>
      'Introduce al menos un código postal o una ciudad.';

  @override
  String get lookingUpAddress => 'Buscando la dirección…';

  @override
  String get noMatchTryCountry =>
      'Sin resultados. Prueba a añadir la ciudad y un código de país de 2 letras (p. ej. US, GB, ES).';

  @override
  String get chooseLocation => 'Elige la ubicación correcta:';

  @override
  String lookupFailed(String error) {
    return 'Falló la búsqueda: $error';
  }

  @override
  String get resolvingTimeZone => 'Resolviendo la zona horaria…';

  @override
  String located(String name) {
    return 'Ubicado: $name';
  }

  @override
  String timeZoneLookupFailed(String error) {
    return 'Coordenadas establecidas, pero falló la búsqueda de la zona horaria ($error). Introduce una zona IANA como America/Mexico_City.';
  }

  @override
  String get gettingPosition => 'Obteniendo tu posición…';

  @override
  String couldNotUseDevice(String error) {
    return 'No se pudo usar la ubicación del dispositivo: $error';
  }

  @override
  String get findLocationFirst =>
      'Toca primero \"Buscar ubicación\" para establecer las coordenadas y la zona horaria.';

  @override
  String get setUpMasjidFirst => 'Configura primero una mezquita.';

  @override
  String get hideIqama => 'Ocultar iqama';

  @override
  String get showIqama => 'Mostrar iqama';

  @override
  String get copyAsCsv => 'Copiar como CSV';

  @override
  String get csvCopied => 'CSV copiado — pégalo en Excel o Sheets';

  @override
  String get shareAsText => 'Compartir como texto';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get date => 'Fecha';

  @override
  String get mushafLayout => 'Disposición';

  @override
  String get layoutAutomatic => 'Automática';

  @override
  String get layoutScroll => 'Una página, desplazamiento vertical';

  @override
  String get layoutFlip => 'Una página, pasar hoja';

  @override
  String get layoutBook => 'Dos páginas, pasar hoja';

  @override
  String get playThisPage => 'Reproducir esta página';

  @override
  String get goToPage => 'Ir a la página';

  @override
  String get goTo => 'Ir';

  @override
  String get pageRange => 'Página (1–604)';

  @override
  String get previousPage => 'Página anterior';

  @override
  String get nextPage => 'Página siguiente';

  @override
  String pageJuz(int page, int juz) {
    return 'Página $page · Yuz $juz';
  }

  @override
  String get library => 'Biblioteca';

  @override
  String get openBook => 'Abrir libro';

  @override
  String get tableOfContents => 'Índice';

  @override
  String chapterPage(int chapter, int page, int total) {
    return 'Capítulo $chapter · Página $page / $total';
  }

  @override
  String get listView => 'Vista de lista';

  @override
  String get downloadPdf => 'Descargar PDF';

  @override
  String get downloadChapterPdf => 'Descargar este capítulo en PDF';

  @override
  String get downloadBookPdf => 'Descargar todo el libro en PDF';

  @override
  String preparingPdf(int done, int total) {
    return 'Obteniendo capítulos… $done / $total';
  }

  @override
  String get renderingPdf => 'Generando el PDF…';

  @override
  String pdfFailed(String error) {
    return 'No se pudo crear el PDF: $error';
  }

  @override
  String hadithsCount(int count) {
    return '$count hadices';
  }

  @override
  String byAuthor(String author) {
    return 'de $author';
  }

  @override
  String get reciteAndCheck => 'Recitar y comprobar';

  @override
  String get reciteFromHere => 'Recitar desde aquí';

  @override
  String get reciteSubtitle =>
      'Recita de memoria; la app escucha y marca cada palabra';

  @override
  String ayahRangeLabel(int from, int to) {
    return 'Aleyas $from–$to';
  }

  @override
  String get accuracy => 'precisión';

  @override
  String get matchedWords => 'correctas';

  @override
  String get wrongWords => 'incorrectas';

  @override
  String get missedWords => 'omitidas';

  @override
  String wordsReached(int reached, int total) {
    return '$reached de $total palabras recitadas';
  }

  @override
  String get listening => 'Escuchando…';

  @override
  String get waitingForSpeech => 'Esperando la voz…';

  @override
  String get tapMicToStart => 'Toca el micrófono y empieza a recitar';

  @override
  String get heard => 'Oído';

  @override
  String get notInPassage => 'Palabras que no están en el pasaje';

  @override
  String get hideText => 'Ocultar el texto (memorización)';

  @override
  String get showText => 'Mostrar el texto';

  @override
  String get hint => 'Pista';

  @override
  String get reset => 'Reiniciar';

  @override
  String get playThisAyah => 'Reproducir esta aleya';

  @override
  String get speechUnavailable =>
      'El reconocimiento de voz no está disponible. Permite el acceso al micrófono o usa Chrome en la web.';

  @override
  String get reciteHelp =>
      'Recita con claridad y a un ritmo constante. El reconocimiento funciona mejor en un lugar silencioso; las palabras correctas se ponen en verde, las incorrectas en rojo (con un zumbido) y las omitidas en naranja. Sigue recitando tras un error y el corrector te seguirá.';

  @override
  String get qibla => 'Qibla';

  @override
  String get qiblaBearing => 'Rumbo de la Qibla desde el norte geográfico';

  @override
  String get qiblaNeedsLocation =>
      'La Qibla se calcula a partir de tu ubicación. Usa el GPS de tu dispositivo o configura primero una mezquita.';

  @override
  String distanceToMakkah(int km) {
    return '$km km hasta La Meca';
  }

  @override
  String headingDegrees(int degrees) {
    return 'Rumbo $degrees°';
  }

  @override
  String get facingQibla => 'Estás mirando hacia la Qibla';

  @override
  String get compassWaiting =>
      'Esperando la brújula… mueve el teléfono haciendo un ocho para calibrarla.';

  @override
  String get compassUnavailable =>
      'Este dispositivo no tiene brújula: usa una brújula o un mapa y gira hacia el rumbo indicado arriba.';

  @override
  String turnToQibla(String direction, int degrees) {
    return 'Gira a la $direction $degrees°';
  }

  @override
  String get left => 'izquierda';

  @override
  String get right => 'derecha';

  @override
  String get qiblaHelp =>
      'Mantén el teléfono plano y lejos de imanes o metales. La marca de la Kaaba en el dial indica la Qibla; la flecha de arriba es hacia donde miras.';

  @override
  String get adhan => 'Adhan';

  @override
  String get adhanIntro =>
      'Escucha la llamada a la oración de distintos muecines, descarga cualquier grabación y elige la predeterminada para tus horarios de oración.';

  @override
  String get adhanCredits =>
      'Grabaciones de Wikimedia Commons bajo CC0 y CC BY-SA 4.0, convertidas a MP3; toca una línea de crédito para abrir el archivo original y su licencia.';

  @override
  String downloaded(String name) {
    return 'Descargado $name';
  }

  @override
  String downloadFailed(String error) {
    return 'Falló la descarga: $error';
  }

  @override
  String get downloadSurahAudio =>
      'Descargar el audio de la sura para sin conexión';

  @override
  String get downloadAyahAudio => 'Descargar el audio de esta aleya (MP3)';

  @override
  String get offlineAudioNativeOnly =>
      'El audio sin conexión se conserva en las apps móviles y de escritorio; en la web, descarga aleyas sueltas.';

  @override
  String surahAudioSaved(String surah) {
    return '$surah guardada para escuchar sin conexión';
  }

  @override
  String get downloadForOffline => 'Descargar para leer sin conexión';

  @override
  String savedForOffline(String name) {
    return '$name guardado para leer sin conexión';
  }

  @override
  String get playAdhan => 'Reproducir adhan';

  @override
  String adhanForNext(String prayer) {
    return 'Adhan para $prayer';
  }

  @override
  String get chooseAdhan => 'Elegir adhan';

  @override
  String get pageAnimation => 'Animación de página';

  @override
  String get animationCurl => 'Curvar página';

  @override
  String get animationFlip => 'Voltear tarjeta';

  @override
  String get animationSlide => 'Deslizar';

  @override
  String get animationFade => 'Fundido';

  @override
  String get highlight => 'Resaltar';

  @override
  String get removeHighlight => 'Quitar resaltado';

  @override
  String get note => 'Nota';

  @override
  String get noteHint => 'Escribe tu reflexión o recordatorio para esta aleya…';

  @override
  String get noteSaved => 'Nota guardada';

  @override
  String get noteHelp =>
      'Las notas se quedan en este dispositivo. Las aleyas resaltadas se colorean en las páginas del Mushaf.';

  @override
  String get continuous => 'Continuar automáticamente';

  @override
  String get repeatEach => 'Repetir';

  @override
  String get verseDetails => 'Detalles de la aleya';

  @override
  String get zoomIn => 'Acercar';

  @override
  String get zoomOut => 'Alejar';

  @override
  String get fitPage => 'Ajustar a la página';

  @override
  String get shareEmbed => 'Compartir e insertar';

  @override
  String get websiteWidget => 'Widget para web y pantalla de TV';

  @override
  String get widgetLinks => 'Enlaces públicos';

  @override
  String get embedCode => 'Código para insertar';

  @override
  String get openLink => 'Abrir';

  @override
  String get linkCopied => 'Enlace copiado';

  @override
  String get codeCopied => 'Código para insertar copiado';

  @override
  String get combinedWidget => 'Widget combinado (diario + viernes)';

  @override
  String get dailyWidget => 'Widget de oraciones diarias';

  @override
  String get jumuahWidget => 'Widget de la oración del viernes';

  @override
  String get compactWidget => 'Widget compacto';

  @override
  String get tvDisplay => 'Pantalla de TV';

  @override
  String get darkWidget => 'Widget oscuro';

  @override
  String get embedHelp =>
      'Pega el código en la web de tu mezquita o comparte un enlace. El propio enlace lleva la ubicación, el método y los ajustes de iqama y yumu\'ah de esta mezquita, así que cópialo de nuevo después de cambiarlos. Añade ?theme=dark o &scale=120, &lang=ar a cualquier enlace.';

  @override
  String get preview => 'Vista previa';

  @override
  String get adhanHeader => 'Adhan';

  @override
  String get poweredBy => 'Con tecnología de Mushaf+';

  @override
  String get invalidWidgetLink =>
      'Este enlace de widget no es válido o está incompleto.';

  @override
  String get micDenied =>
      'Se denegó el acceso al micrófono. Permítelo para este sitio en los ajustes del navegador o del sistema y vuelve a intentarlo.';

  @override
  String get noSpeechYet =>
      'Aún no se ha oído nada. Recita con claridad, cerca del micrófono. Las palabras aparecen aquí a medida que se reconocen.';

  @override
  String get speechNotice => 'Aviso sobre el reconocimiento';

  @override
  String get speechTip =>
      'Las palabras correctas se ponen en verde, las incorrectas en rojo con un zumbido y una vibración; sigue recitando tras un error y el corrector te seguirá.';

  @override
  String get strictMode => 'Estricto';

  @override
  String get lenientMode => 'Flexible';

  @override
  String get strictHelp =>
      'Modo estricto: una palabra cuenta solo cuando coinciden todas las letras. Los signos vocálicos (harakat) y el tajwid no se pueden comprobar: el reconocimiento de voz devuelve solo las letras.';

  @override
  String get tjHamzatWasl => 'Hamzat al-wasl';

  @override
  String get tjSilent => 'Letra muda';

  @override
  String get tjLaamShamsiyyah => 'Lam solar';

  @override
  String get tjMaddNormal => 'Madd natural';

  @override
  String get tjMaddPermissible => 'Madd permitido';

  @override
  String get tjMaddNecessary => 'Madd necesario';

  @override
  String get tjQalqalah => 'Qalqalah';

  @override
  String get tjMaddObligatory => 'Madd obligatorio';

  @override
  String get tjIkhfaShafawi => 'Ikhfa labial';

  @override
  String get tjIkhfa => 'Ikhfa';

  @override
  String get tjIdghamShafawi => 'Idgham labial';

  @override
  String get tjIqlab => 'Iqlab';

  @override
  String get tjIdghamGhunnah => 'Idgham con ghunnah';

  @override
  String get tjIdghamNoGhunnah => 'Idgham sin ghunnah';

  @override
  String get tjIdghamMutajanisayn => 'Idgham de letras semejantes';

  @override
  String get tjIdghamMutaqaribayn => 'Idgham de letras cercanas';

  @override
  String get tjGhunnah => 'Ghunnah';

  @override
  String get tjdHamzatWasl =>
      'Una hamza de unión al inicio de una palabra. Solo se pronuncia cuando empiezas por esa palabra; al enlazar desde la palabra anterior es muda, así que léela de corrido.';

  @override
  String get tjdSilent =>
      'Una letra escrita en el mushaf pero que no se pronuncia, como el alif tras la waw del plural. Omítela al recitar.';

  @override
  String get tjdLaamShamsiyyah =>
      'La lam del artículo definido ante una letra solar no se pronuncia: en su lugar se duplica la letra solar, como en ٱلشَّمْس → ash-shams.';

  @override
  String get tjdMaddNormal =>
      'Un alargamiento natural: mantén la vocal larga dos tiempos, ni más ni menos.';

  @override
  String get tjdMaddPermissible =>
      'Un alargamiento cuando una letra de madd se encuentra con una hamza en la palabra siguiente, o cuando una parada crea un sukun. Mantenlo dos, cuatro o seis tiempos, pero sé constante durante toda la recitación.';

  @override
  String get tjdMaddNecessary =>
      'Un alargamiento exigido por un sukun original o una shadda tras la letra de madd, incluidas las letras iniciales de las suras. Mantenlo seis tiempos.';

  @override
  String get tjdQalqalah =>
      'Un rebote con eco en las letras ق ط ب ج د cuando llevan sukun. Suelta la letra con un ligero rebote, más fuerte al detenerte en ella.';

  @override
  String get tjdMaddObligatory =>
      'Una letra de madd seguida de una hamza en la misma palabra. Mantenla cuatro o cinco tiempos.';

  @override
  String get tjdIkhfaShafawi =>
      'Una mim con sukun ante ب: cierra los labios ligeramente y oculta la mim con un sonido nasal de dos tiempos.';

  @override
  String get tjdIkhfa =>
      'Una nun con sukun o tanwin ante una de las quince letras de ikhfa: oculta la nun con un sonido nasal de dos tiempos, con la lengua preparada para la letra siguiente.';

  @override
  String get tjdIdghamShafawi =>
      'Una mim con sukun ante otra mim: fúndelas en una sola mim duplicada con un sonido nasal de dos tiempos.';

  @override
  String get tjdIqlab =>
      'Una nun con sukun o tanwin ante ب se convierte en mim, oculta con un sonido nasal de dos tiempos y los labios ligeramente cerrados.';

  @override
  String get tjdIdghamGhunnah =>
      'Una nun con sukun o tanwin ante ي ن م و al inicio de la palabra siguiente se funde en esa letra, con un sonido nasal de dos tiempos.';

  @override
  String get tjdIdghamNoGhunnah =>
      'Una nun con sukun o tanwin ante ل o ر se funde por completo en esa letra, sin sonido nasal.';

  @override
  String get tjdIdghamMutajanisayn =>
      'Dos letras del mismo punto de articulación, la primera con sukun, se funden en una sola letra duplicada, como en قَد تَّبَيَّنَ.';

  @override
  String get tjdIdghamMutaqaribayn =>
      'Dos letras de puntos de articulación cercanos, la primera con sukun, se funden en la segunda, como en قُل رَّبِّ.';

  @override
  String get tjdGhunnah =>
      'Una resonancia nasal mantenida dos tiempos en una mim o nun con shadda.';

  @override
  String get tjgMadd => 'Prolongación (madd)';

  @override
  String get tjgNunTanwin => 'Nun sakina y tanwin';

  @override
  String get tjgMeemSakinah => 'Mim sakina';

  @override
  String get tjgGhunnah => 'Ghunnah';

  @override
  String get tjgQalqalah => 'Qalqalah';

  @override
  String get tjgLam => 'Lam';

  @override
  String get tjgSilent => 'Letras mudas';

  @override
  String get tjgIdghamAdjacent => 'Fusión de letras adyacentes';

  @override
  String get tajweed => 'Tajwid';

  @override
  String get tajweedColors => 'Colores de tajwid';

  @override
  String get tajweedColorsSubtitle =>
      'Colorea las letras del Mushaf y del lector según la regla de tajwid';

  @override
  String get tajweedGuide => 'Guía de tajwid';

  @override
  String get tajweedLegend => 'Leyenda de colores de tajwid';

  @override
  String get seeGuide => 'Guía completa';

  @override
  String get tajweedIntro =>
      'El tajwid es recitar cada letra desde su punto de articulación con sus cualidades propias: alargando donde hay madd, con sonido nasal donde hay ghunnah, ocultando, fundiendo y rebotando donde las reglas lo piden. El Mushaf colorea cada letra que lleva una regla; toca cualquier palabra para ver qué reglas se le aplican y cómo recitarla. Las reglas siguen la riwaya de Hafs \'an \'Asim.';

  @override
  String get rulesInThisWord => 'Tajwid en esta palabra';

  @override
  String get noRulesInWord =>
      'Ninguna regla de tajwid está marcada en esta palabra: recita sus letras con claridad desde sus puntos de articulación.';

  @override
  String get wordTab => 'Palabra';

  @override
  String wordOfN(int n, int total) {
    return 'Palabra $n de $total';
  }

  @override
  String get playWord => 'Reproducir palabra';

  @override
  String get example => 'Ejemplo';

  @override
  String get triggerLetters => 'Letras';

  @override
  String countsValue(String n) {
    return '$n tiempos';
  }

  @override
  String tuhfaRef(String lines) {
    return 'Tuhfat al-Atfal, versos $lines';
  }

  @override
  String jazariyyahRef(String lines) {
    return 'al-Yazariyya, versos $lines';
  }

  @override
  String get tajweedSource =>
      'Las reglas y los colores siguen la guía de tajwid de alquran.cloud (riwaya de Hafs, texto Tanzil Uthmani) y el esquema de colores KFGQPC usado por quran.com. Las referencias de versos remiten a Tuhfat al-Atfal y a al-Muqaddima al-Yazariyya.';

  @override
  String get fullScreen => 'Pantalla completa';

  @override
  String get exitFullScreen => 'Salir de pantalla completa';

  @override
  String get playbackSpeed => 'Velocidad';

  @override
  String get chooseReciter => 'Elige un recitador';

  @override
  String get approximateLocation =>
      'Solo se encontró la zona (código postal o ciudad), así que las coordenadas son su centro. Si conoces las coordenadas exactas, introdúcelas abajo.';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String pdfReady(String size) {
    return 'PDF listo ($size)';
  }

  @override
  String get openPdf => 'Abrir';

  @override
  String get savePdf => 'Guardar';

  @override
  String get offlineSavedBody =>
      'El libro se guarda en este dispositivo en el idioma actual de los hadices y se abre sin internet desde la biblioteca. Vuelve a descargarlo tras cambiar de idioma.';

  @override
  String get adhkar => 'Adhkar';

  @override
  String get hisnAlMuslim => 'Hisn al-Muslim';

  @override
  String get hisnAlMuslimSubtitle =>
      'La fortaleza del musulmán · súplicas del Corán y la Sunna';

  @override
  String get adhkarIntro =>
      'Recuerdos y súplicas diarios de Hisn al-Muslim, de Sa‘id al-Qahtani, con contadores de repetición y audio.';

  @override
  String repeatProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get playChapter => 'Reproducir capítulo';

  @override
  String get resetCounters => 'Reiniciar contadores';

  @override
  String get adhkarLanguageNote =>
      'Las traducciones proceden de hisnmuslim.com y solo existen en inglés y árabe.';

  @override
  String get findAdhkar => 'Buscar un capítulo…';

  @override
  String get morning => 'Mañana';

  @override
  String get evening => 'Tarde';

  @override
  String get sleep => 'Dormir';

  @override
  String get afterPrayer => 'Tras la oración';

  @override
  String get allDone => 'Todo hecho';

  @override
  String timesN(int n) {
    return '×$n';
  }

  @override
  String get readAloud => 'Leer en voz alta';

  @override
  String get stopReading => 'Dejar de leer';

  @override
  String get ttsUnavailable =>
      'No hay ninguna voz instalada para este idioma en este dispositivo. Los hadices se leen con las voces de texto a voz del dispositivo.';

  @override
  String get homeSearchHint =>
      'Busca en el Corán — una sura, una aleya, una palabra o una frase. Árabe con o sin harakat, transliteración (insan, bismillah), significado en inglés, o el nombre o número de una sura…';

  @override
  String get countryLabel => 'País';

  @override
  String get region => 'Región';

  @override
  String get changeRegion => 'toca para cambiar';

  @override
  String get detectRegion => 'Detectar';

  @override
  String get regionHelp =>
      'Rellena el país de las mezquitas y elige el cálculo de oración habitual en ese país.';

  @override
  String regionSetTo(String name) {
    return 'Región establecida en $name. Toca la bandera para cambiarla.';
  }

  @override
  String get regionNotDetected =>
      'No se pudo detectar tu país. Elígelo de la lista.';

  @override
  String get findCountry => 'Buscar un país…';

  @override
  String get myPrayerTimes => 'Mis horarios de oración';

  @override
  String get masjidsTab => 'Mezquitas';

  @override
  String get enterMyCity => 'Introducir mi ciudad';

  @override
  String get orEnterCity => 'o introduce tu ciudad';

  @override
  String get editLocation => 'Editar ubicación';

  @override
  String get personalIntro =>
      'Horarios de oración para donde estás: permite tu ubicación precisa o escribe tu ciudad. El método de cálculo sigue tu país y se puede cambiar.';

  @override
  String get masjidAdminHint =>
      'Si administras una mezquita: configúrala, con horarios de iqama y yumu\'ah y widgets para la web, en la pestaña Mezquitas tras crear un perfil.';

  @override
  String get masjidAdminGate =>
      'Los perfiles de mezquita incluyen horarios de iqama, oraciones de yumu\'ah y widgets públicos, por lo que van ligados a un administrador con nombre. Crea tu perfil (nombre y correo, guardados en este dispositivo) para configurar una.';

  @override
  String get createProfile => 'Crear perfil';

  @override
  String get profile => 'Perfil';

  @override
  String get profileIntro =>
      'Tu nombre y correo te identifican como administrador de las mezquitas que configures. Se quedan en este dispositivo.';

  @override
  String get name => 'Nombre';

  @override
  String get email => 'Correo electrónico';

  @override
  String get invalidEmail => 'Introduce una dirección de correo válida.';

  @override
  String get profileSaved => 'Perfil guardado';

  @override
  String get masjidRole => 'Cargo en la mezquita (opcional)';

  @override
  String get masjidRoleHint => 'Imam, miembro de la junta, voluntario…';

  @override
  String get removeProfile => 'Eliminar perfil';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get remindersOn => 'Activados · toca para ajustar';

  @override
  String get remindersOff =>
      'Desactivados · horarios de oración, adhkar, aleya diaria';

  @override
  String get remindersSettingsSubtitle =>
      'Horarios de oración con adhan, adhkar de la mañana y la tarde, aleya o dhikr del día';

  @override
  String get prayerReminders => 'Recordatorios de oración';

  @override
  String prayerRemindersSubtitle(String adhan) {
    return 'Cada oración; al abrir el recordatorio suena $adhan';
  }

  @override
  String get remindBefore => 'Avisar';

  @override
  String get atPrayerTime => 'A la hora de la oración';

  @override
  String minutesBefore(int n) {
    return '$n min antes';
  }

  @override
  String get adhkarReminders => 'Recordatorios de adhkar';

  @override
  String get adhkarRemindersSubtitle =>
      'Adhkar de la mañana tras Fajr, adhkar de la tarde tras Asr, adhkar de dormir una hora después de Isha';

  @override
  String get dailyReminder => 'Aleya o dhikr del día';

  @override
  String get dailyReminderSubtitle =>
      'Una aleya o dhikr al azar una vez al día';

  @override
  String get reminderTime => 'Hora';

  @override
  String get nextReminders => 'Próximos';

  @override
  String get notificationsWebNote =>
      'En un navegador, los recordatorios solo aparecen mientras Mushaf+ está abierto en una pestaña. Instala la app de Android o iOS para recibir recordatorios con la app cerrada.';

  @override
  String get notificationsDenied =>
      'Las notificaciones de Mushaf+ están bloqueadas en los ajustes del sistema.';

  @override
  String get setLocationFirst => 'Establece primero tu ubicación de oración';

  @override
  String get adhanOnNotification =>
      'Los recordatorios de oración usan el sonido del sistema; al abrir uno suena completo el adhan que elegiste.';

  @override
  String prayerInMinutes(String prayer, int n) {
    return '$prayer en $n minutos';
  }

  @override
  String timeForPrayer(String prayer) {
    return 'Hora de $prayer';
  }

  @override
  String get timeAdhkarMorning => 'Adhkar de la mañana';

  @override
  String get timeAdhkarEvening => 'Adhkar de la tarde';

  @override
  String get timeAdhkarSleep => 'Adhkar de dormir';

  @override
  String get adhkarMorningBody =>
      'Empieza el día con los recuerdos de la mañana.';

  @override
  String get adhkarEveningBody =>
      'Los recuerdos de la tarde, antes de la noche.';

  @override
  String get adhkarSleepBody => 'Los recuerdos antes de dormir.';

  @override
  String get ayahOfTheDayNotif => 'Aleya del día';

  @override
  String get dhikrOfTheDay => 'Dhikr del día';

  @override
  String get memorizeCard => 'Memorizar y recitar';

  @override
  String get memorizeCardSubtitle =>
      'Oculta las palabras, revélalas una a una, luego recita y deja que la app te corrija.';

  @override
  String get town => 'Localidad / Ciudad';

  @override
  String get suburb => 'Barrio';

  @override
  String get province => 'Provincia';

  @override
  String get zip => 'Código ZIP';

  @override
  String get postcode => 'Código postal';

  @override
  String get regionOptional => 'Región (opcional)';

  @override
  String get postalOptional => 'Código postal (opcional)';

  @override
  String get bundledAlways =>
      'El texto del Corán, los colores de tajwid, la transliteración, tres traducciones al inglés, el índice de hadices y Hisn al-Muslim vienen integrados y siempre funcionan sin conexión.';

  @override
  String get downloadTextPacks => 'Descargar todos los paquetes de texto';

  @override
  String get textPacks => 'Texto';

  @override
  String get audioPacks => 'Audio';

  @override
  String tafsirPack(String name) {
    return 'Tafsir · $name';
  }

  @override
  String hadithPack(String lang) {
    return 'Libros de hadices ($lang)';
  }

  @override
  String chaptersSaved(int done, int total) {
    return '$done / $total capítulos guardados';
  }

  @override
  String get adhanPack => 'Grabaciones de adhan';

  @override
  String get adhkarAudioPack => 'Audio de Hisn al-Muslim';

  @override
  String reciterPack(String name) {
    return 'Recitación completa · $name';
  }

  @override
  String filesSaved(int done, int total) {
    return '$done / $total archivos guardados';
  }

  @override
  String approxSize(String size) {
    return 'unos $size';
  }

  @override
  String get offlinePromptTitle => '¿Usar Mushaf+ sin conexión?';

  @override
  String get offlinePromptBody =>
      'Descarga ahora las traducciones, los significados de las palabras, el tafsir y los libros de hadices (unos 60 MB) para que todo funcione sin conexión. Los paquetes de audio se pueden añadir después en Ajustes → Paquetes sin conexión.';

  @override
  String get downloadNow => 'Descargar ahora';

  @override
  String get later => 'Más tarde';

  @override
  String get offlineAutoTitle => 'Mushaf+ funciona totalmente sin conexión';

  @override
  String get offlineAutoBody =>
      'La app descargará ahora todo lo que necesita para funcionar sin conexión: traducciones, significados de las palabras, tafsir, los libros de hadices, las grabaciones de adhan y el audio de Hisn al-Muslim (unos 200 MB). Se hace en segundo plano; puedes seguir leyendo. Se recomienda Wi-Fi.';

  @override
  String includeFullRecitation(String name) {
    return 'Recitación completa de $name';
  }

  @override
  String get includeFullRecitationHint =>
      'Unos 700 MB. También puedes añadirla más tarde en Ajustes → Paquetes sin conexión.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String offlineSyncing(int percent) {
    return 'Descargando para uso sin conexión · $percent%';
  }

  @override
  String get offlineAutoIntro =>
      'Mushaf+ descarga en segundo plano todo lo que necesita para funcionar sin conexión. Cada paquete muestra lo que está guardado; toca uno para obtener lo que falta.';

  @override
  String get resumeOfflineDownload => 'Descargar todo lo que falta';

  @override
  String get wifiOnly => 'Audio solo con Wi-Fi';

  @override
  String get wifiOnlyHint =>
      'Con datos móviles solo se descargan por sí solos los paquetes de texto pequeños.';

  @override
  String get waitingForWifi =>
      'Los paquetes de texto están guardados. Los paquetes de audio se descargarán cuando tengas Wi-Fi (o toca el botón de arriba para descargarlos ahora).';

  @override
  String get watchNoPlace =>
      'Establece una ubicación de oración para ver los horarios.';

  @override
  String inDuration(String duration) {
    return 'en $duration';
  }

  @override
  String get tasbih => 'Tasbih';

  @override
  String get tapToCount => 'Toca para contar, mantén pulsado para reiniciar';

  @override
  String get useLocationShort => 'Usar mi ubicación';

  @override
  String get supportTitle => 'Apoya Mushaf+';

  @override
  String get supportSubtitle =>
      'Una contribución voluntaria mantiene la app gratuita, abierta y sin anuncios.';

  @override
  String get supportIntro =>
      'Mushaf+ es gratuita, no tiene anuncios y nunca los tendrá. Si te resulta útil, una contribución voluntaria cubre los servidores, el alojamiento del audio y las tasas de las tiendas, y nos permite seguir mejorándola.';

  @override
  String get tipJarIntro =>
      'Elige una propina. No desbloquea nada: todo en Mushaf+ sigue siendo gratuito para todos.';

  @override
  String get tipThanks => 'JazakAllahu khairan. ¡Gracias por apoyar Mushaf+!';

  @override
  String get tipUnavailable =>
      'Las propinas no están disponibles ahora mismo. Inténtalo de nuevo más tarde.';

  @override
  String get donateIntro => 'Elige cómo te gustaría contribuir.';

  @override
  String get donateComingSoon =>
      'Las opciones de donación se están preparando. Gracias por tu paciencia y por usar Mushaf+.';

  @override
  String get bankTransfer => 'Transferencia bancaria';

  @override
  String get copied => 'Copiado';

  @override
  String get supportFootnote =>
      'Las contribuciones son regalos voluntarios al desarrollador, no compras, y no son deducibles de impuestos.';

  @override
  String get recognitionEngine => 'Motor de reconocimiento';

  @override
  String get engineBrowser => 'Navegador';

  @override
  String get engineBrowserDesc => 'Rápido, solo letras';

  @override
  String get engineVoiceModel => 'Modelo de voz de Mushaf+';

  @override
  String get engineVoiceModelDesc =>
      'Descarga única de 150 MB, marca errores de vocales';

  @override
  String get engineVoiceModelHelp =>
      'El modelo de voz de Mushaf+ descarga unos 150 MB una sola vez y luego se ejecuta en este dispositivo dentro del navegador. Comprueba los signos vocálicos (harakat) además de las letras. Necesita un Chrome, Edge o Safari reciente.';

  @override
  String get voiceModelDownloadTitle =>
      '¿Descargar el modelo de voz de Mushaf+?';

  @override
  String voiceModelDownloadBody(int size) {
    return 'Unos $size MB, descargados una vez y guardados en este dispositivo. El reconocimiento se ejecuta luego en tu navegador y nada de lo que recitas sale de tu dispositivo.';
  }

  @override
  String voiceModelDownloading(int done, int total) {
    return 'Descargando el modelo de voz… $done de $total MB';
  }

  @override
  String get voiceModelPreparing => 'Preparando el modelo de voz…';

  @override
  String get voiceModelFailed => 'No se pudo cargar el modelo de voz.';

  @override
  String get voiceModelSlow =>
      'Este navegador no tiene aceleración gráfica: los resultados pueden tardar varios segundos.';

  @override
  String get usingBrowserEngine => 'Usando el motor del navegador por ahora.';

  @override
  String get vowelSlips => 'errores de vocal';

  @override
  String get letterErrors => 'errores de letra';

  @override
  String reciteSummary(int correct, int vowel, int letter) {
    return '$correct correctas · $vowel errores de vocal · $letter errores de letra';
  }

  @override
  String get feedbackDisclaimer =>
      'La corrección automática puede equivocarse; no sustituye a un maestro.';

  @override
  String vowelSlipLine(String heard, String letter, String expected) {
    return 'Se oyó $heard en $letter, se esperaba $expected';
  }

  @override
  String get wordCorrect => 'Correcta';

  @override
  String get wordVowelSlip => 'Error de vocal';

  @override
  String get wordWrong => 'Palabra incorrecta';

  @override
  String get wordMissed => 'Omitida';

  @override
  String get wordPending => 'Aún no alcanzada';

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
  String get markNone => 'sin signo';

  @override
  String get markNoShadda => 'sin shadda';

  @override
  String get voiceModelHelp =>
      'El modelo de voz de Mushaf+ también comprueba los signos vocálicos (harakat): un error de vocal se muestra en ámbar. Toca cualquier palabra para ver los detalles.';

  @override
  String get playRecitation => 'Reproducir recitación';

  @override
  String get addressLookupCredit =>
      'Búsqueda de direcciones: © colaboradores de OpenStreetMap (ODbL), geocodificación de Open-Meteo (CC BY 4.0), Zippopotam.';

  @override
  String get dataSourcesLicences => 'Créditos';

  @override
  String get dataSourcesLicencesHint =>
      'De dónde proceden los textos, el audio y los mapas';

  @override
  String get openSourceLicences => 'Licencias de código abierto';

  @override
  String recordingCredit(String author, String license) {
    return 'Grabación: $author · $license';
  }

  @override
  String get voiceModelCrashed =>
      'El modelo de voz de Mushaf+ se quedó sin memoria en este dispositivo la última vez, así que se está usando el reconocedor del navegador. Puedes volver a probar el modelo de voz en Ajustes → Recitar y comprobar.';

  @override
  String get engineDevice => 'Reconocedor del teléfono';

  @override
  String engineVoiceModelDescApp(int size) {
    return 'Descarga única de $size MB, marca errores de vocales';
  }

  @override
  String engineVoiceModelHelpApp(int size) {
    return 'El modelo de voz de Mushaf+ descarga unos $size MB una sola vez y luego se ejecuta en este dispositivo: nada de lo que recitas sale de él. Comprueba los signos vocálicos (harakat) además de las letras, y responde un momento después de cada pausa.';
  }

  @override
  String voiceModelDownloadBodyApp(int size) {
    return 'Unos $size MB, descargados una vez y guardados en la app. El reconocimiento se ejecuta luego en este dispositivo y nada de lo que recitas sale de él.';
  }

  @override
  String get voiceModelSlowDevice =>
      'Este dispositivo es lento para el modelo de voz: los resultados pueden tardar varios segundos.';

  @override
  String get usingDeviceEngine =>
      'Usando el reconocedor del teléfono por ahora.';

  @override
  String get voiceModelPack => 'Modelo de voz de Mushaf+';
}
