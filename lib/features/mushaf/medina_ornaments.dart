import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The colours of the printed Madinah Mushaf: white paper, black ink, leaf
/// green ornament with rose flowers and a little gold. One palette is used by
/// the cover, the opening pages, the inner frames, the surah bands and the
/// ayah markers so the book reads as one object.
class MedinaPalette {
  const MedinaPalette({
    required this.paper,
    required this.ink,
    required this.green,
    required this.greenDark,
    required this.greenLight,
    required this.rose,
    required this.gold,
  });

  final Color paper;
  final Color ink;
  final Color green;
  final Color greenDark;
  final Color greenLight;
  final Color rose;
  final Color gold;

  static const light = MedinaPalette(
    paper: Color(0xFFFFFDF7),
    ink: Color(0xFF1C1C1C),
    green: Color(0xFF2F8A4C),
    greenDark: Color(0xFF1B5E3A),
    greenLight: Color(0xFFE4F0DE),
    rose: Color(0xFFD4789F),
    gold: Color(0xFFC9A227),
  );

  static const dark = MedinaPalette(
    paper: Color(0xFF181C19),
    ink: Color(0xFFE9E6DC),
    green: Color(0xFF5FB97C),
    greenDark: Color(0xFF8FD3A5),
    greenLight: Color(0xFF203428),
    rose: Color(0xFFE08FB4),
    gold: Color(0xFFD9BC5C),
  );

  static MedinaPalette of(bool isDark) => isDark ? dark : light;
}

/// Shared motif drawing: a leafy vine with rose flowers, rosettes, scallops.
class MedinaMotifs {
  MedinaMotifs._();

  /// A vine running from [a] to [b] inside a band [t] wide: an S-curve stem
  /// with a small leaf on each bend and a rose flower every other bend.
  static void vine(Canvas canvas, Offset a, Offset b, double t, MedinaPalette p, {double scale = 1}) {
    final len = (b - a).distance;
    if (len < t) return;
    final dir = (b - a) / len;
    final normal = Offset(-dir.dy, dir.dx);
    final step = t * 1.5 * scale;
    final n = math.max(1, (len / step).round());
    final seg = len / n;
    final amp = t * 0.28;
    final stem = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, t * 0.07)
      ..color = p.green;
    final leaf = Paint()..color = p.green;
    final rose = Paint()..color = p.rose;
    final heart = Paint()..color = p.gold;
    final path = Path()..moveTo(a.dx, a.dy);
    for (var i = 0; i < n; i++) {
      final s = a + dir * (seg * i);
      final e = a + dir * (seg * (i + 1));
      final side = i.isEven ? 1.0 : -1.0;
      final c = s + dir * (seg / 2) + normal * (amp * 1.8 * side);
      path.quadraticBezierTo(c.dx, c.dy, e.dx, e.dy);
      final mid = s + dir * (seg / 2) + normal * (amp * side);
      if (i % 2 == 0) {
        canvas.drawCircle(mid, t * 0.16, rose);
        canvas.drawCircle(mid, t * 0.06, heart);
      } else {
        _leaf(canvas, mid, t * 0.26, math.atan2(dir.dy, dir.dx) + side * 0.9, leaf);
      }
    }
    canvas.drawPath(path, stem);
  }

  static void _leaf(Canvas canvas, Offset c, double r, double angle, Paint paint) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 1.6, height: r * 0.8), paint);
    canvas.restore();
  }

  /// Eight-petal rosette: green petals, rose heart, gold centre.
  static void rosette(Canvas canvas, Offset c, double r, MedinaPalette p) {
    final petal = Paint()..color = p.green;
    for (var i = 0; i < 8; i++) {
      final a = math.pi / 4 * i;
      canvas.drawCircle(Offset(c.dx + r * 0.6 * math.cos(a), c.dy + r * 0.6 * math.sin(a)), r * 0.4, petal);
    }
    canvas.drawCircle(c, r * 0.46, Paint()..color = p.rose);
    canvas.drawCircle(c, r * 0.18, Paint()..color = p.gold);
  }

  /// Scalloped arches along a side, facing [inward] (the normal direction).
  static void scallops(Canvas canvas, Offset a, Offset b, Offset inward, double r, MedinaPalette p) {
    final len = (b - a).distance;
    final n = math.max(1, (len / (r * 2)).floor());
    final seg = len / n;
    final dir = (b - a) / len;
    final fill = Paint()..color = p.green.withValues(alpha: 0.18);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = p.green;
    final dot = Paint()..color = p.rose;
    for (var i = 0; i < n; i++) {
      final c = a + dir * (seg * (i + 0.5));
      final rect = Rect.fromCircle(center: c, radius: seg / 2);
      final start = math.atan2(inward.dy, inward.dx) - math.pi / 2;
      canvas.drawArc(rect, start, math.pi, true, fill);
      canvas.drawArc(rect, start, math.pi, false, line);
      canvas.drawCircle(c + inward * (seg * 0.22), seg * 0.1, dot);
    }
  }
}

/// Frame of a Mushaf page. Inner pages: a narrow band carrying the vine with
/// rose flowers between two green rules and rosettes in the corners, as
/// around every page of the Madinah Mushaf. Opening pages (1 and 2): the
/// illuminated border — a wide band of scalloped arches and vines with
/// finials pointing outward, corner rosettes, and a scalloped cartouche
/// around the small block of text.
class MedinaFramePainter extends CustomPainter {
  const MedinaFramePainter({required this.opening, required this.palette});
  final bool opening;
  final MedinaPalette palette;

  /// Band thickness for a page of [size].
  static double bandFor(Size size, bool opening) =>
      opening ? (size.shortestSide * 0.105).clamp(26.0, 44.0) : (size.shortestSide * 0.042).clamp(11.0, 16.0);

  /// Padding to keep the text clear of the ornament.
  static EdgeInsets insetFor(Size size, bool opening) {
    final t = bandFor(size, opening);
    return opening ? EdgeInsets.fromLTRB(t + 30, t + 26, t + 30, t + 26) : EdgeInsets.fromLTRB(t + 10, t + 8, t + 10, t + 8);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (opening) {
      _paintOpening(canvas, size);
    } else {
      _paintInner(canvas, size);
    }
  }

  void _paintInner(Canvas canvas, Size size) {
    final p = palette;
    final t = bandFor(size, false);
    final outer = Offset.zero & size;
    final inner = outer.deflate(t);
    final rule = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = p.greenDark;
    final hair = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = p.green;
    canvas.drawRect(outer.deflate(t * 0.5), Paint()..color = p.greenLight.withValues(alpha: palette == MedinaPalette.dark ? 0.6 : 0.55));
    canvas.drawRect(outer.deflate(0.6), rule);
    canvas.drawRect(inner, rule);
    canvas.drawRect(inner.deflate(2.5), hair);
    final m = t / 2;
    final cs = t * 0.95; // corner square
    MedinaMotifs.vine(canvas, Offset(cs, m), Offset(size.width - cs, m), t, p);
    MedinaMotifs.vine(canvas, Offset(cs, size.height - m), Offset(size.width - cs, size.height - m), t, p);
    MedinaMotifs.vine(canvas, Offset(m, cs), Offset(m, size.height - cs), t, p);
    MedinaMotifs.vine(canvas, Offset(size.width - m, cs), Offset(size.width - m, size.height - cs), t, p);
    for (final c in [Offset(m, m), Offset(size.width - m, m), Offset(m, size.height - m), Offset(size.width - m, size.height - m)]) {
      MedinaMotifs.rosette(canvas, c, t * 0.42, p);
    }
  }

  void _paintOpening(Canvas canvas, Size size) {
    final p = palette;
    final t = bandFor(size, true);
    const gutter = 7.0; // room for the finials outside the band
    final outer = (Offset.zero & size).deflate(gutter);
    final bandInner = outer.deflate(t);
    final rule = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = p.greenDark;
    final goldHair = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = p.gold;

    // Band.
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(outer)
        ..addRect(bandInner),
      Paint()..color = p.greenLight,
    );
    canvas.drawRect(outer, rule);
    canvas.drawRect(bandInner, rule);
    canvas.drawRect(outer.deflate(t * 0.46), goldHair);

    // Finials: small leaves pointing outward all around, as in the print.
    final fin = Paint()..color = p.green;
    void finials(Offset a, Offset b, Offset out) {
      final len = (b - a).distance;
      final n = math.max(1, (len / (t * 0.55)).floor());
      final seg = len / n;
      final dir = (b - a) / len;
      for (var i = 0; i < n; i++) {
        final c = a + dir * (seg * (i + 0.5));
        final tip = c + out * (gutter - 1);
        final path = Path()
          ..moveTo(c.dx + dir.dx * seg * 0.22, c.dy + dir.dy * seg * 0.22)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(c.dx - dir.dx * seg * 0.22, c.dy - dir.dy * seg * 0.22)
          ..close();
        canvas.drawPath(path, fin);
        if (i.isEven) canvas.drawCircle(tip, 1.1, Paint()..color = p.rose);
      }
    }

    finials(outer.topLeft, outer.topRight, const Offset(0, -1));
    finials(outer.bottomLeft, outer.bottomRight, const Offset(0, 1));
    finials(outer.topLeft, outer.bottomLeft, const Offset(-1, 0));
    finials(outer.topRight, outer.bottomRight, const Offset(1, 0));

    // Outer half of the band: vine; inner half: scalloped arches facing in.
    final vm = outer.deflate(t * 0.24);
    final cs = t;
    MedinaMotifs.vine(canvas, Offset(vm.left + cs, vm.top), Offset(vm.right - cs, vm.top), t * 0.5, p);
    MedinaMotifs.vine(canvas, Offset(vm.left + cs, vm.bottom), Offset(vm.right - cs, vm.bottom), t * 0.5, p);
    MedinaMotifs.vine(canvas, Offset(vm.left, vm.top + cs), Offset(vm.left, vm.bottom - cs), t * 0.5, p);
    MedinaMotifs.vine(canvas, Offset(vm.right, vm.top + cs), Offset(vm.right, vm.bottom - cs), t * 0.5, p);
    final sr = t * 0.22;
    final si = outer.deflate(t * 0.56);
    MedinaMotifs.scallops(canvas, Offset(si.left + cs, si.top), Offset(si.right - cs, si.top), const Offset(0, 1), sr, p);
    MedinaMotifs.scallops(canvas, Offset(si.left + cs, si.bottom), Offset(si.right - cs, si.bottom), const Offset(0, -1), sr, p);
    MedinaMotifs.scallops(canvas, Offset(si.left, si.top + cs), Offset(si.left, si.bottom - cs), const Offset(1, 0), sr, p);
    MedinaMotifs.scallops(canvas, Offset(si.right, si.top + cs), Offset(si.right, si.bottom - cs), const Offset(-1, 0), sr, p);

    // Corner squares with rosettes.
    for (final c in [outer.topLeft, outer.topRight, outer.bottomLeft, outer.bottomRight]) {
      final sx = c.dx == outer.left ? 0.0 : -t;
      final sy = c.dy == outer.top ? 0.0 : -t;
      final sq = Rect.fromLTWH(c.dx + sx, c.dy + sy, t, t);
      canvas.drawRect(sq, Paint()..color = p.green.withValues(alpha: 0.16));
      canvas.drawRect(sq, rule);
      MedinaMotifs.rosette(canvas, sq.center, t * 0.36, p);
    }

    // Cartouche around the text: a rounded frame with a scalloped edge and
    // rose dots, leaving the header line room above it.
    final text = bandInner.deflate(t * 0.55);
    final rr = RRect.fromRectAndRadius(text, Radius.circular(t * 1.2));
    canvas.drawRRect(rr, Paint()..color = p.paper);
    canvas.drawRRect(rr, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = p.green);
    canvas.drawRRect(rr.deflate(4), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = p.gold);
    final dots = Paint()..color = p.rose;
    final ring = Path()..addRRect(rr.inflate(3));
    for (final metric in ring.computeMetrics()) {
      final n = (metric.length / 11).floor();
      for (var i = 0; i < n; i++) {
        final tan = metric.getTangentForOffset(metric.length * i / n);
        if (tan != null) canvas.drawCircle(tan.position, 1.3, dots);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MedinaFramePainter old) => old.opening != opening || old.palette != palette;
}

/// Background of a surah band: light green with the vine and rose flowers.
class MedinaBandPainter extends CustomPainter {
  const MedinaBandPainter({required this.palette});
  final MedinaPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final p = palette;
    canvas.drawRect(Offset.zero & size, Paint()..color = p.greenLight);
    final rule = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = p.green;
    canvas.drawRect((Offset.zero & size).deflate(0.5), rule);
    final t = size.height * 0.5;
    MedinaMotifs.vine(canvas, Offset(size.height * 0.4, size.height / 2), Offset(size.width - size.height * 0.4, size.height / 2), t, p, scale: 1.2);
    MedinaMotifs.rosette(canvas, Offset(size.height * 0.5, size.height / 2), size.height * 0.26, p);
    MedinaMotifs.rosette(canvas, Offset(size.width - size.height * 0.5, size.height / 2), size.height * 0.26, p);
  }

  @override
  bool shouldRepaint(covariant MedinaBandPainter old) => old.palette != palette;
}

/// Gold tooling on the cover: a vine border and corner rosettes.
class CoverToolingPainter extends CustomPainter {
  const CoverToolingPainter({required this.gold});
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final p = MedinaPalette(
      paper: Colors.transparent,
      ink: gold,
      green: gold,
      greenDark: gold,
      greenLight: Colors.transparent,
      rose: gold.withValues(alpha: 0.7),
      gold: gold,
    );
    final t = (size.shortestSide * 0.05).clamp(12.0, 18.0);
    final m = t * 1.4;
    MedinaMotifs.vine(canvas, Offset(m * 2, m), Offset(size.width - m * 2, m), t * 0.8, p);
    MedinaMotifs.vine(canvas, Offset(m * 2, size.height - m), Offset(size.width - m * 2, size.height - m), t * 0.8, p);
    MedinaMotifs.vine(canvas, Offset(m, m * 2), Offset(m, size.height - m * 2), t * 0.8, p);
    MedinaMotifs.vine(canvas, Offset(size.width - m, m * 2), Offset(size.width - m, size.height - m * 2), t * 0.8, p);
    for (final c in [Offset(m, m), Offset(size.width - m, m), Offset(m, size.height - m), Offset(size.width - m, size.height - m)]) {
      MedinaMotifs.rosette(canvas, c, t * 0.45, p);
    }
  }

  @override
  bool shouldRepaint(covariant CoverToolingPainter old) => old.gold != gold;
}
