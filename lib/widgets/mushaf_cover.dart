import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../features/mushaf/medina_ornaments.dart';
import 'surah_number_badge.dart';

/// A closed Mushaf cover: deep leather with gold tooling, a central
/// medallion and the title in Arabic calligraphy.
class MushafCover extends StatelessWidget {
  const MushafCover({super.key, this.title = 'ٱلْقُرْآنُ ٱلْكَرِيمُ', this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    const gold = AppColors.goldLight;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8), right: Radius.circular(3)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E6A44), Color(0xFF0F3F2A)],
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 18, offset: const Offset(-4, 8))],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: IslamicPatternPainter(color: gold.withValues(alpha: 0.10), cell: 28)),
          CustomPaint(painter: CoverToolingPainter(gold: gold.withValues(alpha: 0.85))),
          Padding(
            padding: const EdgeInsets.all(34),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: gold.withValues(alpha: 0.9), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: gold.withValues(alpha: 0.55), width: 1)),
                padding: const EdgeInsets.all(6),
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: gold.withValues(alpha: 0.35), width: 0.6)),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final s = c.maxWidth;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('۞', style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: s * 0.09, color: gold.withValues(alpha: 0.9))),
                          SizedBox(height: s * 0.05),
                          SizedBox(
                            width: s * 0.62,
                            height: s * 0.62,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(size: Size.square(s * 0.62), painter: _MedallionPainter(gold)),
                                SurahNumberBadge(number: 0, size: s * 0.5, color: gold, textColor: Colors.transparent),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: ArabicStyles.nameFont,
                                    fontSize: s * 0.085,
                                    fontWeight: FontWeight.w700,
                                    color: gold,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: s * 0.05),
                          if (subtitle != null)
                            Text(subtitle!, textAlign: TextAlign.center, style: TextStyle(fontSize: s * 0.045, color: gold.withValues(alpha: 0.85), letterSpacing: 1)),
                          SizedBox(height: s * 0.03),
                          Text('۞', style: TextStyle(fontFamily: ArabicStyles.nameFont, fontSize: s * 0.09, color: gold.withValues(alpha: 0.9))),
                        ],
                      );
                    },
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

class _MedallionPainter extends CustomPainter {
  _MedallionPainter(this.gold);
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final ring = Paint()
      ..color = gold.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(c, r, ring);
    canvas.drawCircle(c, r * 0.93, ring..strokeWidth = 0.7);
    canvas.drawPath(starPath(c, r * 0.86), Paint()..color = gold.withValues(alpha: 0.08));
    canvas.drawPath(starPath(c, r * 0.86), ring..strokeWidth = 1);
    canvas.drawCircle(c, r * 0.58, ring..strokeWidth = 0.8);
  }

  @override
  bool shouldRepaint(covariant _MedallionPainter oldDelegate) => oldDelegate.gold != gold;
}
