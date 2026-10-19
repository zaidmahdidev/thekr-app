import 'package:flutter/material.dart';
import 'package:thekr_app/features/quran/providers/quran_provider.dart';

/// Colors of the Quran reader for the reading theme the user picked.
///
/// Every piece of reader chrome (top bar, sheets, dialogs) reads its colors from
/// here, so they always match the page instead of the app-wide theme.
class QuranReaderPalette {
  /// Page background.
  final Color background;

  /// Bar / sheet surface: the page color nudged toward the text color so it
  /// stays distinguishable from the page.
  final Color surface;

  final Color text;
  final Color textMuted;

  /// Icons and primary controls.
  final Color icon;

  /// Highlight color (active states, progress).
  final Color accent;

  final bool isDark;

  const QuranReaderPalette({
    required this.background,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.icon,
    required this.accent,
    required this.isDark,
  });

  /// [primary] is used as the icon color of the light theme, [accent] as the
  /// highlight color of all themes.
  factory QuranReaderPalette.of(
    QuranTheme theme, {
    required Color primary,
    required Color accent,
  }) {
    final Color background;
    final Color text;
    final Color icon;

    switch (theme) {
      case QuranTheme.light:
        background = const Color(0xFFFFFDF5);
        text = const Color(0xDE000000);
        icon = primary;
        break;
      case QuranTheme.dark:
        background = const Color(0xFF1F2125);
        text = const Color(0xE6FFFFFF);
        icon = const Color(0xFFFFFFFF);
        break;
      case QuranTheme.sepia:
        background = const Color(0xFFF4ECD8);
        text = const Color(0xFF5B4636);
        icon = const Color(0xFF8D6E63);
        break;
      case QuranTheme.green:
        background = const Color(0xFFE8F5E9);
        text = const Color(0xFF1B5E20);
        icon = const Color(0xFF2E7D32);
        break;
      case QuranTheme.blueGrey:
        background = const Color(0xFF343A41);
        text = const Color(0xFFECEFF1);
        icon = const Color(0xFFB0BEC5);
        break;
    }

    final isDark =
        theme == QuranTheme.dark || theme == QuranTheme.blueGrey;

    return QuranReaderPalette(
      background: background,
      surface: Color.lerp(background, text, isDark ? 0.08 : 0.05)!,
      text: text,
      textMuted: text.withValues(alpha: 0.6),
      icon: icon,
      accent: accent,
      isDark: isDark,
    );
  }
}
