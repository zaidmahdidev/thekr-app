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
