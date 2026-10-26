// Renders the app icon, adaptive foreground and splash image with Flutter
// itself, so the artwork uses the real Amiri font and the app's star badge.
//
//   flutter test tool/render_icon.dart
//
// Writes assets/icon/icon.png (1024²), icon_foreground.png (1024², padded for
// Android adaptive icons) and splash.png (1152², transparent).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_plus/core/theme.dart';
import 'package:mushaf_plus/widgets/surah_number_badge.dart';

Future<void> _loadFonts() async {
  final amiri = FontLoader('Amiri')
    ..addFont(rootBundle.load('assets/fonts/Amiri-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Amiri-Bold.ttf'));
  await amiri.load();
}

class _Art extends StatelessWidget {
  const _Art({required this.size, required this.background, required this.scale});
  final double size;
  final bool background;
  final double scale; // fraction of the canvas the star occupies

  @override
  Widget build(BuildContext context) {
    final star = size * scale;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (background)
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.emerald, AppColors.emeraldDark],
                ),
              ),
              child: CustomPaint(
                painter: IslamicPatternPainter(color: Colors.white.withValues(alpha: 0.07), cell: size / 7),
              ),
            ),
          Center(
            child: SizedBox(
              width: star,
              height: star,
              child: CustomPaint(
                painter: _StarPainter(),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: star * 0.06),
                    child: Text(
                      'ق',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.w700,
                        fontSize: star * 0.5,
                        color: AppColors.emeraldDark,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = starPath(size.center(Offset.zero), size.width / 2);
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.5), size.width * 0.03, false);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.goldLight, AppColors.gold],
        ).createShader(Offset.zero & size),
    );
    final inner = starPath(size.center(Offset.zero), size.width / 2 * 0.86);
    canvas.drawPath(
      inner,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.012,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<void> _render(WidgetTester tester, Widget art, double size, String path) async {
  final key = GlobalKey();
  await tester.binding.setSurfaceSize(Size(size, size));
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        type: MaterialType.transparency,
        child: Center(child: RepaintBoundary(key: key, child: art)),
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
    await _render(tester, const _Art(size: 1024, background: true, scale: 0.62), 1024, 'assets/icon/icon.png');
    await _render(tester, const _Art(size: 1024, background: false, scale: 0.48), 1024, 'assets/icon/icon_foreground.png');
    await _render(tester, const _Art(size: 1152, background: false, scale: 0.42), 1152, 'assets/icon/splash.png');
    expect(File('assets/icon/icon.png').lengthSync(), greaterThan(10000));
  });
}
