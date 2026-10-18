import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/features/home/models/inspiration_item.dart';
import 'package:thekr_app/features/home/providers/ayah_glyphs_provider.dart';
import 'package:thekr_app/features/quran/services/quran_reader_adapter.dart';

/// How an inspiration is written on screen: the span and the base style.
///
/// Verses are drawn with the Mushaf page font (exactly like the reader). While
/// that font loads, or if it is unavailable, they fall back to the Quran text
/// font. Hadiths and adhkar use the app font.
class InspirationReading {
  final TextSpan span;
  final TextStyle style;

  const InspirationReading({required this.span, required this.style});

  /// [isDark] must match the surface the text is drawn on, because the Mushaf
  /// fonts come in light and dark variants.
  static InspirationReading of(
    BuildContext context,
    WidgetRef ref,
    InspirationItem item, {
    required Color color,
    required Color markColor,
    required bool isDark,
    double scale = 1,
  }) {
    final isAyah = item.type == InspirationType.ayah;
    final base = context.textStyles.bodyLarge!.copyWith(
      color: color,
      fontSize: (isAyah ? 15.5.sp : 14.sp) * scale,
      fontWeight: isAyah ? FontWeight.w500 : FontWeight.w600,
      height: isAyah ? 1.85 : 1.7,
    );

    final ref0 = item.ayah;
    if (ref0 != null) {
      final glyphs = ref
          .watch(
            ayahGlyphsProvider((
              surah: ref0.surah,
              ayah: ref0.ayah,
              page: ref0.page,
              isDark: isDark,
            )),
          )
          .value;
      if (glyphs != null) return _mushaf(base, glyphs, ref0, markColor);
    }

    final style = QuranText.style(base, item.content);
    return InspirationReading(
      span: TextSpan(text: item.content, style: style),
      style: style,
    );
  }

  static InspirationReading _mushaf(
    TextStyle base,
    QuranAyahGlyphs glyphs,
    AyahRef ref,
    Color markColor,
  ) {
    // Page fonts are drawn a little larger than regular text.
    final size = (base.fontSize ?? 16) * 1.28;
    final style = base.copyWith(fontSize: size, height: 1.95);

    return InspirationReading(
      style: style,
      span: TextSpan(
        style: style,
        children: [
          for (final part in glyphs.parts)
            TextSpan(
              text: part.glyphs,
              style: style.copyWith(fontFamily: part.fontFamily),
            ),
          TextSpan(
            text: '  ${QuranText.digits(ref.ayah)} ',
            style: style.copyWith(
              fontFamily: 'ayahNumber',
              package: 'quran_library',
              color: markColor,
              fontSize: size * 1.1,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
