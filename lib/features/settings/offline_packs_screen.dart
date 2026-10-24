import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/arabic_utils.dart';
import '../../data/translation_service.dart';
import '../../state/providers.dart';

/// Pre-downloads translations, word-by-word data and tafsir for the whole
/// Quran so everything works with no connection.
class OfflinePacksScreen extends ConsumerStatefulWidget {
  const OfflinePacksScreen({super.key});

  @override
  ConsumerState<OfflinePacksScreen> createState() => _OfflinePacksScreenState();
}

class _OfflinePacksScreenState extends ConsumerState<OfflinePacksScreen> {
  bool _running = false;
  bool _cancel = false;
  String _status = '';
  double _progress = 0;
  int _failed = 0;

  Future<void> _download({required bool translations, required bool words}) async {
    final repo = ref.quran;
    final settings = ref.read(settingsProvider);
    final tr = ref.read(translationServiceProvider);
    final wbw = ref.read(wordByWordServiceProvider);

    final tasks = <Future<void> Function()>[];
    final labels = <String>[];
    if (translations) {
      for (final ed in settings.translations.where((e) => !tr.isBundled(e))) {
        for (final s in repo.surahs) {
          if (tr.isCached(ed, s.number)) continue;
          labels.add('${repo.edition(ed)?.englishName ?? ed} · ${s.englishName}');
          tasks.add(() => tr.forSurah(ed, s.number, startAyah: s.startAyah, count: s.numberOfAyahs));
        }
      }
    }
    if (words) {
      for (final s in repo.surahs) {
        if (wbw.isCached(s.number, settings.wordLanguage)) continue;
        labels.add('Word by word (${wordByWordLanguages[settings.wordLanguage] ?? settings.wordLanguage}) · ${s.englishName}');
        tasks.add(() => wbw.forSurah(s.number, settings.wordLanguage));
      }
    }

    if (tasks.isEmpty) {
      setState(() => _status = 'Everything selected is already available offline.');
      return;
    }

    setState(() {
      _running = true;
      _cancel = false;
      _failed = 0;
      _progress = 0;
      _status = 'Starting…';
    });

    // Run a few downloads concurrently to keep it quick without hammering the APIs.
    const concurrency = 3;
    var next = 0;
    var done = 0;
    Future<void> worker() async {
      while (!_cancel && next < tasks.length) {
        final i = next++;
        try {
          await tasks[i]();
        } catch (_) {
          _failed++;
        }
        done++;
        if (mounted) {
          setState(() {
            _progress = done / tasks.length;
            _status = '${labels[i]}  ($done/${tasks.length})';
          });
        }
      }
    }

    await Future.wait([for (var i = 0; i < concurrency; i++) worker()]);
    if (!mounted) return;
    setState(() {
      _running = false;
      _status = _cancel
          ? 'Cancelled after $done of ${tasks.length}.'
          : _failed == 0
              ? 'Done. ${tasks.length} downloads saved for offline use.'
              : 'Done with $_failed failed downloads (check your connection and run again).';
    });
    ref.invalidate(surahTranslationProvider);
    ref.invalidate(surahWordsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.quran;
    final settings = ref.watch(settingsProvider);
    final tr = ref.read(translationServiceProvider);
    final wbw = ref.read(wordByWordServiceProvider);
    final scheme = Theme.of(context).colorScheme;

    final remoteTranslations = settings.translations.where((e) => !tr.isBundled(e)).toList();
    int cachedTr = 0;
    for (final ed in remoteTranslations) {
      for (final s in repo.surahs) {
        if (tr.isCached(ed, s.number)) cachedTr++;
      }
    }
    final totalTr = remoteTranslations.length * 114;
    final cachedWbw = repo.surahs.where((s) => wbw.isCached(s.number, settings.wordLanguage)).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/settings'),
        ),
        title: const Text('Offline packs'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'The Arabic text, English transliteration and three English translations are always offline. '
                'Download the rest once and read anywhere.',
                style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
              ),
              const SizedBox(height: 16),
              _PackCard(
                icon: Icons.translate,
                title: 'Selected translations',
                subtitle: remoteTranslations.isEmpty
                    ? 'All selected translations are bundled with the app.'
                    : '${remoteTranslations.map((e) => repo.edition(e)?.englishName ?? e).join(', ')}\n'
                        '$cachedTr of $totalTr surah downloads saved',
                progress: totalTr == 0 ? 1 : cachedTr / totalTr,
                enabled: !_running && remoteTranslations.isNotEmpty && cachedTr < totalTr,
                onDownload: () => _download(translations: true, words: false),
              ),
              const SizedBox(height: 12),
              _PackCard(
                icon: Icons.segment,
                title: 'Word by word (${wordByWordLanguages[settings.wordLanguage] ?? settings.wordLanguage})',
                subtitle: '$cachedWbw of 114 surahs saved · about 8 MB',
                progress: cachedWbw / 114,
                enabled: !_running && cachedWbw < 114,
                onDownload: () => _download(translations: false, words: true),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.auto_stories_outlined, color: scheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tafsir is saved automatically for every ayah you open.',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_running || _status.isNotEmpty) ...[
                if (_running) ...[
                  LinearProgressIndicator(value: _progress),
                  const SizedBox(height: 8),
                ],
                Text(_status, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                if (_running) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => setState(() => _cancel = true),
                    child: const Text('Cancel'),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _running
                    ? null
                    : () => _download(translations: true, words: true),
                icon: const Icon(Icons.download),
                label: const Text('Download everything selected'),
              ),
              const SizedBox(height: 8),
              Text(
                'Bundled editions: ${TranslationService.bundledEditions.map((e) => repo.edition(e)?.englishName ?? e).join(', ')}.',
                style: TextStyle(fontSize: 12, color: scheme.outline),
              ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
                if (complete)
                  Icon(Icons.offline_pin, color: scheme.primary)
                else
                  FilledButton.tonal(onPressed: enabled ? onDownload : null, child: const Text('Download')),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant, height: 1.4)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress, minHeight: 6),
            ),
          ],
        ),
      ),
    );
  }
}
