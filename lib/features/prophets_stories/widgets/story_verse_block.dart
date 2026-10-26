import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';

/// Verses of the Quran inside a story, shown apart from the story's own words:
/// a framed block with the verses and the surah they come from.
class StoryVerseBlock extends StatelessWidget {
  const StoryVerseBlock({
    super.key,
    required this.text,
    required this.reference,
    required this.fontSize,
  });

  final String text;
  final String reference;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = context.textStyles.bodyLarge!.copyWith(
      color: colors.textPrimary,
      fontWeight: FontWeight.bold,
      fontSize: QuranText.isUthmani(text)
          ? fontSize * QuranText.fontScale
          : fontSize,
      height: 2.0,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.insets.md,
        vertical: context.insets.md,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '﴿ $text ﴾',
            textAlign: TextAlign.center,
            style: QuranText.style(base, text),
          ),
          SizedBox(height: context.insets.sm),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: context.insets.md,
              vertical: 4.h,
            ),
            child: Text(
              reference,
              style: context.textStyles.bodySmall?.copyWith(
                color: colors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
