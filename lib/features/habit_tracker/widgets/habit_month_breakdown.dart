import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/app_digits.dart';
import 'package:thekr_app/features/habit_tracker/models/daily_habit_model.dart';

/// For each prayer, how many days of the month it was prayed.
class HabitMonthBreakdown extends StatelessWidget {
  const HabitMonthBreakdown({
    super.key,
    required this.month,
    required this.today,
    required this.habitFor,
  });

  final DateTime month;
  final DateTime today;
  final DailyHabit Function(DateTime date) habitFor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    // Only the days that have come count, so the numbers are fair mid-month.
    final counted = [
      for (var day = 1; day <= daysInMonth; day++)
        if (!DateTime(month.year, month.month, day).isAfter(today))
          DateTime(month.year, month.month, day),
    ];
    final habits = [for (final d in counted) habitFor(d)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفصيل الشهر',
          style: context.textStyles.titleMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.insets.sm),
        for (final field in HabitField.fard)
          _Row(
            label: field.label,
            done: habits.where((h) => h.isDone(field)).length,
            total: counted.length,
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.done, required this.total});

  final String label;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fraction = total == 0 ? 0.0 : done / total;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 64.w,
            child: Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.corners.sm),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8.h,
                backgroundColor: colors.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            ),
          ),
          SizedBox(width: context.insets.sm),
          SizedBox(
            width: 64.w,
            child: Text(
              '${AppDigits.of(done)} من ${AppDigits.of(total)}',
              textAlign: TextAlign.end,
              style: context.textStyles.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
