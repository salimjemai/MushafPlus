import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/adhkar.dart';
import '../../data/audio_backend.dart';
import '../../data/downloads.dart';
import '../../state/providers.dart';
import '../../widgets/surah_number_badge.dart';

/// Hisn al-Muslim: the list of chapters with quick entries for the daily ones.
class AdhkarScreen extends ConsumerStatefulWidget {
  const AdhkarScreen({super.key});

  @override
  ConsumerState<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends ConsumerState<AdhkarScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final book = ref.watch(adhkarProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go('/hadith')),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.hisnAlMuslim),
            Text(l.adhkar, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
      body: book.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (b) {
          final q = _query.trim().toLowerCase();
          final chapters = q.isEmpty
              ? b.chapters
              : b.chapters.where((c) => c.arabic.contains(q) || c.english.toLowerCase().contains(q) || '${c.id}' == q).toList();
          final quick = <(String, IconData, AdhkarChapter?)>[
            (l.morning, Icons.wb_sunny_outlined, b.find('الصباح')),
            (l.evening, Icons.nights_stay_outlined, b.find('الصباح')),
            (l.sleep, Icons.bedtime_outlined, b.find('أذكار النوم')),
            (l.afterPrayer, Icons.mosque_outlined, b.find('بعد السلام')),
          ];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  PatternPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('حِصْنُ الْمُسْلِمِ', style: ArabicStyles.surahName(context, size: 30, color: AppColors.goldLight)),
                        const SizedBox(height: 4),
                        Text(l.hisnAlMuslimSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 10),
                        Text(l.adhkarIntro, style: const TextStyle(color: Colors.white, height: 1.45, fontSize: 13.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (label, icon, ch) in quick)
                        if (ch != null)
                          ActionChip(
                            avatar: Icon(icon, size: 18),
                            label: Text(label),
                            onPressed: () => context.push('/adhkar/${ch.id}'),
                          ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(hintText: l.findAdhkar, prefixIcon: const Icon(Icons.search), isDense: true),
                  ),
                  const SizedBox(height: 10),
                  for (final c in chapters)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: SurahNumberBadge(number: c.id, size: 40),
                        title: Text(c.titleFor(lang), style: TextStyle(fontWeight: FontWeight.w600, fontFamily: lang == 'ar' ? ArabicStyles.nameFont : null)),
                        subtitle: Text(
                          '${c.secondaryFor(lang)} · ${c.items.length}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontFamily: lang == 'ar' ? null : ArabicStyles.nameFont),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/adhkar/${c.id}'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(l.adhkarLanguageNote, style: TextStyle(fontSize: 11.5, color: scheme.outline, height: 1.4)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One chapter: each dhikr with its counter, translation and audio.
class AdhkarChapterScreen extends ConsumerStatefulWidget {
  const AdhkarChapterScreen({super.key, required this.chapterId});
  final int chapterId;

  @override
  ConsumerState<AdhkarChapterScreen> createState() => _AdhkarChapterScreenState();
}

class _AdhkarChapterScreenState extends ConsumerState<AdhkarChapterScreen> {
  AyahPlayer? _player;
  String? _playingUrl;
  bool _showTransliteration = true;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _play(String url) async {
    if (url.isEmpty) return;
    if (_playingUrl == url) {
      _player?.stop();
      setState(() => _playingUrl = null);
      return;
    }
    _player ??= createAyahPlayer()
      ..completed.listen((_) {
        if (mounted) setState(() => _playingUrl = null);
      });
    var source = url;
    // Native: play the offline copy when it exists. Web: play at once (the
    // call must stay inside the tap for Safari).
    if (Downloads.supportsCache) source = await Downloads.cachedFile('adhkar', Uri.parse(url).pathSegments.last) ?? url;
    _player!.play(source);
    setState(() => _playingUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final book = ref.watch(adhkarProvider).asData?.value;
    final chapter = book?.byId(widget.chapterId);
    final counts = ref.watch(adhkarCountsProvider);
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;
    if (chapter == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    final done = chapter.items.where((i) => (counts[i.id] ?? 0) >= i.repeat).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go('/adhkar')),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chapter.titleFor(lang), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${chapter.secondaryFor(lang)} · ${l.repeatProgress(done, chapter.items.length)}',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          if (chapter.audio.isNotEmpty)
            IconButton(
              tooltip: l.playChapter,
              icon: Icon(_playingUrl == chapter.audio ? Icons.stop_circle_outlined : Icons.play_circle_outline),
              onPressed: () => _play(chapter.audio),
            ),
          PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'reset':
                  ref.read(adhkarCountsProvider.notifier).reset(chapter);
                case 'translit':
                  setState(() => _showTransliteration = !_showTransliteration);
                case 'download':
                  if (chapter.audio.isNotEmpty) Downloads.saveUrl(chapter.audio, 'hisn-${chapter.id}.mp3');
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'reset', child: ListTile(leading: const Icon(Icons.restart_alt), title: Text(l.resetCounters))),
              PopupMenuItem(
                value: 'translit',
                child: ListTile(leading: Icon(_showTransliteration ? Icons.check_box : Icons.check_box_outline_blank), title: Text(l.transliteration)),
              ),
              if (chapter.audio.isNotEmpty)
                PopupMenuItem(value: 'download', child: ListTile(leading: const Icon(Icons.download_outlined), title: Text(l.download))),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: chapter.items.length + 1,
            itemBuilder: (context, i) {
              if (i == chapter.items.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(l.adhkarLanguageNote, style: TextStyle(fontSize: 11.5, color: scheme.outline, height: 1.4)),
                );
              }
              final item = chapter.items[i];
              final n = counts[item.id] ?? 0;
              final complete = n >= item.repeat;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        item.arabic,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 23 * settings.arabicScale, height: 1.9, color: scheme.onSurface),
                      ),
                      if (lang != 'ar' && item.translation.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(item.translation, style: TextStyle(fontSize: 14.5 * settings.translationScale, height: 1.5)),
                      ],
                      if (_showTransliteration && item.transliteration.isNotEmpty && lang != 'ar') ...[
                        const SizedBox(height: 6),
                        Text(item.transliteration, style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: scheme.primary, height: 1.45)),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              ref.read(adhkarCountsProvider.notifier).tap(item);
                            },
                            style: complete ? FilledButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary) : null,
                            icon: Icon(complete ? Icons.check_circle : Icons.touch_app_outlined, size: 18),
                            label: Text(complete ? l.allDone : l.repeatProgress(n, item.repeat)),
                          ),
                          const SizedBox(width: 6),
                          if (item.repeat > 1)
                            Text(l.timesN(item.repeat), style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          if (item.audio.isNotEmpty) ...[
                            IconButton(
                              tooltip: l.play,
                              icon: Icon(_playingUrl == item.audio ? Icons.stop_circle_outlined : Icons.play_circle_outline),
                              onPressed: () => _play(item.audio),
                            ),
                            IconButton(
                              tooltip: l.download,
                              icon: const Icon(Icons.download_outlined, size: 20),
                              onPressed: () => Downloads.saveUrl(item.audio, 'hisn-${chapter.id}-${item.id}.mp3'),
                            ),
                          ],
                          IconButton(
                            tooltip: l.share,
                            icon: const Icon(Icons.ios_share, size: 20),
                            onPressed: () => Share.share('${item.arabic}\n\n${item.translation}\n\n${chapter.titleFor(lang)} · ${l.hisnAlMuslim}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Book-shaped tile for the hadith library shelf.
class AdhkarCover extends StatelessWidget {
  const AdhkarCover({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(3), right: Radius.circular(8)),
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1F4E3D), Color(0xFF0E2E24)]),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(2, 5))],
              ),
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: AppColors.gold.withValues(alpha: 0.9), width: 1.4), borderRadius: BorderRadius.circular(4)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('۞', style: TextStyle(fontFamily: ArabicStyles.nameFont, color: AppColors.gold.withValues(alpha: 0.9), fontSize: 16)),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('حِصْنُ\nالْمُسْلِمِ',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 24, height: 1.5, fontWeight: FontWeight.w700, color: AppColors.goldLight)),
                    ),
                    const SizedBox(height: 6),
                    Text(l.hisnAlMuslim, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                    const SizedBox(height: 8),
                    Icon(Icons.auto_awesome, color: AppColors.gold.withValues(alpha: 0.8), size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(l.hisnAlMuslim, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(l.adhkar, style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
