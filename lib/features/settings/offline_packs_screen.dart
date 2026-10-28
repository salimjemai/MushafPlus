import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../data/adhans.dart';
import '../../data/adhkar.dart';
import '../../data/downloads.dart';
import '../../data/hadith_service.dart';
import '../../data/offline_sync.dart';
import '../../data/reciters.dart';
import '../../data/tafsir_service.dart';
import '../../data/translation_service.dart';
import '../../core/arabic_utils.dart';
import '../../state/providers.dart';

/// Shows what is stored for offline use and lets the user (re)run any pack.
/// The downloads themselves run in [OfflineSync], so they continue when this
/// screen is closed.
class OfflinePacksScreen extends ConsumerStatefulWidget {
  const OfflinePacksScreen({super.key, this.autoStart = false});

  /// Start the text packs at once.
  final bool autoStart;

  @override
  ConsumerState<OfflinePacksScreen> createState() => _OfflinePacksScreenState();
}

class _OfflinePacksScreenState extends ConsumerState<OfflinePacksScreen> {
  int _adhanCached = 0;
  int _adhkarCached = 0;
  int _reciterCached = 0;
  int _seenRuns = -1;

  @override
  void initState() {
    super.initState();
    _refreshCounts();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final sync = ref.read(offlineSyncProvider.notifier);
        sync.run(await sync.textTasks());
      });
    }
  }

  Future<void> _refreshCounts() async {
    if (!Downloads.supportsCache) return;
    final reciter = reciterById(ref.read(settingsProvider).reciter);
    var reciterCount = 0;
    for (final s in ref.quran.surahs) {
      reciterCount += await Downloads.cachedCount(reciter.id, s.number);
    }
    var adhanCount = 0;
    for (final a in adhans) {
      if (await Downloads.cachedFile('adhans', a.fileName) != null) adhanCount++;
    }
    var adhkarCount = 0;
    final book = ref.read(adhkarProvider).asData?.value;
    if (book != null) {
      for (final c in book.chapters) {
        for (final i in c.items) {
          if (i.audio.isNotEmpty && await Downloads.cachedFile('adhkar', Uri.parse(i.audio).pathSegments.last) != null) adhkarCount++;
        }
      }
    }
    if (mounted) {
      setState(() {
        _reciterCached = reciterCount;
        _adhanCached = adhanCount;
        _adhkarCached = adhkarCount;
      });
    }
  }

  String _statusText(OfflineSyncState s) {
    final l = context.l10n;
    if (s.running) return '${s.label}  (${s.done}/${s.total})';
    if (s.skippedForCellular) return l.waitingForWifi;
    if (s.total == 0) return l.everythingOffline;
    if (s.cancelled) return l.downloadCancelled(s.done, s.total);
    if (s.failed == 0) return l.downloadDone(s.total);
    return l.downloadDoneWithFailures(s.failed);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final repo = ref.quran;
    final settings = ref.watch(settingsProvider);
    final sync = ref.watch(offlineSyncProvider);
    final syncer = ref.read(offlineSyncProvider.notifier);
    if (sync.finishedRuns != _seenRuns) {
      _seenRuns = sync.finishedRuns;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshCounts());
    }
    final tr = ref.read(translationServiceProvider);
    final wbw = ref.read(wordByWordServiceProvider);
    final tafsir = ref.read(tafsirServiceProvider);
    final hadith = ref.read(hadithServiceProvider);
    final books = ref.watch(hadithBooksProvider).asData?.value ?? const <HadithBook>[];
    final adhkar = ref.watch(adhkarProvider).asData?.value;
    final scheme = Theme.of(context).colorScheme;
    final reciter = reciterById(settings.reciter);
    final running = sync.running;

    final remoteTranslations = settings.translations.where((e) => !tr.isBundled(e)).toList();
    var cachedTr = 0;
    for (final ed in remoteTranslations) {
      for (final s in repo.surahs) {
        if (tr.isCached(ed, s.number)) cachedTr++;
      }
    }
    final totalTr = remoteTranslations.length * 114;
    final cachedWbw = repo.surahs.where((s) => wbw.isCached(s.number, settings.wordLanguage)).length;
    final source = tafsirById(settings.tafsirId);
    final cachedTafsir = repo.surahs.where((s) => tafsir.isChapterCached(source.id, s.number, s.numberOfAyahs)).length;
    var hadithTotal = 0;
    var hadithCached = 0;
    for (final b in books) {
      for (final s in b.sections) {
        hadithTotal++;
        if (hadith.isCached(b.id, s.number, settings.hadithLanguage)) hadithCached++;
      }
    }
    final adhkarTotal = adhkar?.chapters.fold<int>(0, (n, c) => n + c.items.where((i) => i.audio.isNotEmpty).length) ?? 0;
    final native = Downloads.supportsCache;
    final showStatus = running || sync.finishedRuns > 0 || sync.skippedForCellular;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/settings'),
        ),
        title: Text(l.offlinePacks),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(native ? l.offlineAutoIntro : l.offlineIntro, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 6),
              Text(l.bundledAlways, style: TextStyle(fontSize: 12.5, color: scheme.outline, height: 1.4)),
              const SizedBox(height: 16),
              if (showStatus) ...[
                Card(
                  color: scheme.primaryContainer.withValues(alpha: 0.35),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (running) ...[LinearProgressIndicator(value: sync.progress), const SizedBox(height: 8)],
                        Text(_statusText(sync), style: const TextStyle(fontSize: 13)),
                        if (running) ...[
                          const SizedBox(height: 8),
                          Align(alignment: AlignmentDirectional.centerEnd, child: OutlinedButton(onPressed: syncer.cancel, child: Text(l.pause))),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (native)
                FilledButton.icon(
                  onPressed: running ? null : () => syncer.startAll(includeReciter: settings.offlineReciter, manual: true),
                  icon: const Icon(Icons.download),
                  label: Text(l.resumeOfflineDownload),
                )
              else
                FilledButton.icon(
                  onPressed: running ? null : () async => syncer.run(await syncer.textTasks()),
                  icon: const Icon(Icons.download),
                  label: Text(l.downloadTextPacks),
                ),
              if (native) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.wifiOnly),
                  subtitle: Text(l.wifiOnlyHint),
                  value: settings.offlineWifiOnly,
                  onChanged: (v) => ref.read(settingsProvider.notifier).setOfflineWifiOnly(v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.includeFullRecitation(reciter.name)),
                  subtitle: Text(l.includeFullRecitationHint),
                  value: settings.offlineReciter,
                  onChanged: (v) => ref.read(settingsProvider.notifier).setOfflineReciter(v),
                ),
              ],
              const SizedBox(height: 16),
              Text(l.textPacks.toUpperCase(), style: TextStyle(fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              _PackCard(
                icon: Icons.translate,
                title: l.selectedTranslations,
                subtitle: remoteTranslations.isEmpty
                    ? l.allSelectedBundled
                    : '${remoteTranslations.map((e) => repo.edition(e)?.englishName ?? e).join(', ')}\n${l.surahDownloadsSaved(cachedTr, totalTr)}',
                progress: totalTr == 0 ? 1 : cachedTr / totalTr,
                enabled: !running && remoteTranslations.isNotEmpty && cachedTr < totalTr,
                onDownload: () => syncer.run(syncer.translationTasks()),
              ),
              const SizedBox(height: 12),
              _PackCard(
                icon: Icons.segment,
                title: l.wordByWordPack(wordByWordLanguages[settings.wordLanguage] ?? settings.wordLanguage),
                subtitle: l.surahsSavedSize(cachedWbw),
                progress: cachedWbw / 114,
                enabled: !running && cachedWbw < 114,
                onDownload: () => syncer.run(syncer.wordTasks()),
              ),
              const SizedBox(height: 12),
              _PackCard(
                icon: Icons.auto_stories_outlined,
                title: l.tafsirPack(source.name),
                subtitle: l.surahsSavedSize(cachedTafsir),
                progress: cachedTafsir / 114,
                enabled: !running && cachedTafsir < 114,
                onDownload: () => syncer.run(syncer.tafsirTasks()),
              ),
              const SizedBox(height: 12),
              _PackCard(
                icon: Icons.format_quote_outlined,
                title: l.hadithPack(hadithLanguages[settings.hadithLanguage] ?? settings.hadithLanguage),
                subtitle: l.chaptersSaved(hadithCached, hadithTotal),
                progress: hadithTotal == 0 ? 0 : hadithCached / hadithTotal,
                enabled: !running && hadithCached < hadithTotal,
                onDownload: () async => syncer.run(await syncer.hadithTasks()),
              ),
              const SizedBox(height: 20),
              Text(l.audioPacks.toUpperCase(), style: TextStyle(fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              if (!native)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(l.offlineAudioNativeOnly, style: TextStyle(fontSize: 12.5, color: scheme.error)),
                ),
              const SizedBox(height: 4),
              _PackCard(
                icon: Icons.campaign_outlined,
                title: l.adhanPack,
                subtitle: '${l.filesSaved(_adhanCached, adhans.length)} · ${l.approxSize('70 MB')}',
                progress: adhans.isEmpty ? 0 : _adhanCached / adhans.length,
                enabled: native && !running && _adhanCached < adhans.length,
                onDownload: () => syncer.run(syncer.adhanTasks()),
              ),
              const SizedBox(height: 12),
              _PackCard(
                icon: Icons.auto_awesome,
                title: l.adhkarAudioPack,
                subtitle: '${l.filesSaved(_adhkarCached, adhkarTotal)} · ${l.approxSize('60 MB')}',
                progress: adhkarTotal == 0 ? 0 : _adhkarCached / adhkarTotal,
                enabled: native && !running && adhkarTotal > 0 && _adhkarCached < adhkarTotal,
                onDownload: () async => syncer.run(await syncer.adhkarAudioTasks()),
              ),
              const SizedBox(height: 12),
              _PackCard(
                icon: Icons.record_voice_over_outlined,
                title: l.reciterPack(reciter.name),
                subtitle: '${l.filesSaved(_reciterCached, 6236)} · ${l.approxSize('700 MB')}',
                progress: _reciterCached / 6236,
                enabled: native && !running && _reciterCached < 6236,
                onDownload: () => syncer.run(syncer.reciterTasks()),
              ),
              const SizedBox(height: 12),
              Text(l.bundledEditions(TranslationService.bundledEditions.map((e) => repo.edition(e)?.englishName ?? e).join(', ')),
                  style: TextStyle(fontSize: 12, color: scheme.outline)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.enabled,
    required this.onDownload,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double progress;
  final bool enabled;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final complete = progress >= 1;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant, height: 1.35)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                complete
                    ? Icon(Icons.check_circle, color: scheme.primary)
                    : IconButton.filledTonal(
                        tooltip: context.l10n.download,
                        onPressed: enabled ? onDownload : null,
                        icon: const Icon(Icons.download_outlined),
                      ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress.clamp(0, 1), minHeight: 6),
            ),
          ],
        ),
      ),
    );
  }
}
