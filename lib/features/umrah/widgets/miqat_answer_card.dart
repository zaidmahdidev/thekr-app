import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import '../models/umrah_models.dart';
import '../providers/umrah_text.dart';

/// Where to ihram for the chosen situation: the miqat, its place today, the
/// details and the text the ruling rests on.
class MiqatAnswerCard extends ConsumerWidget {
  const MiqatAnswerCard({super.key, required this.answer, this.framed = true});

  final MiqatAnswer answer;

  /// Draws the border and shadow; turn off when it sits inside a sheet.
  final bool framed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(framed ? context.insets.md : 0),
      decoration: framed
          ? BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(context.corners.xl),
              border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
              boxShadow: context.shadows.medium,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ميقاتك',
            style: text.small(context, color: colors.textSecondary),
          ),
          Text(
            answer.title,
            style: context.textStyles.headlineMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          SizedBox(height: context.insets.sm),
          Container(
            padding: EdgeInsets.all(context.insets.sm + 4.w),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(context.corners.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: AppIcon(
                    HugeIcons.strokeRoundedLocation01,
                    size: 22.w,
                    color: colors.primary,
                  ),
                ),
                SizedBox(width: context.insets.sm),
                Expanded(
                  child: Text(
                    answer.place,
                    style: text.body(context, weight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.insets.md),
          for (final detail in answer.details)
            Padding(
              padding: EdgeInsets.only(bottom: context.insets.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 13.h),
                    child: Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: BoxDecoration(
                        color: colors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(width: context.insets.sm + 2.w),
                  Expanded(child: Text(detail, style: text.body(context))),
                ],
              ),
            ),
          SizedBox(height: context.insets.sm),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.insets.sm + 4.w),
            decoration: BoxDecoration(
              color: colors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.corners.md),
            ),
            child: Text(
              'الدليل: ${answer.evidence}',
              style: text.small(
                context,
                color: colors.textPrimary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
