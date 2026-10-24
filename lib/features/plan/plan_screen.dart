import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/quran_repository.dart';
import '../../state/providers.dart';
import '../../state/reading_stats.dart';

/// Daily goal, streak, last-7-days chart and a khatm (complete reading) plan.
class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final stats = ref.watch(readingStatsProvider);
    final repo = ref.quran;
    final lastRead = ref.watch(lastReadProvider)?.ayahNumber ?? 1;
    final memorized = ref.watch(memorizedProvider).length;
    final scheme = Theme.of(context).colorScheme;
    final plan = stats.plan;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(l.readingPlan),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ---- today ---------------------------------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      GoalRing(progress: stats.readToday / stats.dailyGoal, size: 92,
                          label: '${stats.readToday}', sublabel: 'of ${stats.dailyGoal}'),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.today, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              stats.readToday >= stats.dailyGoal
                                  ? l.goalReached
                                  : l.moreAyahsToGoal(stats.dailyGoal - stats.readToday),
                              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.local_fire_department, color: AppColors.gold, size: 20),
                                const SizedBox(width: 4),
                                Text(l.dayStreak(stats.streak), style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ---- daily goal ----------------------------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.dailyGoal, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(l.ayahsPerDay(stats.dailyGoal), style: TextStyle(color: scheme.onSurfaceVariant)),
                      Slider(
                        value: stats.dailyGoal.toDouble().clamp(5, 300),
                        min: 5,
                        max: 300,
                        divisions: 59,
                        label: '${stats.dailyGoal}',
                        onChanged: (v) => ref.read(readingStatsProvider.notifier).setDailyGoal(v.round()),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final g in const [10, 20, 50, 100, 208])
                            ChoiceChip(
                              label: Text(g == 208 ? l.khatmIn30Days : '$g'),
                              selected: stats.dailyGoal == g,
                              onSelected: (_) => ref.read(readingStatsProvider.notifier).setDailyGoal(g),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ---- last 7 days ---------------------------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.last7Days, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _WeekChart(stats: stats),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _Stat(label: l.ayahsRead, value: '${stats.totalAyahsRead}'),
                          _Stat(label: l.activeDays, value: '${stats.activeDays}'),
                          _Stat(label: l.memorized, value: '$memorized'),
                          _Stat(label: l.quranRead, value: '${(lastRead / QuranRepository.totalAyahs * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ---- khatm plan ----------------------------------------------
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: plan == null
                      ? _StartPlan(lastRead: lastRead)
                      : _PlanStatus(plan: plan, lastRead: lastRead, repo: repo),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: scheme.primary)),
          Text(label, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.stats});
  final ReadingStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final days = [for (var i = 6; i >= 0; i--) today.subtract(Duration(days: i))];
    final max = [stats.dailyGoal, ...days.map(stats.readOn)].reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${stats.readOn(d)}', style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Container(
                      height: 70 * (stats.readOn(d) / max).clamp(0.03, 1.0),
                      decoration: BoxDecoration(
                        color: stats.goalMetOn(d) ? scheme.primary : scheme.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(DateFormat.E().format(d).substring(0, 2), style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StartPlan extends ConsumerStatefulWidget {
  const _StartPlan({required this.lastRead});
  final int lastRead;

  @override
  ConsumerState<_StartPlan> createState() => _StartPlanState();
}

class _StartPlanState extends ConsumerState<_StartPlan> {
  int _days = 30;
  bool _fromStart = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final startAyah = _fromStart ? 1 : widget.lastRead;
    final perDay = ((QuranRepository.totalAyahs - startAyah + 1) / _days).ceil();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.khatmPlan, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(l.khatmPlanHelp,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final d in const [30, 60, 90, 180, 365])
              ChoiceChip(label: Text(l.nDays(d)), selected: _days == d, onSelected: (_) => setState(() => _days = d)),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.startFromFatiha),
          subtitle: Text(_fromStart ? l.fromTheBeginning : l.fromWhereYouAre),
          value: _fromStart,
          onChanged: (v) => setState(() => _fromStart = v),
        ),
        Text(l.aboutAyahsADay(perDay), style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => ref.read(readingStatsProvider.notifier).startPlan(days: _days, startAyah: startAyah),
          icon: const Icon(Icons.flag),
          label: Text(l.startPlan),
        ),
      ],
    );
  }
}

class _PlanStatus extends ConsumerWidget {
  const _PlanStatus({required this.plan, required this.lastRead, required this.repo});
  final KhatmPlan plan;
  final int lastRead;
  final QuranRepository repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final target = plan.targetAyahFor(now);
    final behind = target - lastRead;
    final progress = ((lastRead - plan.startAyah + 1) / plan.totalAyahs).clamp(0.0, 1.0);
    final targetAyah = repo.ayah(target);
    final day = plan.dayNumber(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l.khatmPlan, style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(
              onPressed: () => ref.read(readingStatsProvider.notifier).cancelPlan(),
              child: Text(l.endPlan),
            ),
          ],
        ),
        Text(
          l.planStatusLine(day.clamp(1, plan.days), plan.days, DateFormat.yMMMd().format(plan.endDate), plan.perDay),
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: progress, minHeight: 8),
        ),
        const SizedBox(height: 10),
        Text(
          behind < 0
              ? l.onTrackAhead(-behind)
              : behind == 0
                  ? l.onTrack
                  : l.catchUp(behind),
          style: TextStyle(fontWeight: FontWeight.w600, color: behind <= 0 ? scheme.primary : scheme.error),
        ),
        const SizedBox(height: 4),
        Text(l.todaysTarget(repo.surah(targetAyah.surah).englishName, targetAyah.key),
            style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 10),
        FilledButton.tonalIcon(
          onPressed: () {
            final a = repo.ayah(lastRead);
            context.go('/surah/${a.surah}?ayah=${a.numberInSurah}');
          },
          icon: const Icon(Icons.menu_book),
          label: Text(l.continueReadingButton),
        ),
      ],
    );
  }
}

/// Circular progress ring with a value in the middle.
class GoalRing extends StatelessWidget {
  const GoalRing({super.key, required this.progress, required this.label, this.sublabel, this.size = 72});
  final double progress;
  final String label;
  final String? sublabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = progress >= 1;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0, 1),
            strokeWidth: size * 0.09,
            strokeCap: StrokeCap.round,
            backgroundColor: scheme.primary.withValues(alpha: 0.12),
            color: done ? AppColors.gold : scheme.primary,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: TextStyle(fontSize: size * 0.24, fontWeight: FontWeight.w800, height: 1)),
                if (sublabel != null)
                  Text(sublabel!, style: TextStyle(fontSize: size * 0.12, color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
