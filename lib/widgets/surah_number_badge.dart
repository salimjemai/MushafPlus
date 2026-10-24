import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The classic eight-pointed star (Rub el Hizb) with a number inside.
class SurahNumberBadge extends StatelessWidget {
  const SurahNumberBadge({
    super.key,
    required this.number,
    this.size = 44,
    this.color,
    this.textColor,
    this.filled = false,
  });

  final int number;
  final double size;
  final Color? color;
  final Color? textColor;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarPainter(color: c, filled: filled),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: size * 0.34,
              fontWeight: FontWeight.w700,
              color: textColor ?? (filled ? Colors.white : c),
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.color, required this.filled});
  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final path = starPath(size.center(Offset.zero), size.width / 2);
    if (filled) {
      canvas.drawPath(path, Paint()..color = color);
    } else {
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.10));
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) =>
      old.color != color || old.filled != filled;
}

/// Two overlapping squares rotated 45 degrees -> eight-pointed star outline.
Path starPath(Offset center, double radius) {
  final path = Path();
  const points = 16;
  final inner = radius * 0.82;
  for (var i = 0; i < points; i++) {
    final r = i.isEven ? radius : inner;
    final angle = (math.pi / 8) * i - math.pi / 2;
    final p = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  path.close();
  return path;
}

/// A subtle tiled geometric pattern used behind headers.
class IslamicPatternPainter extends CustomPainter {
  IslamicPatternPainter({required this.color, this.cell = 36});
  final Color color;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double y = cell / 2; y < size.height + cell; y += cell) {
      for (double x = cell / 2; x < size.width + cell; x += cell) {
        canvas.drawPath(starPath(Offset(x, y), cell * 0.42), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter old) =>
      old.color != color || old.cell != cell;
}

/// Gradient header panel with the geometric pattern overlay.
class PatternPanel extends StatelessWidget {
  const PatternPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF123B30), Color(0xFF0B241C)]
                : const [AppColors.emerald, AppColors.emeraldDark],
          ),
        ),
        child: CustomPaint(
          painter: IslamicPatternPainter(color: Colors.white.withValues(alpha: 0.07)),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
