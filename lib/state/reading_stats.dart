import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/quran_repository.dart';
import '../data/storage.dart';

String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime _parseDay(String k) {
  final p = k.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

/// A khatm (complete reading) plan: finish from [startAyah] to the end of the
/// Quran in [days] days, starting on [start].
@immutable
class KhatmPlan {
  const KhatmPlan({required this.start, required this.days, required this.startAyah});
  final DateTime start;
  final int days;
  final int startAyah;

  int get totalAyahs => QuranRepository.totalAyahs - startAyah + 1;
  int get perDay => (totalAyahs / days).ceil();

  /// Day index (1-based) for [date]; may exceed [days] when overdue.
  int dayNumber(DateTime date) =>
      DateTime(date.year, date.month, date.day).difference(DateTime(start.year, start.month, start.day)).inDays + 1;

  /// The global ayah the reader should have reached by the end of [date].
  int targetAyahFor(DateTime date) =>
      (startAyah - 1 + dayNumber(date) * perDay).clamp(startAyah, QuranRepository.totalAyahs);

  DateTime get endDate => start.add(Duration(days: days - 1));

  Map<String, dynamic> toMap() => {'start': dayKey(start), 'days': days, 'startAyah': startAyah};

  factory KhatmPlan.fromMap(Map<dynamic, dynamic> m) => KhatmPlan(
        start: _parseDay(m['start'] as String),
        days: m['days'] as int,
        startAyah: m['startAyah'] as int,
      );
}

@immutable
class ReadingStats {
  const ReadingStats({
    required this.dailyGoal,
    required this.log,
    required this.plan,
  });

  /// Ayahs per day the user aims for.
  final int dailyGoal;

  /// dayKey -> distinct global ayah numbers read that day (last 90 days).
  final Map<String, Set<int>> log;
  final KhatmPlan? plan;

  int readOn(DateTime d) => log[dayKey(d)]?.length ?? 0;
  int get readToday => readOn(DateTime.now());
  bool goalMetOn(DateTime d) => readOn(d) >= dailyGoal;

  /// Consecutive days (ending today or yesterday) on which the goal was met.
  int get streak {
    var day = DateTime.now();
    if (!goalMetOn(day)) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while (goalMetOn(day)) {
      n++;
      day = day.subtract(const Duration(days: 1));
    }
    return n;
  }

  int get totalAyahsRead {
    final all = <int>{};
    for (final s in log.values) {
      all.addAll(s);
    }
    return all.length;
  }

  int get activeDays => log.values.where((s) => s.isNotEmpty).length;

  ReadingStats copyWith({int? dailyGoal, Map<String, Set<int>>? log, KhatmPlan? plan, bool clearPlan = false}) {
    return ReadingStats(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      log: log ?? this.log,
      plan: clearPlan ? null : (plan ?? this.plan),
    );
  }
}

class ReadingStatsNotifier extends Notifier<ReadingStats> {
  static const _goalKey = 'dailyGoal';
  static const _logKey = 'readLog';
  static const _planKey = 'khatmPlan';

  @override
  ReadingStats build() {
    final goal = (Storage.settings.get(_goalKey) as int?) ?? 20;
    final rawLog = Storage.settings.get(_logKey);
    final log = <String, Set<int>>{};
    if (rawLog is Map) {
      rawLog.forEach((k, v) {
        if (v is List) log[k as String] = v.cast<int>().toSet();
      });
    }
    final rawPlan = Storage.settings.get(_planKey);
    return ReadingStats(
      dailyGoal: goal,
      log: log,
      plan: rawPlan is Map ? KhatmPlan.fromMap(rawPlan) : null,
    );
  }

  /// Records that [ayahNumber] was read now.
  void recordRead(int ayahNumber) {
    final key = dayKey(DateTime.now());
    final today = state.log[key] ?? <int>{};
    if (today.contains(ayahNumber)) return;
    final log = Map<String, Set<int>>.from(state.log);
    log[key] = {...today, ayahNumber};
    // Keep the log bounded.
    if (log.length > 90) {
      final keys = log.keys.toList()..sort();
      for (final k in keys.take(log.length - 90)) {
        log.remove(k);
      }
    }
    state = state.copyWith(log: log);
    Storage.settings.put(_logKey, {for (final e in log.entries) e.key: e.value.toList()});
  }

  void setDailyGoal(int goal) {
    state = state.copyWith(dailyGoal: goal);
    Storage.settings.put(_goalKey, goal);
  }

  void startPlan({required int days, required int startAyah}) {
    final p = KhatmPlan(start: DateTime.now(), days: days, startAyah: startAyah);
    state = state.copyWith(plan: p);
    Storage.settings.put(_planKey, p.toMap());
  }

  void cancelPlan() {
    state = state.copyWith(clearPlan: true);
    Storage.settings.delete(_planKey);
  }
}

final readingStatsProvider =
    NotifierProvider<ReadingStatsNotifier, ReadingStats>(ReadingStatsNotifier.new);
