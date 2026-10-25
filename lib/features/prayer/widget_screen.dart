import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/masjid.dart';
import '../../data/masjid_share.dart';
import '../../data/prayer_times.dart';
import '../../state/masjid_providers.dart';
import 'prayer_screen.dart' show prayerLabel;

/// The embeddable prayer-time widget (and the TV display): a self-contained
/// page whose masjid is carried in the link, like DeenTime's public widgets.
class PrayerWidgetScreen extends StatefulWidget {
  const PrayerWidgetScreen({
    super.key,
    required this.code,
    this.view = WidgetView.combined,
    this.tv = false,
    this.theme,
    this.scale = 1,
    this.lang,
  });

  final String code;
  final WidgetView view;
  final bool tv;

  /// `light`, `dark` or null for the system setting.
  final String? theme;

  /// Font scale, 0.75 – 1.6.
  final double scale;

  /// Interface language of the widget (en, ar, fr, ur, id, tr); null follows the app.
  final String? lang;

  @override
  State<PrayerWidgetScreen> createState() => _PrayerWidgetScreenState();
}

class _PrayerWidgetScreenState extends State<PrayerWidgetScreen> {
  late final Masjid? _masjid = decodeMasjid(widget.code);
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(Duration(seconds: widget.tv ? 1 : 20), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    if (lang != null && AppLocalizations.supportedLocales.any((x) => x.languageCode == lang)) {
      return Localizations.override(
        context: context,
        locale: Locale(lang),
        child: Builder(builder: _build),
      );
    }
    return _build(context);
  }

  Widget _build(BuildContext context) {
    final l = context.l10n;
    final dark = widget.theme == 'dark' || (widget.theme != 'light' && (widget.tv || MediaQuery.platformBrightnessOf(context) == Brightness.dark));
    final p = _Palette(dark);
    final m = _masjid;
    if (m == null) {
      return Scaffold(
        backgroundColor: p.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.invalidWidgetLink, textAlign: TextAlign.center, style: TextStyle(color: p.fg)),
          ),
        ),
      );
    }

    final body = _WidgetBody(masjid: m, view: widget.view, tv: widget.tv, palette: p, scale: widget.scale.clamp(0.75, 1.6));
    return Scaffold(
      backgroundColor: p.bg,
      body: widget.tv
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark ? const [Color(0xFF0B1512), Color(0xFF13201B)] : const [Color(0xFFF7F3E8), Color(0xFFE9E1CC)],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(width: 1120, child: body),
                  ),
                ),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: widget.view == WidgetView.compact ? 380 : 460),
                    child: body,
                  ),
                ),
              ),
            ),
    );
  }
}

class _Palette {
  _Palette(this.dark);
  final bool dark;
  Color get bg => dark ? const Color(0xFF0F1512) : Colors.white;
  Color get card => dark ? const Color(0xFF17201B) : const Color(0xFFF6F3EA);
  Color get fg => dark ? const Color(0xFFECE8DC) : const Color(0xFF1C2420);
  Color get muted => dark ? const Color(0xFFA9B3AC) : const Color(0xFF5E6A63);
  Color get line => dark ? const Color(0xFF26332C) : const Color(0xFFE3DCC8);
  Color get primary => dark ? const Color(0xFF7FCBA4) : AppColors.emerald;
  Color get gold => AppColors.gold;
}

class _WidgetBody extends StatelessWidget {
  const _WidgetBody({required this.masjid, required this.view, required this.tv, required this.palette, required this.scale});
  final Masjid masjid;
  final WidgetView view;
  final bool tv;
  final _Palette palette;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = palette;
    final m = masjid;
    final now = nowAt(m);
    final date = DateTime(now.year, now.month, now.day);
    final today = prayerTimesFor(m, date);
    final next = today.nextAfter(now);
    final tomorrow = prayerTimesFor(m, DateTime(now.year, now.month, now.day + 1));
    final nextTime = next != null ? today[next] : tomorrow[Prayer.fajr];
    final nextLabel = next != null ? prayerLabel(context, next) : l.fajrTomorrow;
    final remaining = nextTime.difference(now);
    final hijri = hijriFromGregorian(date, adjustmentDays: m.hijriAdjustment);
    final compact = view == WidgetView.compact;
    final s = scale * (tv ? 1.9 : compact ? 0.92 : 1);
    final showDaily = view != WidgetView.jumuah;
    final showJumuah = view != WidgetView.daily && (m.jumuah.isNotEmpty || view == WidgetView.jumuah);
    final pad = compact ? 12.0 : 18.0;

    TextStyle t(double size, {FontWeight? w, Color? c, String? family}) =>
        TextStyle(fontSize: size * s, fontWeight: w, color: c ?? p.fg, fontFamily: family, height: 1.25);

    return Padding(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ---- header ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name, style: t(compact ? 17 : 21, w: FontWeight.w800)),
                    if (m.addressLine.isNotEmpty && !compact)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(m.addressLine, style: t(11.5, c: p.muted), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    const SizedBox(height: 6),
                    Text(DateFormat.yMMMMEEEEd().format(now), style: t(12.5, c: p.muted)),
                    Text('${hijri.day} ${hijri.monthName} ${hijri.year} AH', style: t(12.5, c: p.gold, w: FontWeight.w600)),
                  ],
                ),
              ),
              if (tv)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(DateFormat.jm().format(now), style: t(34, w: FontWeight.w800, c: p.primary)),
                    Text(DateFormat.Hms().format(now), style: t(12, c: p.muted)),
                  ],
                )
              else
                Text('مسجد', style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 20 * s, color: p.gold)),
            ],
          ),
          SizedBox(height: pad * 0.8),
          // ---- next prayer ----
          Container(
            padding: EdgeInsets.symmetric(horizontal: pad, vertical: pad * 0.7),
            decoration: BoxDecoration(color: p.primary.withValues(alpha: p.dark ? 0.18 : 0.12), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Icon(Icons.notifications_active_outlined, color: p.primary, size: 22 * s),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Text(
                    l.nextPrayerIn(nextLabel, DateFormat.jm().format(nextTime), _fmt(remaining, tv)),
                    style: t(compact ? 13 : 14.5, w: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          if (showDaily) ...[
            SizedBox(height: pad * 0.8),
            Container(
              decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.line)),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(pad, 10, pad, 6),
                    child: Row(
                      children: [
                        Expanded(flex: 5, child: Text(l.prayerTimes.toUpperCase(), style: t(10.5, c: p.muted, w: FontWeight.w700))),
                        Expanded(flex: 3, child: Text(l.adhanHeader.toUpperCase(), textAlign: TextAlign.end, style: t(10.5, c: p.muted, w: FontWeight.w700))),
                        Expanded(flex: 3, child: Text(l.iqama.toUpperCase(), textAlign: TextAlign.end, style: t(10.5, c: p.muted, w: FontWeight.w700))),
                      ],
                    ),
                  ),
                  for (final pr in Prayer.values)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: pad, vertical: compact ? 7 : 10),
                      decoration: BoxDecoration(
                        color: pr == next ? p.primary.withValues(alpha: 0.14) : null,
                        border: Border(top: BorderSide(color: p.line)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                Text(prayerLabel(context, pr), style: t(15, w: pr == next ? FontWeight.w800 : FontWeight.w600, c: pr == next ? p.primary : p.fg)),
                                SizedBox(width: 8 * s),
                                Text(pr.arabic, style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 15 * s, color: p.muted)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(DateFormat.jm().format(today[pr]), textAlign: TextAlign.end, style: t(15, w: FontWeight.w600)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              iqamaMinutes(m, today, pr) == null ? '—' : formatMinutes(iqamaMinutes(m, today, pr)!),
                              textAlign: TextAlign.end,
                              style: t(15, w: FontWeight.w800, c: iqamaMinutes(m, today, pr) == null ? p.muted : p.fg),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (showJumuah) ...[
            SizedBox(height: pad * 0.8),
            Container(
              padding: EdgeInsets.all(pad),
              decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.line)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('الجمعة', style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: 20 * s, fontWeight: FontWeight.w700, color: p.primary)),
                      SizedBox(width: 10 * s),
                      Text(l.jumuah, style: t(15, w: FontWeight.w800)),
                      const Spacer(),
                      if (now.weekday == DateTime.friday) Text(l.today, style: t(12, c: p.gold, w: FontWeight.w700)),
                    ],
                  ),
                  SizedBox(height: 6 * s),
                  if (m.jumuah.isEmpty)
                    Text(l.noJumuahSet, style: t(13, c: p.muted))
                  else
                    for (var i = 0; i < m.jumuah.length; i++)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4 * s),
                        child: Row(
                          children: [
                            Container(
                              width: 26 * s,
                              height: 26 * s,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: p.gold.withValues(alpha: 0.2)),
                              child: Text('${i + 1}', style: t(12, w: FontWeight.w800, c: p.gold)),
                            ),
                            SizedBox(width: 10 * s),
                            Text(formatMinutes(m.jumuah[i].minutes), style: t(16, w: FontWeight.w800)),
                            SizedBox(width: 10 * s),
                            Expanded(
                              child: Text(
                                [
                                  if (m.jumuah[i].khutbahMinutes != null) l.khutbahAt(formatMinutes(m.jumuah[i].khutbahMinutes!)),
                                  if (m.jumuah[i].label.isNotEmpty) m.jumuah[i].label,
                                ].join(' · '),
                                style: t(12.5, c: p.muted),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ],
          SizedBox(height: pad * 0.7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(methodById(m.methodId).name, style: t(10.5, c: p.muted), overflow: TextOverflow.ellipsis),
              Text(l.poweredBy, style: t(10.5, c: p.muted, w: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(Duration d, bool withSeconds) {
    if (d.isNegative) return '0m';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (withSeconds) {
      final s = d.inSeconds % 60;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
}
