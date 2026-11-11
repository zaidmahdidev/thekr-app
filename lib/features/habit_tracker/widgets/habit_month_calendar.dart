import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/app_digits.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/habit_tracker/models/daily_habit_model.dart';

/// The month as a grid of days. Each day fills from the bottom by how many of
/// the five prayers were prayed; a full day is solid. Tap a day to edit it.
class HabitMonthCalendar extends StatelessWidget {
  const HabitMonthCalendar({
    super.key,
    required this.month,
    required this.today,
    required this.habitFor,
    required this.onPrevious,
    required this.onNext,
    required this.onDayTap,
  });

  /// The first day of the month shown.
  final DateTime month;
  final DateTime today;
  final DailyHabit Function(DateTime date) habitFor;
  final VoidCallback onPrevious;

  /// Null when the month shown is the current one.
  final VoidCallback? onNext;
  final ValueChanged<DateTime> onDayTap;

  static const List<String> _weekdays = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    // Sunday first: DateTime.sunday is 7, so the remainder gives 0 for Sunday.
    final leading = month.weekday % 7;
    final title = AppDigits.latin(DateFormat('MMMM yyyy', 'ar').format(month));

    return Column(
      children: [
        Row(
          children: [
            _MonthArrow(
              icon: HugeIcons.strokeRoundedArrowRight01,
              onTap: onPrevious,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: context.textStyles.titleMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _MonthArrow(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              onTap: onNext,
            ),
          ],
        ),
        SizedBox(height: context.insets.sm),
        Row(
          children: [
            for (final name in _weekdays)
              Expanded(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: context.insets.sm),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6.w,
          crossAxisSpacing: 6.w,
          children: [
            for (var i = 0; i < leading; i++) const SizedBox.shrink(),
            for (var day = 1; day <= daysInMonth; day++)
              _DayCell(
                date: DateTime(month.year, month.month, day),
                today: today,
                habit: habitFor(DateTime(month.year, month.month, day)),
                onTap: onDayTap,
              ),
          ],
        ),
      ],
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, required this.onTap});

  final AppIconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton(
      onPressed: onTap,
      icon: Directionality(
        textDirection: TextDirection.ltr,
        child: AppIcon(
          icon,
          size: 22.sp,
          color: onTap == null
              ? colors.textSecondary.withValues(alpha: 0.3)
              : colors.textPrimary,
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.today,
    required this.habit,
    required this.onTap,
  });

  final DateTime date;
  final DateTime today;
  final DailyHabit habit;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFuture = date.isAfter(today);
    final isToday = DateUtils.isSameDay(date, today);
    final fraction = habit.fardCount / 5;
    final radius = BorderRadius.circular(context.corners.md);

    final textColor = isFuture
        ? colors.textSecondary.withValues(alpha: 0.4)
        : fraction >= 0.6
        ? Theme.of(context).colorScheme.onPrimary
        : colors.textPrimary;

    return Opacity(
      opacity: isFuture ? 0.55 : 1,
      child: GestureDetector(
        onTap: isFuture ? null : () => onTap(date),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: radius,
            border: Border.all(
              color: isToday
                  ? colors.secondary
                  : colors.primary.withValues(alpha: 0.15),
              width: isToday ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (fraction > 0)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: fraction,
                      widthFactor: 1,
                      child: ColoredBox(color: colors.primary),
                    ),
                  ),
                Text(
                  AppDigits.of(date.day),
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
