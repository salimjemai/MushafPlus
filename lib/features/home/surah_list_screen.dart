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
        actions: [
          IconButton(
            tooltip: l.searchTheQuran,
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              // The hero cards come and go with the query; keys keep the text
              // field's element (and the keyboard) alive across that change.
              if (showHero)
                const Column(
                  key: ValueKey('home-hero'),
                  children: [
                    _ContinueReadingCard(),
                    SizedBox(height: 12),
                    _TodayCard(),
                    SizedBox(height: 12),
                    _VerseOfTheDayCard(),
                    SizedBox(height: 16),
                  ],
                ),
              Row(
                key: const ValueKey('home-finder'),
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: l.findSurahHint,
                        prefixIcon: const Icon(Icons.search),
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
                    ),
                  ),
                  const SizedBox(width: 10),
                  SegmentedButton<_Tab>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: _Tab.surahs, label: Text(l.tabSurah)),
                      ButtonSegment(value: _Tab.juz, label: Text(l.tabJuz)),
                      ButtonSegment(value: _Tab.pages, label: Text(l.tabPage)),
                    ],
                    selected: {_tab},
                    onSelectionChanged: (s) => setState(() => _tab = s.first),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_query.trim().length >= 2)
                Padding(
                  key: const ValueKey('home-search-all'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.go('/search?q=${Uri.encodeQueryComponent(_query.trim())}'),
                    icon: const Icon(Icons.manage_search),
                    label: Text('${l.searchWholeQuran}: “${_query.trim()}”'),
                  ),
                ),
              if (_tab == _Tab.surahs) ...[
                if (surahs.isEmpty)
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
              ] else if (_tab == _Tab.juz) ...[
                for (final j in repo.juzs) ...[
                  _JuzTile(juz: j),
                  const SizedBox(height: 8),
                ],
              ] else ...[
                const _PageGrid(),
              ],
            ],
          ),
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
    final lq = q.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    final aq = containsArabic(q) ? normalizeArabic(q) : null;
    return all.where((s) {
      if (aq != null) return normalizeArabic(s.name).contains(aq);
      final en = s.englishName.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
      final tr = s.englishNameTranslation.toLowerCase().replaceAll(' ', '');
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
