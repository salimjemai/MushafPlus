// Renders the Mushaf+ app icon artwork with Flutter itself, so the ق uses the
// real Amiri font and the colours come straight from AppColors.
//
//   flutter test tool/render_icon.dart
//   dart run flutter_launcher_icons
//   cp assets/icon/maskable_192.png web/icons/Icon-maskable-192.png
//   cp assets/icon/maskable_512.png web/icons/Icon-maskable-512.png
//   cp assets/icon/favicon_64.png web/favicon.png
//   dart run flutter_native_splash:create
//
// (flutter_launcher_icons derives the web maskable icons and favicon from the
// full cover, which would clip the frame under a circular mask and turn to mush
// at 16 px, so the three copies above replace them with purpose-made renders.)
//
// The icon is a mushaf cover: deep emerald tooled leather, a gold double frame
// with corner pieces, and a central gold mandorla (almond medallion) with four
// pendants holding the ق on ivory. Outputs, all under assets/icon/:
//
//   icon.png            1024²  full cover (iOS, web, macOS, Windows)
//   icon_background.png 1024²  leather only (Android adaptive background)
//   icon_foreground.png 1024²  medallion only, sized for the adaptive safe zone
//   icon_monochrome.png 1024²  white silhouette for Android 13 themed icons
//   maskable_192.png / maskable_512.png  leather + medallion for PWA maskable
//   favicon_64.png      simplified rounded tile for the browser tab
//   splash.png          1152²  medallion on transparent for the splash screens
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_plus/core/theme.dart';

Future<void> _loadFonts() async {
  final amiri = FontLoader('Amiri')
    ..addFont(rootBundle.load('assets/fonts/Amiri-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Amiri-Bold.ttf'));
  await amiri.load();
}

enum _Variant { cover, background, foreground, monochrome, maskable, favicon, splash }

class _IconPainter extends CustomPainter {
  const _IconPainter(this.variant);
  final _Variant variant;

  static const _ivory = Color(0xFFF7EFDB);
  static const _goldDeep = Color(0xFFA8841C);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final u = s / 1024;
    final c = Offset(s / 2, s / 2);
    switch (variant) {
      case _Variant.cover:
        _leather(canvas, s, u, radius: 0);
        _frame(canvas, s, u);
        _medallion(canvas, c, u * 0.92);
      case _Variant.background:
        _leather(canvas, s, u, radius: 0);
      case _Variant.foreground:
        _medallion(canvas, c, u * 0.78);
      case _Variant.monochrome:
        _monochrome(canvas, c, u * 0.78);
      case _Variant.maskable:
        _leather(canvas, s, u, radius: 0);
        _medallion(canvas, c, u * 0.86);
      case _Variant.favicon:
        _leather(canvas, s, u, radius: 200 * u);
        _medallion(canvas, c, u * 1.2, shadow: false);
      case _Variant.splash:
        _medallion(canvas, c, u * 0.58);
    }
  }

  // ── Tooled leather ──────────────────────────────────────────────────────
  void _leather(Canvas canvas, double s, double u, {required double radius}) {
    final rect = Offset.zero & Size(s, s);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF13806A), AppColors.emerald, AppColors.emeraldDark],
          stops: [0, 0.45, 1],
        ).createShader(rect),
    );
    // Soft sheen top-left.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.55, -0.6),
          radius: 0.9,
          colors: [Colors.white.withValues(alpha: 0.14), Colors.transparent],
        ).createShader(rect),
    );
    // Blind-tooled diamond lattice.
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * u;
    final cell = s / 9;
    for (var k = -s; k <= 2 * s; k += cell) {
      canvas.drawLine(Offset(k, 0), Offset(k + s, s), line);
      canvas.drawLine(Offset(k, s), Offset(k + s, 0), line);
    }
    final dot = Paint()..color = AppColors.goldLight.withValues(alpha: 0.16);
    for (var y = cell / 2; y < s; y += cell) {
      for (var x = cell / 2; x < s; x += cell) {
        canvas.drawCircle(Offset(x, y), 3.2 * u, dot);
      }
    }
    // Vignette so the edges sit darker than the centre.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.95,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.28)],
          stops: const [0.55, 1],
        ).createShader(rect),
    );
    canvas.restore();
  }

  // ── Gold double frame with corner pieces ────────────────────────────────
  void _frame(Canvas canvas, double s, double u) {
    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(80 * u, 80 * u, s - 160 * u, s - 160 * u),
      Radius.circular(64 * u),
    );
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(106 * u, 106 * u, s - 212 * u, s - 212 * u),
      Radius.circular(44 * u),
    );
    final goldStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9 * u
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.goldLight, AppColors.gold, _goldDeep],
      ).createShader(outer.outerRect);
    canvas.drawRRect(outer, goldStroke);
    canvas.drawRRect(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * u
        ..color = AppColors.goldLight.withValues(alpha: 0.6),
    );

    // Corner pieces: quarter-discs hugging the inside corners of the inner
    // frame, each with a pointed tip towards the centre, an ivory inner arc and
    // an emerald stud.
    final goldFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.goldLight, AppColors.gold],
      ).createShader(Offset.zero & Size(s, s));
    final ivoryLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * u
      ..color = _ivory.withValues(alpha: 0.75);
    const r = 128.0;
    for (final sx in [1.0, -1.0]) {
      for (final sy in [1.0, -1.0]) {
        canvas.save();
        canvas.translate(sx > 0 ? 106 * u : s - 106 * u, sy > 0 ? 106 * u : s - 106 * u);
        canvas.scale(sx * u, sy * u);
        final disc = Path()
          ..moveTo(0, 0)
          ..lineTo(r, 0)
          ..arcToPoint(const Offset(0, r), radius: const Radius.circular(r), clockwise: true)
          ..close();
        canvas.drawPath(disc, goldFill);
        // Pointed tip on the diagonal.
        const d = 0.7071;
        final tipC = Offset(r * d, r * d);
        final tip = Path()
          ..moveTo(tipC.dx + 44 * d, tipC.dy + 44 * d)
          ..lineTo(tipC.dx + 14 * d, tipC.dy - 14 * d)
          ..lineTo(tipC.dx - 30 * d, tipC.dy - 30 * d)
          ..lineTo(tipC.dx - 14 * d, tipC.dy + 14 * d)
          ..close();
        canvas.drawPath(tip, goldFill);
        canvas.drawPath(
          Path()
            ..moveTo(r * 0.72, 0)
            ..arcToPoint(Offset(0, r * 0.72), radius: Radius.circular(r * 0.72), clockwise: true),
          ivoryLine,
        );
        canvas.drawCircle(const Offset(40, 40), 12, Paint()..color = AppColors.emeraldDark);
        canvas.drawCircle(const Offset(40, 40), 5, Paint()..color = _ivory);
        canvas.restore();
      }
    }
  }

  // ── Central mandorla medallion ──────────────────────────────────────────
  /// Vesica piscis with half-height [h] and half-width [w], centred on [c].
  Path _mandorla(Offset c, double h, double w) {
    final r = (h * h + w * w) / (2 * w);
    return Path()
      ..moveTo(c.dx, c.dy - h)
      ..arcToPoint(Offset(c.dx, c.dy + h), radius: Radius.circular(r), clockwise: true)
      ..arcToPoint(Offset(c.dx, c.dy - h), radius: Radius.circular(r), clockwise: true)
      ..close();
  }

  Path _lozenge(Offset c, double hw, double hh) => Path()
    ..moveTo(c.dx, c.dy - hh)
    ..lineTo(c.dx + hw, c.dy)
    ..lineTo(c.dx, c.dy + hh)
    ..lineTo(c.dx - hw, c.dy)
    ..close();

  void _medallion(Canvas canvas, Offset c, double u, {bool shadow = true}) {
    const h = 300.0, w = 215.0;
    final body = _mandorla(c, h * u, w * u);

    // Pendants: a lozenge above and below on a short stem, and two at the sides,
    // so the medallion carries a quiet four-fold "plus" geometry.
    final pendants = Path()
      ..addPath(_lozenge(Offset(c.dx, c.dy - (h + 56) * u), 20 * u, 36 * u), Offset.zero)
      ..addPath(_lozenge(Offset(c.dx, c.dy + (h + 56) * u), 20 * u, 36 * u), Offset.zero)
      ..addPath(_lozenge(Offset(c.dx - (w + 46) * u, c.dy), 34 * u, 18 * u), Offset.zero)
      ..addPath(_lozenge(Offset(c.dx + (w + 46) * u, c.dy), 34 * u, 18 * u), Offset.zero);
    final stems = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * u;
    final whole = Path()
      ..addPath(body, Offset.zero)
      ..addPath(pendants, Offset.zero);

    if (shadow) {
      canvas.drawShadow(whole, Colors.black.withValues(alpha: 0.55), 18 * u, false);
    }

    final bounds = whole.getBounds();
    final goldFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.goldLight, AppColors.gold, _goldDeep],
        stops: [0, 0.55, 1],
      ).createShader(bounds);

    canvas.drawLine(Offset(c.dx, c.dy - h * u), Offset(c.dx, c.dy - (h + 30) * u), stems);
    canvas.drawLine(Offset(c.dx, c.dy + h * u), Offset(c.dx, c.dy + (h + 30) * u), stems);
    canvas.drawLine(Offset(c.dx - w * u, c.dy), Offset(c.dx - (w + 20) * u, c.dy), stems);
    canvas.drawLine(Offset(c.dx + w * u, c.dy), Offset(c.dx + (w + 20) * u, c.dy), stems);
    canvas.drawPath(pendants, goldFill);
    canvas.drawPath(
      pendants,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * u
        ..color = _goldDeep.withValues(alpha: 0.7),
    );

    // Halo line just outside the body.
    canvas.drawPath(
      _mandorla(c, (h + 16) * u, (w + 14) * u),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * u
        ..color = AppColors.goldLight.withValues(alpha: 0.55),
    );

    canvas.drawPath(body, goldFill);
    // Ivory field.
    canvas.drawPath(_mandorla(c, (h - 42) * u, (w - 38) * u), Paint()..color = _ivory);
    canvas.drawPath(
      _mandorla(c, (h - 56) * u, (w - 50) * u),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * u
        ..color = AppColors.gold,
    );
    // Small gold rosettes at the top and bottom of the ivory field.
    for (final dy in [-(h - 84) * u, (h - 84) * u]) {
      final p = Offset(c.dx, c.dy + dy);
      canvas.drawCircle(p, 9 * u, Paint()..color = AppColors.gold);
      canvas.drawCircle(p, 4 * u, Paint()..color = _ivory);
    }

    // The ق.
    final tp = TextPainter(
      text: TextSpan(
        text: 'ق',
        style: TextStyle(
          fontFamily: 'Amiri',
          fontWeight: FontWeight.w700,
          fontSize: 360 * u,
          color: AppColors.emeraldDark,
          height: 1,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2 - 2 * u));
  }

  /// Android 13 themed icon: a single-colour silhouette (the launcher tints
  /// it), so the ivory field becomes transparent and the ق stays solid.
  void _monochrome(Canvas canvas, Offset c, double u) {
    const h = 300.0, w = 215.0;
    final white = Paint()..color = Colors.white;
    final ring = Path.combine(
      PathOperation.difference,
      _mandorla(c, h * u, w * u),
      _mandorla(c, (h - 42) * u, (w - 38) * u),
    );
    canvas.drawPath(ring, white);
    final stems = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * u;
    canvas.drawLine(Offset(c.dx, c.dy - h * u), Offset(c.dx, c.dy - (h + 30) * u), stems);
    canvas.drawLine(Offset(c.dx, c.dy + h * u), Offset(c.dx, c.dy + (h + 30) * u), stems);
    canvas.drawLine(Offset(c.dx - w * u, c.dy), Offset(c.dx - (w + 20) * u, c.dy), stems);
    canvas.drawLine(Offset(c.dx + w * u, c.dy), Offset(c.dx + (w + 20) * u, c.dy), stems);
    canvas.drawPath(_lozenge(Offset(c.dx, c.dy - (h + 56) * u), 20 * u, 36 * u), white);
    canvas.drawPath(_lozenge(Offset(c.dx, c.dy + (h + 56) * u), 20 * u, 36 * u), white);
    canvas.drawPath(_lozenge(Offset(c.dx - (w + 46) * u, c.dy), 34 * u, 18 * u), white);
    canvas.drawPath(_lozenge(Offset(c.dx + (w + 46) * u, c.dy), 34 * u, 18 * u), white);
    final tp = TextPainter(
      text: TextSpan(
        text: 'ق',
        style: TextStyle(
          fontFamily: 'Amiri',
          fontWeight: FontWeight.w700,
          fontSize: 360 * u,
          color: Colors.white,
          height: 1,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2 - 2 * u));
  }

  @override
  bool shouldRepaint(covariant _IconPainter old) => old.variant != variant;
}

Future<void> _render(WidgetTester tester, _Variant variant, double size, String path) async {
  final key = GlobalKey();
  await tester.binding.setSurfaceSize(Size(size, size));
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        type: MaterialType.transparency,
        child: Center(
          child: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(painter: _IconPainter(variant)),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(path)..createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('render icon assets', (tester) async {
    await tester.runAsync(_loadFonts);
    await _render(tester, _Variant.cover, 1024, 'assets/icon/icon.png');
    await _render(tester, _Variant.background, 1024, 'assets/icon/icon_background.png');
    await _render(tester, _Variant.foreground, 1024, 'assets/icon/icon_foreground.png');
    await _render(tester, _Variant.monochrome, 1024, 'assets/icon/icon_monochrome.png');
    await _render(tester, _Variant.maskable, 512, 'assets/icon/maskable_512.png');
    await _render(tester, _Variant.maskable, 192, 'assets/icon/maskable_192.png');
    await _render(tester, _Variant.favicon, 64, 'assets/icon/favicon_64.png');
    await _render(tester, _Variant.favicon, 256, 'assets/icon/favicon_256.png');
    await _render(tester, _Variant.splash, 1152, 'assets/icon/splash.png');
    expect(File('assets/icon/icon.png').lengthSync(), greaterThan(10000));
  });
}
