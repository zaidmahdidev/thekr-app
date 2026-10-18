import 'package:flutter/material.dart';

/// Helpers for text that comes from the Quran data (Uthmani script).
///
/// That script uses marks (wasla ٱ, small high sukun ۡ ...) that regular UI
/// fonts do not draw correctly, so such text must be shown with the Quran font
/// bundled with `quran_library`.
class QuranText {
  QuranText._();

  static final RegExp _uthmaniMarks = RegExp('[ٱۡ]');

  static bool isUthmani(String text) => _uthmaniMarks.hasMatch(text);

  /// Number written with Arabic-Indic digits.
  static String digits(int number) {
    const map = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((c) => map[int.parse(c)]).join();
  }

  /// Returns [base] switched to the Quran font when [text] needs it.
  static TextStyle style(TextStyle base, String text) {
    if (!isUthmani(text)) return base;
    return base.copyWith(fontFamily: 'hafs', package: 'quran_library');
  }
}
