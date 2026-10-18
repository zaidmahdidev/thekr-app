import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';

/// A group of habits (e.g. the five prayers) with its own progress.
class HabitCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<HabitItemData> items;

  const HabitCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final done = items.where((i) => i.isDone).length;
    final progress = items.isEmpty ? 0.0 : done / items.length;

    return Container(
      margin: EdgeInsets.only(bottom: context.insets.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: context.shadows.low,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.corners.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.insets.md,
                vertical: context.insets.sm + 2.h,
              ),
              color: color.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 18.sp),
                  ),
                  SizedBox(width: context.insets.sm + 2.w),
                  Expanded(
                    child: Text(
                      title,
                      style: context.textStyles.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.insets.sm + 2.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(context.corners.xl),
                    ),
                    child: Text(
                      '${QuranText.digits(done)} / ${QuranText.digits(items.length)}',
                      style: context.textStyles.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 3,
                backgroundColor: color.withValues(alpha: 0.08),
                color: color,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.insets.sm / 2),
              child: Column(
                children: [
                  for (final item in items) _HabitRow(item: item, color: color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({required this.item, required this.color});

  final HabitItemData item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        item.onToggle();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.insets.md,
          vertical: context.insets.sm + 1.h,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: item.isDone
                      ? context.colors.textSecondary
                      : context.colors.textPrimary,
                  decoration: item.isDone ? TextDecoration.lineThrough : null,
                  decorationColor: context.colors.textSecondary,
                  fontWeight: item.isDone ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ),
            if (item.points != null) ...[
              Text(
                '+${QuranText.digits(item.points!)}',
                style: context.textStyles.labelMedium?.copyWith(
                  color: item.isDone ? color : context.colors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: context.insets.sm + 2.w),
            ],
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: item.isDone ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isDone
                      ? color
                      : context.colors.textSecondary.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: item.isDone
                    ? Icon(
                        Icons.check_rounded,
                        key: const ValueKey('done'),
                        color: Colors.white,
                        size: 18.sp,
                      )
                    : const SizedBox.shrink(key: ValueKey('todo')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HabitItemData {
  final String title;
  final bool isDone;
  final VoidCallback onToggle;

  /// Points earned when done, shown next to the check (optional).
  final int? points;

  HabitItemData({
    required this.title,
    required this.isDone,
    required this.onToggle,
    this.points,
  });
}
