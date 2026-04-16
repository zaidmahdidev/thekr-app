import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Tajawal';

  // Headlines
  static TextStyle get h1 =>
      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold);

  static TextStyle get h2 =>
      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold);

  static TextStyle get h3 =>
      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold);

  // Body Text
  static TextStyle get bodyLarge => TextStyle(fontSize: 14.sp);

  static TextStyle get bodyMedium => TextStyle(fontSize: 13.sp);

  static TextStyle get bodySmall => TextStyle(fontSize: 11.sp);

  static TextStyle get label => TextStyle(fontSize: 10.sp);

  static TextStyle get button => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15.sp,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.25,
  );
}
