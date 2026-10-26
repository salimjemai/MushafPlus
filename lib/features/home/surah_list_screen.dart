import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/arabic_utils.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/quran_repository.dart';
import '../../data/translation_service.dart';
import '../../state/providers.dart';
import '../search/search_screen.dart';
import '../../state/reading_stats.dart';
import '../../widgets/surah_number_badge.dart';
import '../plan/plan_screen.dart';

enum _Tab { surahs, juz, pages }

class SurahListScreen extends ConsumerStatefulWidget {
  const SurahListScreen({super.key});

  @override
  ConsumerState<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends ConsumerState<SurahListScreen> {
  final _controller = TextEditingController();
  String _query = '';
  _Tab _tab = _Tab.surahs;
  List<String>? _corpus;

  @override
  void initState() {
    super.initState();
    ref.read(translationServiceProvider).bundledCorpus(TranslationService.defaultEdition).then((c) {
      if (mounted) setState(() => _corpus = c);
    });
  }

  /// Ayahs matching the query (Arabic, transliteration, then the bundled
  /// translation), capped like the search screen.
  List<int> _ayahHits(QuranRepository repo, String q) {
    if (q.trim().length < 2) return const [];
    final seen = <int>{};
    final out = <int>[];
    for (final n in repo.searchArabicAndTransliteration(q)) {
      if (seen.add(n)) out.add(n);
    }
    final corpus = _corpus;
    if (corpus != null) {
      for (final n in QuranRepository.searchCorpus(corpus, q)) {
        if (seen.add(n)) out.add(n);
      }
    }
    return out;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final repo = ref.quran;
    final surahs = _filter(repo.surahs, _query);
    final showHero = _query.isEmpty;
    final hits = _tab == _Tab.surahs ? _ayahHits(repo, _query) : const <int>[];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(l.appTitle),
            const SizedBox(width: 10),
            Text(
              'ٱلْقُرْآنُ ٱلْكَرِيمُ',
              style: ArabicStyles.surahName(context, size: 18, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Wide screens (desktop web, tablets in landscape): the daily cards
          // move to a side panel and the surah list keeps the main column.
          final wide = constraints.maxWidth >= 900;
          final main = ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              // On phones the search bar is the first thing on the page; on wide
              // screens it spans both columns above this list.
              if (!wide) ...[
                KeyedSubtree(key: const ValueKey('home-search'), child: _searchField(context, l, hits)),
                const SizedBox(height: 12),
              ],
              // The hero cards come and go with the query; keys keep the text
              // field's element (and the keyboard) alive across that change.
              if (showHero)
                Column(
                  key: const ValueKey('home-hero'),
                  children: [
                    const _ContinueReadingCard(),
                    const SizedBox(height: 12),
                    if (!wide) ...const [
                      _AdhkarCard(),
                      SizedBox(height: 12),
                      _TodayCard(),
                      SizedBox(height: 12),
                      _VerseOfTheDayCard(),
                      SizedBox(height: 4),
                    ],
                    const SizedBox(height: 4),
                  ],
                ),
              Column(
                key: const ValueKey('home-finder'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: SegmentedButton<_Tab>(
                      showSelectedIcon: false,
                      style: const ButtonStyle(visualDensity: VisualDensity.compact),
                      segments: [
                        ButtonSegment(value: _Tab.surahs, label: Text(l.tabSurah)),
                        ButtonSegment(value: _Tab.juz, label: Text(l.tabJuz)),
                        ButtonSegment(value: _Tab.pages, label: Text(l.tabPage)),
                      ],
                      selected: {_tab},
                      onSelectionChanged: (s) => setState(() => _tab = s.first),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_tab == _Tab.surahs) ...[
                if (surahs.isEmpty && hits.isEmpty && _query.trim().isNotEmpty)
                  Padding(
                    key: const ValueKey('home-no-match'),
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text(l.noSurahMatches)),
                  ),
                for (final s in surahs) ...[
                  SurahTile(
                    surah: s,
                    onTap: () => context.go(
                      ref.read(settingsProvider).readerMode == ReaderMode.mushaf
                          ? '/mushaf?page=${s.startPage}'
                          : '/surah/${s.number}',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (hits.isNotEmpty) ...[
                  Padding(
                    key: const ValueKey('home-ayah-hits-header'),
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    child: Text(
                      l.resultsCount('${hits.length}${hits.length >= 200 ? '+' : ''}'),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                  for (final n in hits.take(10)) ...[
                    AyahResultTile(
                      key: ValueKey('hit-$n'),
                      ayahNumber: n,
                      query: _query,
                      translation: _corpus?[n - 1],
                      onTap: () => context.go('/surah/${repo.ayah(n).surah}?ayah=${repo.ayah(n).numberInSurah}'),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (hits.length > 10)
                    Padding(
                      key: const ValueKey('home-search-all'),
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      child: FilledButton.tonalIcon(
                        onPressed: () => context.go('/search?q=${Uri.encodeQueryComponent(_query.trim())}'),
                        icon: const Icon(Icons.manage_search),
                        label: Text('${l.searchWholeQuran} · ${l.resultsCount('${hits.length}${hits.length >= 200 ? '+' : ''}')}'),
                      ),
                    ),
                ],
              ] else if (_tab == _Tab.juz) ...[
                for (final j in repo.juzs) ...[
                  _JuzTile(juz: j),
                  const SizedBox(height: 8),
                ],
              ] else ...[
                const _PageGrid(),
              ],
            ],
          );
          if (!wide) {
            return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 820), child: main));
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1360),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: KeyedSubtree(key: const ValueKey('home-search-wide'), child: _searchField(context, l, hits)),
                  ),
                  Expanded(
                    child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: main),
                  SizedBox(
                    width: 380,
                    child: ListView(
                      key: const ValueKey('home-side'),
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 16, 24),
                      children: const [
                        _AdhkarCard(),
                        SizedBox(height: 12),
                        _TodayCard(),
                        SizedBox(height: 12),
                        _VerseOfTheDayCard(),
                      ],
                    ),
                  ),
                ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// The one search field: wide, with the tips in its placeholder.
  Widget _searchField(BuildContext context, AppLocalizations l, List<int> hits) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: _controller,
      onChanged: (v) => setState(() => _query = v),
      textInputAction: TextInputAction.search,
      onSubmitted: (v) {
        if (v.trim().length >= 2 && hits.isNotEmpty) {
          context.go('/search?q=${Uri.encodeQueryComponent(v.trim())}');
        }
      },
      style: const TextStyle(fontSize: 17),
      decoration: InputDecoration(
        hintText: l.homeSearchHint,
        hintMaxLines: 2,
        hintStyle: TextStyle(fontSize: 14.5, color: scheme.onSurfaceVariant, height: 1.35),
        prefixIcon: const Padding(padding: EdgeInsetsDirectional.only(start: 8, end: 4), child: Icon(Icons.search, size: 28)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: scheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: scheme.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: scheme.primary, width: 1.6)),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  setState(() => _query = '');
                },
              ),
      ),
    );
  }

  static List<Surah> _filter(List<Surah> all, String query) {
    final q = query.trim();
    if (q.isEmpty) return all;
    final n = int.tryParse(q);
    if (n != null) {
      return all.where((s) => s.number == n || s.number.toString().startsWith(q)).toList();
    }
    final lq = transliterationSearchKey(q);
    final aq = containsArabic(q) ? normalizeArabic(q) : null;
    return all.where((s) {
      if (aq != null) return normalizeArabic(s.name).contains(aq);
      final en = transliterationSearchKey(s.englishName);
      final tr = transliterationSearchKey(s.englishNameTranslation);
      return en.contains(lq) || tr.contains(lq);
    }).toList();
  }
}

String revelationLabel(BuildContext context, Surah s) =>
    s.isMeccan ? context.l10n.meccan : context.l10n.medinan;

class SurahTile extends StatelessWidget {
  const SurahTile({
    super.key,
    required this.surah,
    required this.onTap,
    this.selected = false,
    this.compact = false,
  });

  final Surah surah;
  final VoidCallback onTap;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: selected ? scheme.primary.withValues(alpha: 0.10) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 10 : 12),
          child: Row(
            children: [
              SurahNumberBadge(number: surah.number, size: compact ? 38 : 46),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.englishName,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: compact ? 15 : 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      compact
                          ? '${surah.englishNameTranslation} · ${surah.numberOfAyahs}'
                          : context.l10n.surahSubtitle(
                              surah.englishNameTranslation, surah.numberOfAyahs, revelationLabel(context, surah)),
                      style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                surah.name,
                textDirection: TextDirection.rtl,
                style: ArabicStyles.surahName(context, size: compact ? 18 : 22, color: scheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JuzTile extends ConsumerWidget {
  const _JuzTile({required this.juz});
  final Juz juz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final repo = ref.quran;
    final s = repo.surah(juz.startSurah);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: SurahNumberBadge(number: juz.number, size: 42, color: scheme.secondary),
        title: Text(l.juzN(juz.number), style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(l.juzStartsAt(s.englishName, juz.startAyahInSurah, juz.endAyah - juz.startAyah + 1)),
        trailing: Text(
          toArabicDigits(juz.number),
          style: ArabicStyles.surahName(context, size: 20, color: scheme.secondary),
        ),
        onTap: () => context.go('/surah/${juz.startSurah}?ayah=${juz.startAyahInSurah}'),
      ),
    );
  }
}

/// All 604 Mushaf pages grouped by juz.
class _PageGrid extends ConsumerWidget {
  const _PageGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.quran;
    final scheme = Theme.of(context).colorScheme;
    final byJuz = <int, List<int>>{};
    for (var p = 1; p <= QuranRepository.totalPages; p++) {
      byJuz.putIfAbsent(repo.ayah(repo.pageStarts[p - 1]).juz, () => []).add(p);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in byJuz.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
            child: Text(
              context.l10n.juzN(e.key).toUpperCase(),
              style: TextStyle(fontSize: 11.5, letterSpacing: 1.4, fontWeight: FontWeight.w700, color: scheme.primary),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final p in e.value)
                ActionChip(
                  label: Text('$p'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => context.go('/mushaf?page=$p'),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ContinueReadingCard extends ConsumerWidget {
  const _ContinueReadingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final repo = ref.quran;
    final last = ref.watch(lastReadProvider);
    final ayah = repo.ayah(last?.ayahNumber ?? 1);
    final surah = repo.surah(ayah.surah);
    final progress = ayah.number / repo.ayahs.length;

    return PatternPanel(
      child: InkWell(
        onTap: () => context.go('/surah/${surah.number}?ayah=${ayah.numberInSurah}'),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    last == null ? l.startReading : l.continueReading,
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    surah.englishName,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.ayahOfJuzPage(ayah.numberInSurah, surah.numberOfAyahs, ayah.juz, ayah.page),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      color: AppColors.goldLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(surah.name, style: ArabicStyles.surahName(context, size: 28, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// Daily goal ring, streak and khatm status; opens the plan screen.
class _TodayCard extends ConsumerWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final stats = ref.watch(readingStatsProvider);
    final lastRead = ref.watch(lastReadProvider)?.ayahNumber ?? 1;
    final scheme = Theme.of(context).colorScheme;
    final plan = stats.plan;
    final now = DateTime.now();
    final behind = plan == null ? 0 : plan.targetAyahFor(now) - lastRead;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/plan'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              GoalRing(
                progress: stats.readToday / stats.dailyGoal,
                label: '${stats.readToday}',
                sublabel: '/ ${stats.dailyGoal}',
                size: 64,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(l.today, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(width: 10),
                        const Icon(Icons.local_fire_department, size: 16, color: AppColors.gold),
                        Text(' ${stats.streak}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plan == null
                          ? l.dailyGoalTapToStartPlan(stats.dailyGoal)
                          : behind <= 0
                              ? l.khatmOnTrack(plan.dayNumber(now).clamp(1, plan.days), plan.days)
                              : l.khatmBehind(behind, plan.dayNumber(now).clamp(1, plan.days), plan.days),
                      style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerseOfTheDayCard extends ConsumerWidget {
  const _VerseOfTheDayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.quran;
    final n = ref.watch(verseOfTheDayProvider);
    final ayah = repo.ayah(n);
    final surah = repo.surah(ayah.surah);
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);
    final translation = ref.watch(surahTranslationProvider(
      (surah: ayah.surah, edition: settings.translations.firstOrNull ?? TranslationService.defaultEdition),
    ));

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go('/surah/${surah.number}?ayah=${ayah.numberInSurah}'),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: scheme.secondary),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.verseOfTheDay,
                    style: TextStyle(color: scheme.secondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.6),
                  ),
                  const Spacer(),
                  Text('${surah.englishName} ${ayah.key}', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                ayah.text,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: ArabicStyles.ayah(context, scale: 0.8, font: settings.arabicFont),
              ),
              const SizedBox(height: 6),
              translation.when(
                data: (list) => Text(
                  list[ayah.numberInSurah - 1],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, height: 1.5, color: scheme.onSurfaceVariant),
                ),
                loading: () => const SizedBox(height: 20),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact surah list used as a side pane in the reader on wide screens.
class SurahSidebar extends ConsumerStatefulWidget {
  const SurahSidebar({super.key, required this.selected});
  final int selected;

  @override
  ConsumerState<SurahSidebar> createState() => _SurahSidebarState();
}

class _SurahSidebarState extends ConsumerState<SurahSidebar> {
  String _query = '';
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController(initialScrollOffset: ((widget.selected - 3) * 74.0).clamp(0, 114 * 74.0));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.quran;
    final surahs = _SurahListScreenState._filter(repo.surahs, _query);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: context.l10n.jumpToSurah,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            itemCount: surahs.length,
            itemBuilder: (context, i) {
              final s = surahs[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SurahTile(
                  surah: s,
                  compact: true,
                  selected: s.number == widget.selected,
                  onTap: () => context.go('/surah/${s.number}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Hisn al-Muslim shortcuts: the chapter for this time of day comes first.
class _AdhkarCard extends StatelessWidget {
  const _AdhkarCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final hour = DateTime.now().hour;
    final evening = hour >= 15 || hour < 3;
    final chips = <(String, IconData, int)>[
      if (evening) (l.evening, Icons.nights_stay_outlined, 27) else (l.morning, Icons.wb_sunny_outlined, 27),
      (l.sleep, Icons.bedtime_outlined, 28),
      (l.afterPrayer, Icons.mosque_outlined, 25),
      if (evening) (l.morning, Icons.wb_sunny_outlined, 27) else (l.evening, Icons.nights_stay_outlined, 27),
    ];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/adhkar'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.auto_awesome, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.hisnAlMuslim, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                        Text(l.hisnAlMuslimSubtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text('حِصْن', style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 20, color: scheme.primary)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final (label, icon, id) in chips) ...[
                      ActionChip(
                        avatar: Icon(icon, size: 16),
                        label: Text(label),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => context.push('/adhkar/$id'),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
