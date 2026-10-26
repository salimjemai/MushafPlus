import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:share_plus/share_plus.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/adhans.dart';
import '../../data/masjid.dart';
import '../../data/prayer_times.dart';
import '../../state/masjid_providers.dart';
import '../../state/providers.dart';
import '../../widgets/surah_number_badge.dart';

/// Today's prayer and iqama times for the selected masjid.
class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  Timer? _tick;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final masjids = ref.watch(masjidsProvider);
    final masjid = ref.watch(selectedMasjidProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: masjid == null
            ? Text(l.prayerTimes)
            : masjids.length > 1
                ? DropdownButton<String>(
                    value: masjid.id,
                    underline: const SizedBox.shrink(),
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                    items: [for (final m in masjids) DropdownMenuItem(value: m.id, child: Text(m.name))],
                    onChanged: (v) {
                      if (v != null) ref.read(masjidsProvider.notifier).select(v);
                    },
                  )
                : Text(masjid.name, overflow: TextOverflow.ellipsis),
        actions: [
          if (masjid != null) ...[
            IconButton(
              tooltip: l.monthlyTimetable,
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () => context.push('/prayer/month'),
            ),
            IconButton(
              tooltip: l.shareToday,
              icon: const Icon(Icons.ios_share),
              onPressed: () => Share.share(_todayText(masjid)),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                switch (v) {
                  case 'edit':
                    context.push('/prayer/edit?id=${masjid.id}');
                  case 'publish':
                    context.push('/prayer/publish?id=${masjid.id}');
                  case 'add':
                    context.push('/prayer/edit');
                  case 'delete':
                    _confirmDelete(masjid);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: ListTile(leading: const Icon(Icons.edit_outlined), title: Text(l.editMasjid))),
                PopupMenuItem(value: 'publish', child: ListTile(leading: const Icon(Icons.code), title: Text(l.shareEmbed))),
                PopupMenuItem(value: 'add', child: ListTile(leading: const Icon(Icons.add_location_alt_outlined), title: Text(l.addAnotherMasjid))),
                PopupMenuItem(value: 'delete', child: ListTile(leading: const Icon(Icons.delete_outline), title: Text(l.removeMasjid))),
              ],
            ),
          ],
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: masjid == null ? _setup(scheme) : _today(masjid, scheme),
        ),
      ),
    );
  }

  // ---- first run --------------------------------------------------------

  Widget _setup(ColorScheme scheme) {
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PatternPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مواقيت الصلاة', style: ArabicStyles.surahName(context, size: 30, color: AppColors.goldLight)),
              const SizedBox(height: 6),
              Text(l.prayerTimesForMasjid,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                l.prayerIntro,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.push('/prayer/edit'),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: Text(l.setUpMasjid),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/prayer/qibla'),
                icon: const Icon(Icons.explore_outlined),
                label: Text(l.qibla),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/prayer/adhan'),
                icon: const Icon(Icons.campaign_outlined),
                label: Text(l.adhan),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _locating ? null : _useMyLocation,
          icon: _locating
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.my_location),
          label: Text(l.useMyLocation),
        ),
        const SizedBox(height: 16),
        Text(
          l.methodsList,
          style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant, height: 1.5),
        ),
      ],
    );
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 30));
      final geo = ref.read(geocodingServiceProvider);
      final place = await geo.reverse(pos.latitude, pos.longitude);
      final tzId = await geo.timezoneFor(pos.latitude, pos.longitude);
      final m = Masjid(
        id: DateTime.now().millisecondsSinceEpoch.toRadixString(36),
        name: place?.city != null ? 'My location · ${place!.city}' : 'My location',
        street: '',
        city: place?.city ?? '',
        state: place?.state ?? '',
        postalCode: place?.postcode ?? '',
        countryCode: place?.countryCode ?? '',
        latitude: pos.latitude,
        longitude: pos.longitude,
        timezone: tzId,
      );
      await ref.read(masjidsProvider.notifier).save(m);
      ref.read(masjidsProvider.notifier).select(m.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.couldNotGetLocation('$e'))));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  // ---- today ------------------------------------------------------------

  Widget _today(Masjid masjid, ColorScheme scheme) {
    final l = context.l10n;
    final now = nowAt(masjid);
    final today = prayerTimesFor(masjid, DateTime(now.year, now.month, now.day));
    final next = today.nextAfter(now);
    final tomorrow = prayerTimesFor(masjid, DateTime(now.year, now.month, now.day + 1));
    final nextTime = next != null ? today[next] : tomorrow[Prayer.fajr];
    final nextLabel = next != null ? prayerLabel(context, next) : l.fajrTomorrow;
    final remaining = nextTime.difference(now);
    final hijri = hijriFromGregorian(DateTime(now.year, now.month, now.day), adjustmentDays: masjid.hijriAdjustment);
    final qibla = qiblaDirection(masjid.latitude, masjid.longitude);
    final isFriday = now.weekday == DateTime.friday;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PatternPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.yMMMMEEEEd().format(now),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        Text('$hijri', style: const TextStyle(color: AppColors.goldLight, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(
                          masjid.addressLine.isEmpty
                              ? '${masjid.latitude.toStringAsFixed(4)}, ${masjid.longitude.toStringAsFixed(4)}'
                              : masjid.addressLine,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.5),
                        ),
                        Text(
                          '${methodById(masjid.methodId).name} · ${masjid.asrHanafi ? l.asrHanafi : l.asrShafii} · ${masjid.timezone}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () => context.push('/prayer/qibla'),
                    child: _QiblaBadge(bearing: qibla),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, color: AppColors.goldLight, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.nextPrayerIn(nextLabel, DateFormat.jm().format(nextTime), _fmtDuration(remaining)),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              for (final p in Prayer.values)
                _PrayerRow(
                  prayer: p,
                  time: today[p],
                  iqama: iqamaMinutes(masjid, today, p),
                  isNext: p == next,
                  isPast: today[p].isBefore(now) && p != next,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.campaign_outlined, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.adhan, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        adhanFor(ref.watch(settingsProvider).adhanId, fajr: next == Prayer.fajr || next == null).name,
                        style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: l.playAdhan,
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => context.push('/prayer/adhan?play=1${next == Prayer.fajr || next == null ? '&fajr=1' : ''}'),
                ),
                IconButton(
                  tooltip: l.chooseAdhan,
                  icon: const Icon(Icons.library_music_outlined),
                  onPressed: () => context.push('/prayer/adhan'),
                ),
              ],
            ),
          ),
        ),
        if (masjid.jumuah.isNotEmpty || isFriday) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('الجمعة', style: ArabicStyles.surahName(context, size: 20, color: scheme.primary)),
                      const SizedBox(width: 10),
                      Text(l.jumuah, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const Spacer(),
                      if (isFriday)
                        Chip(label: Text(l.today), visualDensity: VisualDensity.compact, backgroundColor: scheme.primary.withValues(alpha: 0.12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (masjid.jumuah.isEmpty)
                    Text(l.noJumuahSet,
                        style: TextStyle(color: scheme.onSurfaceVariant))
                  else
                    for (var i = 0; i < masjid.jumuah.length; i++)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: SurahNumberBadge(number: i + 1, size: 34, color: scheme.secondary),
                        title: Text(formatMinutes(masjid.jumuah[i].minutes), style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text([
                          if (masjid.jumuah[i].khutbahMinutes != null)
                            l.khutbahAt(formatMinutes(masjid.jumuah[i].khutbahMinutes!)),
                          if (masjid.jumuah[i].label.isNotEmpty) masjid.jumuah[i].label,
                        ].join(' · ')),
                      ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => context.push('/prayer/publish?id=${masjid.id}'),
          icon: const Icon(Icons.web_outlined),
          label: Text(l.websiteWidget),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => context.push('/prayer/month'),
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(l.monthlyTimetable),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/prayer/edit?id=${masjid.id}'),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l.editMasjid),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l.timesFootnote(masjid.latitude.toStringAsFixed(5), masjid.longitude.toStringAsFixed(5), masjid.timezone),
          style: TextStyle(fontSize: 11.5, color: scheme.outline, height: 1.4),
        ),
      ],
    );
  }

  String _todayText(Masjid masjid) {
    final now = nowAt(masjid);
    final t = prayerTimesFor(masjid, DateTime(now.year, now.month, now.day));
    final b = StringBuffer()
      ..writeln('${masjid.name} · ${DateFormat.yMMMEd().format(now)}')
      ..writeln(masjid.addressLine)
      ..writeln();
    for (final p in Prayer.values) {
      final iq = iqamaMinutes(masjid, t, p);
      b.writeln('${p.label.padRight(8)} ${DateFormat.jm().format(t[p])}${iq != null ? '  (iqama ${formatMinutes(iq)})' : ''}');
    }
    for (var i = 0; i < masjid.jumuah.length; i++) {
      final j = masjid.jumuah[i];
      b.writeln("Jumu'ah ${i + 1}: ${formatMinutes(j.minutes)}${j.label.isNotEmpty ? ' · ${j.label}' : ''}");
    }
    b.write('\n${methodById(masjid.methodId).name} · generated by Mushaf+');
    return b.toString();
  }

  Future<void> _confirmDelete(Masjid masjid) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(context.l10n.removeMasjidQuestion(masjid.name)),
        content: Text(context.l10n.removeMasjidBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(context.l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(context.l10n.remove)),
        ],
      ),
    );
    if (ok == true) await ref.read(masjidsProvider.notifier).remove(masjid.id);
  }
}

String _fmtDuration(Duration d) {
  if (d.isNegative) return '0m';
  final h = d.inHours;
  final m = d.inMinutes % 60;
  return h > 0 ? '${h}h ${m}m' : '${m}m';
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.prayer,
    required this.time,
    required this.iqama,
    required this.isNext,
    required this.isPast,
  });

  final Prayer prayer;
  final DateTime time;
  final int? iqama;
  final bool isNext;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isNext ? scheme.primary : isPast ? scheme.onSurfaceVariant : scheme.onSurface;
    final label = prayerLabel(context, prayer);
    return Container(
      decoration: BoxDecoration(
        color: isNext ? scheme.primary.withValues(alpha: 0.08) : null,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(prayer.arabic,
                textDirection: TextDirection.rtl,
                style: ArabicStyles.surahName(context, size: 18, color: color)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: TextStyle(fontWeight: isNext ? FontWeight.w800 : FontWeight.w600, color: color, fontSize: 15)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateFormat.jm().format(time),
                  style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 16)),
              if (iqama != null)
                Text(context.l10n.iqamaAt(formatMinutes(iqama!)),
                    style: TextStyle(fontSize: 11.5, color: scheme.secondary, fontWeight: FontWeight.w600)),
            ],
          ),
          if (isNext) ...[
            const SizedBox(width: 10),
            Icon(Icons.circle, size: 10, color: scheme.primary),
          ],
        ],
      ),
    );
  }
}

class _QiblaBadge extends StatelessWidget {
  const _QiblaBadge({required this.bearing});
  final double bearing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Transform.rotate(
            angle: bearing * math.pi / 180,
            child: const Icon(Icons.navigation, color: AppColors.goldLight, size: 28),
          ),
        ),
        const SizedBox(height: 4),
        Text(context.l10n.qiblaDegrees(bearing.round()), style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }
}

/// Localised prayer name.
String prayerLabel(BuildContext context, Prayer p) => switch (p) {
      Prayer.fajr => context.l10n.fajr,
      Prayer.sunrise => context.l10n.sunrise,
      Prayer.dhuhr => context.l10n.dhuhr,
      Prayer.asr => context.l10n.asr,
      Prayer.maghrib => context.l10n.maghrib,
      Prayer.isha => context.l10n.isha,
    };

/// Copies text and shows a snackbar.
Future<void> copyWithToast(BuildContext context, String text, String message) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
