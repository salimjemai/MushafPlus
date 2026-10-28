import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/compass.dart' as compass;
import '../../data/prayer_times.dart';
import '../../state/masjid_providers.dart';
import '../../widgets/surah_number_badge.dart';

/// Live Qibla compass: the dial rotates with the device heading and the Kaaba
/// marker sits at the Qibla bearing. Falls back to a static bearing where no
/// compass is available (desktop).
class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  StreamSubscription<double?>? _sub;
  double? _heading;
  double? _lat;
  double? _lng;
  String? _placeName;
  bool _locating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final m = ref.read(activePlaceProvider);
    if (m != null) {
      _lat = m.latitude;
      _lng = m.longitude;
      _placeName = m.name;
    }
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
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('location permission denied');
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 30));
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _placeName = null;
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  static double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * r * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final hasLocation = _lat != null && _lng != null;
    final qibla = hasLocation ? qiblaDirection(_lat!, _lng!) : null;
    final distance = hasLocation ? _distanceKm(_lat!, _lng!, 21.4225, 39.8262) : null;
    final heading = _heading;
    final relative = qibla == null ? null : ((qibla - (heading ?? 0)) % 360 + 360) % 360;
    final aligned = relative != null && heading != null && (relative < 4 || relative > 356);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/prayer'),
        ),
        title: Text(l.qibla),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!hasLocation)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(l.qiblaNeedsLocation, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5)),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _locating ? null : _useDevice,
                          icon: _locating
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location),
                          label: Text(l.useMyLocation),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                AspectRatio(
                  aspectRatio: 1,
                  child: _CompassDial(heading: heading, qibla: qibla!, aligned: aligned),
                ),
                const SizedBox(height: 12),
                Card(
                  color: aligned ? scheme.primary.withValues(alpha: 0.12) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${qibla.round()}°',
                          style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: scheme.primary, height: 1),
                        ),
                        Text(l.qiblaBearing, style: TextStyle(color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 16,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            _Fact(icon: Icons.place_outlined, text: _placeName ?? '${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}'),
                            _Fact(icon: Icons.straighten, text: l.distanceToMakkah((distance!).round())),
                            if (heading != null) _Fact(icon: Icons.explore_outlined, text: l.headingDegrees(heading.round())),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          aligned
                              ? l.facingQibla
                              : heading == null
                                  ? (compass.compassSupported ? l.compassWaiting : l.compassUnavailable)
                                  : l.turnToQibla(relative! <= 180 ? l.right : l.left, (relative <= 180 ? relative : 360 - relative).round()),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600, color: aligned ? scheme.primary : scheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _locating ? null : _useDevice,
                  icon: const Icon(Icons.my_location),
                  label: Text(l.useMyLocation),
                ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(l.couldNotGetLocation(_error!), style: TextStyle(color: scheme.error)),
                ),
              const SizedBox(height: 8),
              Text(l.qiblaHelp, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: scheme.outline, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

class _CompassDial extends StatelessWidget {
  const _CompassDial({required this.heading, required this.qibla, required this.aligned});
  final double? heading;
  final double qibla;
  final bool aligned;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rotation = -(heading ?? 0) * math.pi / 180;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dial rotates against the heading so north stays north.
        AnimatedRotation(
          turns: rotation / (2 * math.pi),
          duration: const Duration(milliseconds: 250),
          child: CustomPaint(
            size: Size.infinite,
            painter: _DialPainter(scheme: scheme, qibla: qibla),
          ),
        ),
        // Fixed needle (device forward direction).
        Positioned(
          top: 6,
          child: Icon(Icons.arrow_drop_down, size: 40, color: aligned ? scheme.primary : scheme.onSurfaceVariant),
        ),
        SurahNumberBadge(number: 0, size: 54, color: aligned ? scheme.primary : AppColors.gold, textColor: Colors.transparent),
        Text('🕋', style: TextStyle(fontSize: 26, shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6)])),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.scheme, required this.qibla});
  final ColorScheme scheme;
  final double qibla;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 8;
    canvas.drawCircle(c, r, Paint()..color = scheme.surfaceContainerHighest.withValues(alpha: 0.5));
    canvas.drawCircle(c, r, Paint()..color = scheme.outlineVariant..style = PaintingStyle.stroke..strokeWidth = 2);
    final tick = Paint()..color = scheme.onSurfaceVariant..strokeWidth = 1.5;
    for (var d = 0; d < 360; d += 5) {
      final a = (d - 90) * math.pi / 180;
      final major = d % 30 == 0;
      final len = major ? 14.0 : (d % 10 == 0 ? 9.0 : 5.0);
      canvas.drawLine(c + Offset(math.cos(a) * (r - len), math.sin(a) * (r - len)), c + Offset(math.cos(a) * r, math.sin(a) * r), tick);
    }
    void label(String s, int deg, {Color? color, double size = 18}) {
      final a = (deg - 90) * math.pi / 180;
      final tp = TextPainter(
        text: TextSpan(text: s, style: TextStyle(fontSize: size, fontWeight: FontWeight.w800, color: color ?? scheme.onSurface)),
        textDirection: TextDirection.ltr,
      )..layout();
      final p = c + Offset(math.cos(a) * (r - 30), math.sin(a) * (r - 30));
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
    label('N', 0, color: scheme.error);
    label('E', 90);
    label('S', 180);
    label('W', 270);
    // Qibla ray and Kaaba marker on the rim.
    final qa = (qibla - 90) * math.pi / 180;
    final rim = c + Offset(math.cos(qa) * (r - 2), math.sin(qa) * (r - 2));
    canvas.drawLine(c, rim, Paint()..color = AppColors.gold..strokeWidth = 3..strokeCap = StrokeCap.round);
    canvas.drawCircle(rim, 12, Paint()..color = AppColors.gold);
    final tp = TextPainter(
      text: const TextSpan(text: '🕋', style: TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, rim - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) => old.qibla != qibla || old.scheme != scheme;
}
