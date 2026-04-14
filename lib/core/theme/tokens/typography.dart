import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Tajawal';

  // Headlines
  static TextStyle get h1 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle get h2 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle get h3 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  // Body Text
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    height: 1.6,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    height: 1.6,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // Helper styles
  static TextStyle get label => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle get button => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.25,
  );
}
