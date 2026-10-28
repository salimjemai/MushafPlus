import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'adhans.dart';
import 'adhkar.dart';
import 'downloads.dart';
import 'reciters.dart';
import 'speech_engine.dart';
import 'tafsir_service.dart';
import 'voice_model.dart';
import '../state/providers.dart';

/// One download unit with a human label.
typedef OfflineTask = (String label, Future<void> Function() run);

class OfflineSyncState {
  const OfflineSyncState({
    this.running = false,
    this.done = 0,
    this.total = 0,
    this.failed = 0,
    this.label = '',
    this.finishedRuns = 0,
    this.cancelled = false,
    this.skippedForCellular = false,
  });

  final bool running;
  final int done;
  final int total;
  final int failed;
  final String label;

  /// Bumped after every run so screens can refresh their counts.
  final int finishedRuns;
  final bool cancelled;

  /// Audio packs were left out because the device is on cellular data.
  final bool skippedForCellular;

  double get progress => total == 0 ? 0 : done / total;
  int get percent => (progress * 100).floor();

  OfflineSyncState copyWith({bool? running, int? done, int? total, int? failed, String? label, int? finishedRuns, bool? cancelled, bool? skippedForCellular}) =>
      OfflineSyncState(
        running: running ?? this.running,
        done: done ?? this.done,
        total: total ?? this.total,
        failed: failed ?? this.failed,
        label: label ?? this.label,
        finishedRuns: finishedRuns ?? this.finishedRuns,
        cancelled: cancelled ?? this.cancelled,
        skippedForCellular: skippedForCellular ?? this.skippedForCellular,
      );
}

/// Background downloader for the offline packs. It outlives any screen, so
/// the first-launch download keeps going while the user reads, and
/// [startAll] can be called on every launch to resume what is missing
/// (every pack skips what is already stored).
class OfflineSync extends Notifier<OfflineSyncState> {
  bool _cancel = false;

  @override
  OfflineSyncState build() => const OfflineSyncState();

  static String _name(String url) => Uri.parse(url).pathSegments.last;

  // ---- pack builders --------------------------------------------------------

  List<OfflineTask> translationTasks() {
    final repo = ref.read(repositoryProvider).requireValue;
    final settings = ref.read(settingsProvider);
    final tr = ref.read(translationServiceProvider);
    return [
      for (final ed in settings.translations.where((e) => !tr.isBundled(e)))
        for (final s in repo.surahs)
          if (!tr.isCached(ed, s.number))
            ('${repo.edition(ed)?.englishName ?? ed} · ${s.englishName}', () => tr.forSurah(ed, s.number, startAyah: s.startAyah, count: s.numberOfAyahs)),
    ];
  }

  List<OfflineTask> wordTasks() {
    final repo = ref.read(repositoryProvider).requireValue;
    final settings = ref.read(settingsProvider);
    final wbw = ref.read(wordByWordServiceProvider);
    return [
      for (final s in repo.surahs)
        if (!wbw.isCached(s.number, settings.wordLanguage)) ('Word by word · ${s.englishName}', () => wbw.forSurah(s.number, settings.wordLanguage)),
    ];
  }

  List<OfflineTask> tafsirTasks() {
    final repo = ref.read(repositoryProvider).requireValue;
    final settings = ref.read(settingsProvider);
    final svc = ref.read(tafsirServiceProvider);
    final source = tafsirById(settings.tafsirId);
    return [
      for (final s in repo.surahs)
        if (!svc.isChapterCached(source.id, s.number, s.numberOfAyahs)) ('${source.name} · ${s.englishName}', () => svc.forChapter(source.id, s.number)),
    ];
  }

  Future<List<OfflineTask>> hadithTasks() async {
    final settings = ref.read(settingsProvider);
    final svc = ref.read(hadithServiceProvider);
    final books = await ref.read(hadithBooksProvider.future);
    return [
      for (final b in books)
        for (final s in b.sections)
          if (!svc.isCached(b.id, s.number, settings.hadithLanguage)) ('${b.name} · ${s.number}', () => svc.section(b.id, s.number, settings.hadithLanguage)),
    ];
  }

  List<OfflineTask> adhanTasks() => [
        for (final a in adhans) ('Adhan · ${a.name}', () => Downloads.cacheFile('adhans', a.fileName, a.url)),
      ];

  Future<List<OfflineTask>> adhkarAudioTasks() async {
    final book = await ref.read(adhkarProvider.future);
    return [
      for (final c in book.chapters)
        for (final i in c.items)
          if (i.audio.isNotEmpty) ('Hisn al-Muslim · ${c.id}', () => Downloads.cacheFile('adhkar', _name(i.audio), i.audio)),
    ];
  }

  List<OfflineTask> reciterTasks() {
    final repo = ref.read(repositoryProvider).requireValue;
    final reciter = reciterById(ref.read(settingsProvider).reciter);
    return [
      for (final a in repo.ayahs) ('${reciter.name} · ${a.key}', () => Downloads.cacheAyah(reciter.id, a.surah, a.numberInSurah, reciter.ayahUrl(a.surah, a.numberInSurah))),
    ];
  }

  /// The on-device voice model of the recitation checker (Android, iOS):
  /// a few files, about 85 MB, fetched only once the user has chosen that
  /// engine (or from the packs screen). Kept apart from the audio cache.
  Future<List<OfflineTask>> voiceModelTasks() async {
    if (!voiceModelAvailable || !Downloads.supportsCache) return const [];
    const pack = voiceModelPack;
    return [
      for (final f in pack.files)
        if (await Downloads.cachedModelPath(pack.folder, f.name) == null)
          ('Voice model · ${f.name}', () => Downloads.cacheModel(pack.folder, f.name, pack.urlFor(f))),
    ];
  }

  /// Whether at least one voice model file is on the device (the user agreed
  /// to the download once).
  Future<bool> voiceModelStarted() async {
    for (final f in voiceModelPack.files) {
      if (await Downloads.cachedModelPath(voiceModelPack.folder, f.name) != null) return true;
    }
    return false;
  }

  /// Text packs only (web and native).
  Future<List<OfflineTask>> textTasks() async => [...translationTasks(), ...wordTasks(), ...tafsirTasks(), ...await hadithTasks()];

  /// Everything the installed app needs: texts, adhans, adhkar audio and,
  /// when [includeReciter], the whole recitation of the chosen reciter.
  ///
  /// Store policy: large downloads must not surprise the user, so with no
  /// connection nothing runs, and on cellular data only the small text packs
  /// run unless the user turned "Wi-Fi only" off or pressed the button
  /// themselves ([manual]).
  Future<void> startAll({required bool includeReciter, bool manual = false}) async {
    if (state.running) return;
    await ref.read(repositoryProvider.future);
    final link = await _connection();
    if (link == _Link.none) return;
    final audioAllowed = link == _Link.unmetered || manual || !ref.read(settingsProvider).offlineWifiOnly;
    final tasks = <OfflineTask>[...await textTasks()];
    if (Downloads.supportsCache && !audioAllowed) {
      state = state.copyWith(skippedForCellular: true);
    }
    if (Downloads.supportsCache && audioAllowed) {
      tasks.addAll(adhanTasks());
      tasks.addAll(await adhkarAudioTasks());
      // The voice model only finishes here: it starts from the recite screen,
      // after the user has agreed to its size, and the sync completes what an
      // interrupted download left missing.
      if (ref.read(settingsProvider).useVoiceModel && await voiceModelStarted()) tasks.addAll(await voiceModelTasks());
      if (includeReciter) {
        // Only the files still missing.
        final repo = ref.read(repositoryProvider).requireValue;
        final reciter = reciterById(ref.read(settingsProvider).reciter);
        for (final a in repo.ayahs) {
          if (await Downloads.cachedAyahPath(reciter.id, a.surah, a.numberInSurah) == null) {
            tasks.add(('${reciter.name} · ${a.key}', () => Downloads.cacheAyah(reciter.id, a.surah, a.numberInSurah, reciter.ayahUrl(a.surah, a.numberInSurah))));
          }
        }
      }
    }
    await run(tasks);
  }

  Future<_Link> _connection() async {
    try {
      final r = await Connectivity().checkConnectivity();
      if (r.isEmpty || r.every((c) => c == ConnectivityResult.none)) return _Link.none;
      if (r.contains(ConnectivityResult.mobile) && !r.contains(ConnectivityResult.wifi) && !r.contains(ConnectivityResult.ethernet)) return _Link.metered;
      return _Link.unmetered;
    } catch (_) {
      return _Link.unmetered;
    }
  }

  void cancel() => _cancel = true;

  Future<void> run(List<OfflineTask> tasks) async {
    if (state.running) return;
    _cancel = false;
    if (tasks.isEmpty) {
      state = state.copyWith(running: false, done: 0, total: 0, failed: 0, label: '', finishedRuns: state.finishedRuns + 1, cancelled: false);
      return;
    }
    state = OfflineSyncState(running: true, total: tasks.length, finishedRuns: state.finishedRuns, skippedForCellular: state.skippedForCellular);
    const concurrency = 3;
    var next = 0;
    var done = 0;
    var failed = 0;
    Future<void> worker() async {
      while (!_cancel && next < tasks.length) {
        final i = next++;
        try {
          await tasks[i].$2();
        } catch (_) {
          failed++;
        }
        done++;
        if (done % 2 == 0 || done == tasks.length) {
          state = state.copyWith(done: done, failed: failed, label: tasks[i].$1);
        }
      }
    }

    await Future.wait([for (var i = 0; i < concurrency; i++) worker()]);
    state = state.copyWith(running: false, done: done, failed: failed, finishedRuns: state.finishedRuns + 1, cancelled: _cancel);
    ref.invalidate(surahTranslationProvider);
    ref.invalidate(surahWordsProvider);
    ref.invalidate(tafsirProvider);
    ref.invalidate(hadithSectionProvider);
  }
}

enum _Link { none, metered, unmetered }

final offlineSyncProvider = NotifierProvider<OfflineSync, OfflineSyncState>(OfflineSync.new);
