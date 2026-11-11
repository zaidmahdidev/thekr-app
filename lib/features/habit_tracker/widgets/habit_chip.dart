import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// A tick box shaped as a pill: filled with a check when done.
class HabitChip extends StatelessWidget {
  const HabitChip({
    super.key,
    required this.label,
    required this.done,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool done;
  final VoidCallback onTap;

  /// Smaller, for the extra acts of worship.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textColor = done
        ? Theme.of(context).colorScheme.onPrimary
        : colors.textPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: done ? colors.primary : colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(
          color: done ? colors.primary : colors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.lg),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? context.insets.md : context.insets.sm,
              vertical: compact ? context.insets.sm : context.insets.sm * 1.25,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                if (done) ...[
                  SizedBox(width: 4.w),
                  AppIcon(
                    HugeIcons.strokeRoundedTick02,
                    size: 16.sp,
                    color: textColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
