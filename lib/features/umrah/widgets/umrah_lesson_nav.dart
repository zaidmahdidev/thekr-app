import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Previous and next lesson buttons for the bottom of a lesson page. The next
/// button carries the name of the lesson it leads to, so the reader knows where
/// it goes. On the last lesson it becomes a finish button.
class UmrahLessonNav extends StatelessWidget {
  const UmrahLessonNav({
    super.key,
    required this.hasPrevious,
    required this.nextTitle,
    required this.onPrevious,
    required this.onNext,
    required this.onFinish,
  });

  final bool hasPrevious;

  /// Title of the next lesson, or null on the last one.
  final String? nextTitle;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.corners.xl),
    );
    final isLast = nextTitle == null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.insets.md,
        context.insets.sm + 2.w,
        context.insets.md,
        context.insets.sm + 2.w + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: context.shadows.medium,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.corners.xl),
        ),
      ),
      child: Row(
        children: [
          if (hasPrevious) ...[
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(
                      color: colors.textSecondary.withValues(alpha: 0.35),
                    ),
                    shape: shape,
                  ),
                  child: const Text('السابق'),
                ),
              ),
            ),
            SizedBox(width: context.insets.sm + 2.w),
          ],
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52.h,
              child: FilledButton.icon(
                onPressed: isLast ? onFinish : onNext,
                icon: AppIcon(
                  isLast
                      ? HugeIcons.strokeRoundedCheckmarkCircle02
                      : HugeIcons.strokeRoundedArrowRight01,
                ),
                iconAlignment: IconAlignment.end,
                label: Text(
                  isLast ? 'انتهيت من الدليل' : 'التالي: $nextTitle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: shape,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
