import 'package:flutter/material.dart';

/// Brand palette: deep emerald with warm gold accents on a paper-like surface.
class AppColors {
  AppColors._();
  static const emerald = Color(0xFF0F6E56);
  static const emeraldDark = Color(0xFF0A4A3A);
  static const gold = Color(0xFFC9A227);
  static const goldLight = Color(0xFFE8CF7A);
  static const paper = Color(0xFFFBF8F1);
  static const paperCard = Color(0xFFFFFDF8);
  static const ink = Color(0xFF1B1F1D);
  static const night = Color(0xFF0E1412);
  static const nightCard = Color(0xFF17201C);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.emerald,
      brightness: Brightness.light,
      primary: AppColors.emerald,
      secondary: AppColors.gold,
      surface: AppColors.paper,
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      cardTheme: const CardThemeData(
        color: AppColors.paperCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: Color(0x14000000)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.emerald,
      brightness: Brightness.dark,
      primary: const Color(0xFF5FD3B0),
      secondary: AppColors.goldLight,
      surface: AppColors.night,
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.night,
      cardTheme: const CardThemeData(
        color: AppColors.nightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: Color(0x1FFFFFFF)),
        ),
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        indicatorColor: scheme.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurface),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Text-style helpers for Arabic script.
class ArabicStyles {
  ArabicStyles._();

  static const quranFont = 'AmiriQuran';
  static const nameFont = 'Amiri';

  /// The Madani Mushaf script (DigitalKhatt Madina, OFL) used by the
  /// line-by-line Mushaf pages.
  static const mushafFont = 'DigitalKhatt';

  static TextStyle ayah(BuildContext context, {double scale = 1, String font = quranFont}) {
    return TextStyle(
      fontFamily: font,
      fontSize: 28 * scale,
      height: font == quranFont ? 2.1 : 1.9,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle surahName(BuildContext context, {double size = 22, Color? color}) {
    return TextStyle(
      fontFamily: nameFont,
      fontSize: size,
      height: 1.4,
      fontWeight: FontWeight.w700,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }
}
