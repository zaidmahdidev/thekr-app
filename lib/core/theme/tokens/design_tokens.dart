import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color error;
  final Color success;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.error,
    required this.success,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
  });

  static const MaterialColor primarySwatch =
      MaterialColor(0xFF0E635B, <int, Color>{
        50: Color(0xFFE2ECEB),
        100: Color(0xFFB7D0CE),
        200: Color(0xFF87B1AD),
        300: Color(0xFF56928C),
        400: Color(0xFF327A74),
        500: Color(0xFF0E635B),
        600: Color(0xFF0C5B53),
        700: Color(0xFF0A5149),
        800: Color(0xFF084740),
        900: Color(0xFF04352F),
      });

  static const light = AppColors(
    primary: Color(0xFF0E645C),
    secondary: Color(0xFFFF9900),
    surface: Colors.white,
    error: Color(0xFFDC3545),
    success: Color(0xFF28A745),
    background: Color(0xFFF8F9FA),
    textPrimary: Color(0xFF212529),
    textSecondary: Color(0xFF6C757D),
  );

  static const dark = AppColors(
    primary: Color(0xFF0E645C),
    secondary: Color(0xFFFF9900),
    surface: Color(0xFF1E1E1E),
    error: Color(0xFFE35D6A),
    success: Color(0xFF47C363),
    background: Color(0xFF121212),
    textPrimary: Color(0xFFF8F9FA),
    textSecondary: Color(0xFFADB5BD),
  );

  // Desert Theme
  static const desertLight = AppColors(
    primary: Color(0xFFC19A6B), // Desert Sand
    secondary: Color(0xFFE1AD01), // Mustard Gold
    surface: Color(0xFFFFF9E3),
    error: Color(0xFFDC3545),
    success: Color(0xFF28A745),
    background: Color(0xFFFDF5E6), // Old Lace
    textPrimary: Color(0xFF5D4037),
    textSecondary: Color(0xFF8D6E63),
  );

  static const desertDark = AppColors(
    primary: Color(0xFFC19A6B),
    secondary: Color(0xFFE1AD01),
    surface: Color(0xFF2D241E),
    error: Color(0xFFE35D6A),
    success: Color(0xFF47C363),
    background: Color(0xFF1B1613),
    textPrimary: Color(0xFFEFEBE9),
    textSecondary: Color(0xFFBCAAA4),
  );

  // Forest Theme
  static const forestLight = AppColors(
    primary: Color(0xFF2D5A27), // Forest Green
    secondary: Color(0xFF8DA47E), // Sage Green
    surface: Color(0xFFF1F4F0),
    error: Color(0xFFDC3545),
    success: Color(0xFF2E7D32),
    background: Color(0xFFE8EDE7),
    textPrimary: Color(0xFF1B3022),
    textSecondary: Color(0xFF4A5D4E),
  );

  static const forestDark = AppColors(
    primary: Color(0xFF4A7C44),
    secondary: Color(0xFF8DA47E),
    surface: Color(0xFF1E261F),
    error: Color(0xFFE35D6A),
    success: Color(0xFF47C363),
    background: Color(0xFF121812),
    textPrimary: Color(0xFFE8F5E9),
    textSecondary: Color(0xFFA5B0A6),
  );
}

class AppCorners {
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double rc360;

  const AppCorners({
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.rc360,
  });

  factory AppCorners.defaultValues() =>
      AppCorners(sm: 4.r, md: 8.r, lg: 12.r, xl: 20.r, rc360: 360.r);
}

class AppInsets {
  final double sm;
  final double md;
  final double lg;
  final double xl;

  const AppInsets({
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  factory AppInsets.defaultValues() =>
      AppInsets(sm: 8.w, md: 16.w, lg: 24.w, xl: 32.w);
}

class AppShadows {
  final List<BoxShadow> low;
  final List<BoxShadow> medium;

  const AppShadows({required this.low, required this.medium});

  factory AppShadows.light() => [
    const BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ].toAppShadows();

  factory AppShadows.dark() => [
    const BoxShadow(
      color: Color(0x33000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ].toAppShadows();
}

extension BoxShadowListExt on List<BoxShadow> {
  AppShadows toAppShadows() => AppShadows(low: this, medium: this);
}
