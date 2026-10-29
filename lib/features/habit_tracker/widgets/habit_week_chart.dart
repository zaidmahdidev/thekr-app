import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/calendar/services/calendar_service.dart';
import 'package:thekr_app/core/utils/app_digits.dart';

/// The last seven days as bars. Tap a bar to open that day.
class HabitWeekChart extends StatelessWidget {
  const HabitWeekChart({
    super.key,
    required this.progress,
    required this.average,
    required this.selectedDate,
    required this.onSelected,
  });

  /// Completion (0..1) of the recent days, oldest first (the last 7 are shown).
  final List<double> progress;
  final double average;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  static const double barMax = 54;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = progress.length > 7
        ? progress.sublist(progress.length - 7)
        : progress;
    final dates = [
      for (int i = 0; i < days.length; i++)
        today.subtract(Duration(days: days.length - 1 - i)),
    ];

    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.1),
        ),
        boxShadow: context.shadows.low,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: context.colors.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: context.insets.sm),
              Text(
                'آخر 7 أيام',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              Text(
                'المعدل ${AppDigits.of((average * 100).round())}%',
                style: context.textStyles.labelMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: context.insets.md),
          SizedBox(
            height: barMax.h + 26.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < days.length; i++)
                  Expanded(
                    child: _Bar(
                      value: days[i],
                      label: CalendarService
                          .weekdayNames[(dates[i].weekday + 1) % 7],
                      isToday: i == days.length - 1,
                      isSelected: DateUtils.isSameDay(dates[i], selectedDate),
                      onTap: () => onSelected(dates[i]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.label,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final double value;
  final String label;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = value >= 1.0
        ? context.colors.secondary
        : context.colors.primary;
    final height = (HabitWeekChart.barMax * value).clamp(4.0, 999.0).h;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            width: 20.w,
            height: height,
            decoration: BoxDecoration(
              color: value == 0
                  ? context.colors.primary.withValues(alpha: 0.1)
                  : color.withValues(alpha: isSelected ? 1 : 0.65),
              borderRadius: BorderRadius.circular(6.r),
              border: isSelected
                  ? Border.all(color: context.colors.secondary, width: 1.5)
                  : null,
            ),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            height: 18.h,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isToday ? 'اليوم' : label,
                style: context.textStyles.labelSmall?.copyWith(
                  color: isSelected || isToday
                      ? context.colors.primary
                      : context.colors.textSecondary,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
