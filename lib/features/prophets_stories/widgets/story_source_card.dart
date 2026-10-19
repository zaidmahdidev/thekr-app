import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import '../models/prophet_story.dart';

/// Shown at the end of a story: the book the text comes from, or a notice when
/// the story is not documented yet.
class StorySourceCard extends StatelessWidget {
  const StorySourceCard({super.key, required this.source});

  final StorySource? source;

  @override
  Widget build(BuildContext context) {
    final documented = source != null;
    final accent = documented ? context.colors.primary : context.colors.secondary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                documented
                    ? Icons.verified_rounded
                    : Icons.hourglass_top_rounded,
                color: accent,
                size: 20.sp,
              ),
              SizedBox(width: context.insets.sm),
              Text(
                documented ? 'المصدر' : 'قيد التوثيق',
                style: context.textStyles.titleSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: context.insets.sm),
          if (source != null) ...[
            Text(
              source!.book,
              style: context.textStyles.titleSmall?.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            Text(
              source!.author,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            Text(
              source!.edition,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: context.insets.sm),
            Text(
              source!.note,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.textSecondary,
                height: 1.7,
              ),
            ),
          ] else
            Text(
              'نص هذه القصة قيد المراجعة، وسيُستبدل بنص موثّق من كتب أهل العلم '
              'مع ذكر المصدر. ما يُنقل من القصص هنا يجب مراجعته على المصادر '
              'المعتمدة.',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.textSecondary,
                height: 1.7,
              ),
            ),
        ],
      ),
    );
  }
}
