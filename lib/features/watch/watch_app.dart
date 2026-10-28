import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/compass.dart' as compass;
import '../../data/prayer_times.dart';
import '../../data/storage.dart';
import '../../data/translation_service.dart';
import '../../state/masjid_providers.dart';
import '../../state/providers.dart';
import '../prayer/locate.dart';
import '../prayer/prayer_screen.dart' show prayerLabel;
import 'watch_recite_page.dart';

/// The Wear OS interface: a handful of swipeable pages sized for a 1.2–1.5"
/// (often round) screen on a black background, as Wear's design guidance
/// asks. Everything here reads the same providers as the phone app, so a
/// watch set up on its own (standalone) behaves like the phone would.
class WatchApp extends ConsumerWidget {
  const WatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final locale = settings.locale == null ? null : Locale(settings.locale!);
    final base = AppTheme.dark();
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: base.colorScheme.copyWith(surface: Colors.black),
        visualDensity: VisualDensity.compact,
      ),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const WatchShell(),
    );
  }
}

/// Padding that keeps content inside the circle of a round watch face.
EdgeInsets watchInsets(BuildContext context, WidgetRef ref) {
  final round = ref.watch(deviceFormProvider).round;
  final side = MediaQuery.sizeOf(context).shortestSide;
  return EdgeInsets.all(round ? side * 0.11 : 8);
}

class WatchShell extends ConsumerStatefulWidget {
  const WatchShell({super.key});

  @override
  ConsumerState<WatchShell> createState() => _WatchShellState();
}

class _WatchShellState extends ConsumerState<WatchShell> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const pages = [
      WatchPrayerPage(),
      WatchQiblaPage(),
      WatchTasbihPage(),
      WatchVersePage(),
      WatchRecitePage(),
    ];
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: pages,
          ),
          // Page dots, inside the bottom of the circle.
          Positioned(
            left: 0,
            right: 0,
            bottom: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  Container(
                    width: i == _page ? 7 : 5,
                    height: i == _page ? 7 : 5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page ? scheme.primary : scheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String watchDuration(Duration d) {
  if (d.isNegative) return '0m';
  final h = d.inHours;
  final m = d.inMinutes % 60;
  return h > 0 ? '${h}h ${m}m' : '${m}m';
}

// ---- prayer times ---------------------------------------------------------

class WatchPrayerPage extends ConsumerStatefulWidget {
  const WatchPrayerPage({super.key});

  @override
  ConsumerState<WatchPrayerPage> createState() => _WatchPrayerPageState();
}

class _WatchPrayerPageState extends ConsumerState<WatchPrayerPage> {
  Timer? _tick;
  bool _locating = false;
  String? _error;

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

  Future<void> _useMyLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      final m = await locateDevice(ref);
      await ref.read(myLocationProvider.notifier).save(m);
      ref.read(settingsProvider.notifier).setPrayerMode('personal');
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final place = ref.watch(activePlaceProvider);
    final insets = watchInsets(context, ref);

    if (place == null) {
      return Padding(
        padding: insets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mosque_outlined, color: scheme.primary, size: 22),
            const SizedBox(height: 6),
            Text(l.watchNoPlace, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, height: 1.3)),
            const SizedBox(height: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), textStyle: const TextStyle(fontSize: 11)),
              onPressed: _locating ? null : _useMyLocation,
              icon: _locating
                  ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location, size: 14),
              label: Text(l.useLocationShort),
            ),
            if (_error != null)
              Text(l.couldNotGetLocation(_error!), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: scheme.error)),
          ],
        ),
      );
    }

    final now = nowAt(place);
    final today = prayerTimesFor(place, DateTime(now.year, now.month, now.day));
    final next = today.nextAfter(now);
    final tomorrow = prayerTimesFor(place, DateTime(now.year, now.month, now.day + 1));
    final nextTime = next != null ? today[next] : tomorrow[Prayer.fajr];
    final nextLabel = next != null ? prayerLabel(context, next) : l.fajrTomorrow;
    final remaining = nextTime.difference(now);
    final fmt = DateFormat.jm();

    return ListView(
      padding: insets.copyWith(bottom: insets.bottom + 8),
      children: [
        Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
        Text(nextLabel, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.primary)),
        Text(
          l.inDuration(watchDuration(remaining)),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.1),
        ),
        Text(fmt.format(nextTime), textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
        const SizedBox(height: 6),
        for (final p in Prayer.values)
          if (p.isSalah)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      prayerLabel(context, p),
                      style: TextStyle(fontSize: 11, fontWeight: p == next ? FontWeight.w700 : FontWeight.w500, color: p == next ? scheme.primary : (today[p].isBefore(now) ? scheme.onSurfaceVariant : scheme.onSurface)),
                    ),
                  ),
                  Text(
                    fmt.format(today[p]),
                    style: TextStyle(fontSize: 11, fontWeight: p == next ? FontWeight.w700 : FontWeight.w500, color: p == next ? scheme.primary : (today[p].isBefore(now) ? scheme.onSurfaceVariant : scheme.onSurface)),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

// ---- qibla ----------------------------------------------------------------

class WatchQiblaPage extends ConsumerStatefulWidget {
  const WatchQiblaPage({super.key});

  @override
  ConsumerState<WatchQiblaPage> createState() => _WatchQiblaPageState();
}

class _WatchQiblaPageState extends ConsumerState<WatchQiblaPage> {
  StreamSubscription<double?>? _sub;
  double? _heading;
  double? _lat;
  double? _lng;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    if (compass.compassSupported) {
      _sub = compass.headingStream().listen((h) {
        if (mounted) setState(() => _heading = h);
      }, onError: (_) {});
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _useDevice() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 30));
      if (mounted) {
        setState(() {
          _lat = pos.latitude;
          _lng = pos.longitude;
        });
      }
    } catch (_) {
      // Keep whatever we had.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final place = ref.watch(activePlaceProvider);
    final lat = _lat ?? place?.latitude;
    final lng = _lng ?? place?.longitude;
    final insets = watchInsets(context, ref);

    if (lat == null || lng == null) {
      return Padding(
        padding: insets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l.qibla, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.primary)),
            const SizedBox(height: 6),
            FilledButton.icon(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), textStyle: const TextStyle(fontSize: 11)),
              onPressed: _locating ? null : _useDevice,
              icon: const Icon(Icons.my_location, size: 14),
              label: Text(l.useLocationShort),
            ),
          ],
        ),
      );
    }

    final qibla = qiblaDirection(lat, lng);
    final heading = _heading;
    final relative = ((qibla - (heading ?? 0)) % 360 + 360) % 360;
    final aligned = heading != null && (relative < 4 || relative > 356);
    final status = aligned
        ? l.facingQibla
        : heading == null
            ? (compass.compassSupported ? l.compassWaiting : l.compassUnavailable)
            : l.turnToQibla(relative <= 180 ? l.right : l.left, (relative <= 180 ? relative : 360 - relative).round());

    return Padding(
      padding: insets,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _WatchDialPainter(heading: heading, qibla: qibla, aligned: aligned, scheme: scheme),
            ),
          ),
          Text('${qibla.round()}°', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: aligned ? scheme.primary : AppColors.gold, height: 1.1)),
          Text(status, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: aligned ? scheme.primary : scheme.onSurfaceVariant)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

/// A small dial: north rotates with the heading, the gold ray points at the
/// Kaaba, the fixed tick at the top is where the watch is facing.
class _WatchDialPainter extends CustomPainter {
  _WatchDialPainter({required this.heading, required this.qibla, required this.aligned, required this.scheme});
  final double? heading;
  final double qibla;
  final bool aligned;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 4;
    if (r <= 0) return;
    canvas.drawCircle(c, r, Paint()..color = scheme.onSurface.withValues(alpha: 0.08));
    canvas.drawCircle(c, r, Paint()..color = scheme.outlineVariant..style = PaintingStyle.stroke..strokeWidth = 1.5);
    final rot = -(heading ?? 0);
    final tick = Paint()..color = scheme.onSurfaceVariant..strokeWidth = 1;
    for (var d = 0; d < 360; d += 30) {
      final a = (d + rot - 90) * math.pi / 180;
      final len = d == 0 ? 8.0 : 4.0;
      canvas.drawLine(c + Offset(math.cos(a) * (r - len), math.sin(a) * (r - len)), c + Offset(math.cos(a) * r, math.sin(a) * r), d == 0 ? (Paint()..color = scheme.error..strokeWidth = 2) : tick);
    }
    final qa = (qibla + rot - 90) * math.pi / 180;
    final rim = c + Offset(math.cos(qa) * (r - 9), math.sin(qa) * (r - 9));
    final gold = aligned ? scheme.primary : AppColors.gold;
    canvas.drawLine(c, rim, Paint()..color = gold..strokeWidth = 3..strokeCap = StrokeCap.round);
    canvas.drawCircle(rim, 8, Paint()..color = gold);
    final tp = TextPainter(text: const TextSpan(text: '🕋', style: TextStyle(fontSize: 10)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, rim - Offset(tp.width / 2, tp.height / 2));
    // Where the watch points.
    final top = c + Offset(0, -r);
    final path = Path()
      ..moveTo(top.dx, top.dy + 10)
      ..lineTo(top.dx - 5, top.dy)
      ..lineTo(top.dx + 5, top.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = aligned ? scheme.primary : scheme.onSurface);
  }

  @override
  bool shouldRepaint(covariant _WatchDialPainter old) => old.heading != heading || old.qibla != qibla || old.aligned != aligned;
}

// ---- tasbih ---------------------------------------------------------------

class WatchTasbihPage extends ConsumerStatefulWidget {
  const WatchTasbihPage({super.key});

  @override
  ConsumerState<WatchTasbihPage> createState() => _WatchTasbihPageState();
}

class _WatchTasbihPageState extends ConsumerState<WatchTasbihPage> {
  static const _key = 'watchTasbih';
  static const _adhkar = ['سُبْحَانَ ٱللَّٰهِ', 'ٱلْحَمْدُ لِلَّٰهِ', 'ٱللَّٰهُ أَكْبَرُ'];
  late int _count = (Storage.settings.get(_key) as int?) ?? 0;

  void _tap() {
    setState(() => _count++);
    Storage.settings.put(_key, _count);
    if (_count % 33 == 0) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void _reset() {
    setState(() => _count = 0);
    Storage.settings.put(_key, 0);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final phase = (_count ~/ 33) % _adhkar.length;
    final inPhase = _count % 33;
    final insets = watchInsets(context, ref);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _tap,
      onLongPress: _reset,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: CircularProgressIndicator(
              value: inPhase == 0 && _count > 0 ? 1 : inPhase / 33,
              strokeWidth: 3,
              color: AppColors.gold,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: insets,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l.tasbih, style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant, letterSpacing: 1)),
                Text(
                  _adhkar[phase],
                  textDirection: TextDirection.rtl,
                  style: ArabicStyles.surahName(context, size: 16, color: scheme.primary).copyWith(height: 1.3),
                ),
                Text('$_count', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, height: 1.1)),
                Text('$inPhase / 33', style: TextStyle(fontSize: 10, color: AppColors.gold)),
                const SizedBox(height: 4),
                Text(l.tapToCount, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: scheme.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- verse of the day -----------------------------------------------------

class WatchVersePage extends ConsumerWidget {
  const WatchVersePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.quran;
    final ayah = repo.ayah(ref.watch(verseOfTheDayProvider));
    final surah = repo.surah(ayah.surah);
    final settings = ref.watch(settingsProvider);
    final translation = ref.watch(surahTranslationProvider(
      (surah: ayah.surah, edition: settings.translations.firstOrNull ?? TranslationService.defaultEdition),
    ));
    final insets = watchInsets(context, ref);
    return ListView(
      padding: insets.copyWith(bottom: insets.bottom + 8),
      children: [
        Text(l.verseOfTheDay, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: scheme.secondary)),
        Text('${surah.englishName} ${ayah.key}', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(
          ayah.text,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: ArabicStyles.ayah(context, scale: 0.6, font: settings.arabicFont).copyWith(height: 1.9),
        ),
        const SizedBox(height: 4),
        translation.when(
          data: (list) => Text(
            list[ayah.numberInSurah - 1],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, height: 1.4, color: scheme.onSurfaceVariant),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
