// Renders the Mushaf+ app icon artwork with Flutter itself, so the colours
// come straight from AppColors and the result is identical on every machine.
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
// The icon is an open mushaf resting on a rehal (the X-shaped book stand), in
// gold and ivory on tooled emerald leather, inside a gold double frame with
// corner pieces; a gold "+" sits in the open corner above the pages. Outputs,
// all under assets/icon/:
//
//   icon.png            1024²  full cover (iOS, web, macOS, Windows)
//   icon_background.png 1024²  leather only (Android adaptive background)
//   icon_foreground.png 1024²  rehal only, sized for the adaptive safe zone
//   icon_monochrome.png 1024²  white silhouette for Android 13 themed icons
//   maskable_192.png / maskable_512.png  leather + rehal for PWA maskable
//   favicon_64.png      simplified rounded tile for the browser tab
//   splash.png          1152²  rehal on transparent for the splash screens
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_plus/core/theme.dart';

enum _Variant { cover, background, foreground, monochrome, maskable, favicon, splash }

class _IconPainter extends CustomPainter {
  const _IconPainter(this.variant);
  final _Variant variant;

  static const _ivory = Color(0xFFF7EFDB);
  static const _ivoryShade = Color(0xFFE2D4B0);
  static const _goldDeep = Color(0xFFA8841C);

  /// The rehal composition is drawn in a 1024-unit space; this is the centre
  /// of its bounding box (top of the "+" to the feet of the stand).
  static const _markCenter = Offset(512, 533);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final u = s / 1024;
    final c = Offset(s / 2, s / 2);
    switch (variant) {
      case _Variant.cover:
        _leather(canvas, s, u, radius: 0);
        _frame(canvas, s, u);
        _rehal(canvas, c, 0.86 * u);
      case _Variant.background:
        _leather(canvas, s, u, radius: 0);
      case _Variant.foreground:
        _rehal(canvas, c, 0.68 * u);
      case _Variant.monochrome:
        _rehal(canvas, c, 0.68 * u, mono: true);
      case _Variant.maskable:
        _leather(canvas, s, u, radius: 0);
        _rehal(canvas, c, 0.80 * u);
      case _Variant.favicon:
        _leather(canvas, s, u, radius: 200 * u);
        _rehal(canvas, c, 1.08 * u, shadow: false);
      case _Variant.splash:
        _rehal(canvas, c, 0.62 * u);
    }
  }

  Paint _gold(Rect r, {bool vertical = true}) => Paint()
    ..shader = LinearGradient(
      begin: vertical ? Alignment.topCenter : Alignment.topLeft,
      end: vertical ? Alignment.bottomCenter : Alignment.bottomRight,
      colors: const [AppColors.goldLight, AppColors.gold, _goldDeep],
      stops: const [0, 0.55, 1],
    ).createShader(r);

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
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.55, -0.6),
          radius: 0.9,
          colors: [Colors.white.withValues(alpha: 0.14), Colors.transparent],
        ).createShader(rect),
    );
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
    canvas.drawRRect(
      outer,
      _gold(outer.outerRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9 * u,
    );
    canvas.drawRRect(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * u
        ..color = AppColors.goldLight.withValues(alpha: 0.6),
    );

    final goldFill = _gold(Offset.zero & Size(s, s), vertical: false);
    final ivoryLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * u
      ..color = _ivory.withValues(alpha: 0.75);
    const r = 100.0;
    for (final sx in [1.0, -1.0]) {
      for (final sy in [1.0, -1.0]) {
        canvas.save();
        canvas.translate(sx > 0 ? 106 * u : s - 106 * u, sy > 0 ? 106 * u : s - 106 * u);
        canvas.scale(sx * u, sy * u);
        canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(r, 0)
            ..arcToPoint(const Offset(0, r), radius: const Radius.circular(r), clockwise: true)
            ..close(),
          goldFill,
        );
        const d = 0.7071;
        final t = Offset(r * d, r * d);
        canvas.drawPath(
          Path()
            ..moveTo(t.dx + 36 * d, t.dy + 36 * d)
            ..lineTo(t.dx + 12 * d, t.dy - 12 * d)
            ..lineTo(t.dx - 26 * d, t.dy - 26 * d)
            ..lineTo(t.dx - 12 * d, t.dy + 12 * d)
            ..close(),
          goldFill,
        );
        canvas.drawPath(
          Path()
            ..moveTo(r * 0.72, 0)
            ..arcToPoint(Offset(0, r * 0.72), radius: Radius.circular(r * 0.72), clockwise: true),
          ivoryLine,
        );
        canvas.drawCircle(const Offset(34, 34), 10, Paint()..color = AppColors.emeraldDark);
        canvas.drawCircle(const Offset(34, 34), 4, Paint()..color = _ivory);
        canvas.restore();
      }
    }
  }

  // ── Mushaf on a rehal ───────────────────────────────────────────────────
  /// Draws the stand, the open mushaf and the "+" so that the composition's
  /// centre lands on [center], scaled by [k] (1024-unit space → px).
  void _rehal(Canvas canvas, Offset center, double k, {bool mono = false, bool shadow = true}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(k, k);
    canvas.translate(-_markCenter.dx, -_markCenter.dy);

    final white = Paint()..color = Colors.white;

    // Slats of the X-shaped stand (crossing at 512,650).
    final slats = Path()
      ..moveTo(182, 837)
      ..lineTo(842, 463)
      ..moveTo(842, 837)
      ..lineTo(182, 463);
    if (mono) {
      canvas.drawPath(
        slats,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 56
          ..strokeCap = StrokeCap.round,
      );
    } else {
      if (shadow) {
        canvas.drawPath(
          slats,
          Paint()
            ..color = Colors.black.withValues(alpha: 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 52
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
        );
      }
      canvas.drawPath(
        slats,
        Paint()
          ..color = _goldDeep
          ..style = PaintingStyle.stroke
          ..strokeWidth = 52
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        slats,
        _gold(const Rect.fromLTWH(182, 463, 660, 374))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 38
          ..strokeCap = StrokeCap.round,
      );
    }

    // Open mushaf resting in the V.
    for (final right in [false, true]) {
      final m = right ? 1.0 : -1.0;
      Offset p(double x, double y) => Offset(512 + m * x, y);
      Path pageShape(double lift) => Path()
        ..moveTo(p(0, 620 - lift).dx, 620 - lift)
        ..lineTo(p(0, 490).dx, 490)
        ..quadraticBezierTo(p(150, 430).dx, 430, p(300, 320).dx, 320)
        ..lineTo(p(300, 450 - lift).dx, 450 - lift)
        ..quadraticBezierTo(p(150, 560 - lift).dx, 560 - lift, p(0, 620 - lift).dx, 620 - lift)
        ..close();
      final block = pageShape(0);
      if (mono) {
        canvas.drawPath(block, white);
        continue;
      }
      if (shadow) canvas.drawShadow(block, Colors.black.withValues(alpha: 0.5), 16, false);
      canvas.drawPath(block, Paint()..color = _ivoryShade);
      canvas.drawPath(pageShape(20), Paint()..color = _ivory);

      // Illuminated frame and text lines, following the page tilt.
      Offset lerp(Offset a, Offset b, double t) => Offset.lerp(a, b, t)!;
      final innerTop = p(30, 512), innerBot = p(30, 582);
      final outerTop = p(268, 356), outerBot = p(268, 420);
      canvas.drawPath(
        Path()
          ..moveTo(innerTop.dx, innerTop.dy)
          ..lineTo(outerTop.dx, outerTop.dy)
          ..lineTo(outerBot.dx, outerBot.dy)
          ..lineTo(innerBot.dx, innerBot.dy)
          ..close(),
        Paint()
          ..color = AppColors.gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
      final ink = Paint()
        ..color = AppColors.emeraldDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      for (final t in [0.3, 0.55, 0.8]) {
        final a = lerp(innerTop, innerBot, t), b = lerp(outerTop, outerBot, t);
        canvas.drawLine(lerp(a, b, 0.14), lerp(a, b, t == 0.8 ? 0.6 : 0.86), ink);
      }
    }
    if (!mono) {
      canvas.drawLine(
        const Offset(512, 490),
        const Offset(512, 620),
        Paint()
          ..color = AppColors.emeraldDark.withValues(alpha: 0.5)
          ..strokeWidth = 6,
      );
    }

    // The "+" of Mushaf+, large, in the open corner above the right-hand page.
    const pc = Offset(700, 278);
    const arm = 72.0, stroke = 34.0;
    final plus = Path()
      ..moveTo(pc.dx - arm, pc.dy)
      ..lineTo(pc.dx + arm, pc.dy)
      ..moveTo(pc.dx, pc.dy - arm)
      ..lineTo(pc.dx, pc.dy + arm);
    if (!mono && shadow) {
      canvas.drawPath(
        plus,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }
    canvas.drawPath(
      plus,
      mono
          ? (Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..strokeCap = StrokeCap.round)
          : (_gold(Rect.fromCircle(center: pc, radius: arm + stroke))
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..strokeCap = StrokeCap.round),
    );
    canvas.restore();
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
