import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/masjid.dart';
import '../../data/prayer_times.dart';
import '../../state/masjid_providers.dart';
import 'prayer_screen.dart';

/// Month-at-a-glance timetable, shareable as text or CSV (for the masjid's
/// website, notice board or PDF).
class MonthlyTimetableScreen extends ConsumerStatefulWidget {
  const MonthlyTimetableScreen({super.key});

  @override
  ConsumerState<MonthlyTimetableScreen> createState() => _MonthlyTimetableScreenState();
}

class _MonthlyTimetableScreenState extends ConsumerState<MonthlyTimetableScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool _showIqama = true;

  @override
  Widget build(BuildContext context) {
    final masjid = ref.watch(selectedMasjidProvider);
    final scheme = Theme.of(context).colorScheme;
    if (masjid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Monthly timetable')),
        body: const Center(child: Text('Set up a masjid first.')),
      );
    }
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    final rows = [for (var d = 1; d <= days; d++) prayerTimesFor(masjid, DateTime(_month.year, _month.month, d))];
    final now = nowAt(masjid);
    final fmt = DateFormat.jm();
    final hasIqama = masjid.iqama.values.any((r) => r.mode != IqamaMode.none);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/prayer'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(masjid.name, overflow: TextOverflow.ellipsis),
            Text(DateFormat.yMMMM().format(_month),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          if (hasIqama)
            IconButton(
              tooltip: _showIqama ? 'Hide iqama' : 'Show iqama',
              icon: Icon(_showIqama ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _showIqama = !_showIqama),
            ),
          IconButton(
            tooltip: 'Copy as CSV',
            icon: const Icon(Icons.table_view_outlined),
            onPressed: () => copyWithToast(context, _csv(masjid, rows), 'CSV copied — paste into Excel or Sheets'),
          ),
          IconButton(
            tooltip: 'Share as text',
            icon: const Icon(Icons.ios_share),
            onPressed: () => Share.share(_text(masjid, rows), subject: '${masjid.name} prayer times ${DateFormat.yMMMM().format(_month)}'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)), icon: const Icon(Icons.chevron_left)),
                Expanded(
                  child: Text(DateFormat.yMMMM().format(_month), textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)), icon: const Icon(Icons.chevron_right)),
                TextButton(
                  onPressed: () => setState(() => _month = DateTime(now.year, now.month)),
                  child: const Text('This month'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: DataTable(
                  headingRowHeight: 40,
                  dataRowMinHeight: 36,
                  dataRowMaxHeight: _showIqama && hasIqama ? 52 : 40,
                  columnSpacing: 18,
                  columns: [
                    const DataColumn(label: Text('Date')),
                    for (final p in Prayer.values) DataColumn(label: Text(p.label)),
                  ],
                  rows: [
                    for (final r in rows)
                      DataRow(
                        color: WidgetStatePropertyAll(
                          r.date.year == now.year && r.date.month == now.month && r.date.day == now.day
                              ? scheme.primary.withValues(alpha: 0.12)
                              : r.date.weekday == DateTime.friday
                                  ? scheme.secondary.withValues(alpha: 0.08)
                                  : null,
                        ),
                        cells: [
                          DataCell(Text(
                            DateFormat('EEE d').format(r.date),
                            style: TextStyle(fontWeight: r.date.weekday == DateTime.friday ? FontWeight.w800 : FontWeight.w600),
                          )),
                          for (final p in Prayer.values)
                            DataCell(
                              _showIqama && hasIqama && iqamaMinutes(masjid, r, p) != null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(fmt.format(r[p])),
                                        Text(formatMinutes(iqamaMinutes(masjid, r, p)!),
                                            style: TextStyle(fontSize: 11, color: scheme.secondary, fontWeight: FontWeight.w600)),
                                      ],
                                    )
                                  : Text(fmt.format(r[p])),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (masjid.jumuah.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                "Jumu'ah: ${masjid.jumuah.map((j) => formatMinutes(j.minutes) + (j.label.isNotEmpty ? ' (${j.label})' : '')).join(' · ')}",
                style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  String _csv(Masjid m, List<PrayerTimes> rows) {
    final fmt = DateFormat.Hm();
    final b = StringBuffer()..writeln('Date,${Prayer.values.map((p) => p.label).join(',')}');
    for (final r in rows) {
      b.writeln('${DateFormat('yyyy-MM-dd').format(r.date)},${Prayer.values.map((p) => fmt.format(r[p])).join(',')}');
    }
    return b.toString();
  }

  String _text(Masjid m, List<PrayerTimes> rows) {
    final fmt = DateFormat.Hm();
    final b = StringBuffer()
      ..writeln('${m.name} · ${DateFormat.yMMMM().format(_month)}')
      ..writeln(m.addressLine)
      ..writeln('${methodById(m.methodId).name} · Asr ${m.asrHanafi ? 'Hanafi' : "Shafi'i"}')
      ..writeln()
      ..writeln('Day    ${Prayer.values.map((p) => p.label.padRight(8)).join()}');
    for (final r in rows) {
      b.writeln('${DateFormat('EEE d').format(r.date).padRight(7)}${Prayer.values.map((p) => fmt.format(r[p]).padRight(8)).join()}');
    }
    if (m.jumuah.isNotEmpty) {
      b.writeln();
      b.writeln("Jumu'ah: ${m.jumuah.map((j) => formatMinutes(j.minutes) + (j.label.isNotEmpty ? ' (${j.label})' : '')).join(', ')}");
    }
    b.write('\nGenerated by Quran+');
    return b.toString();
  }
}
