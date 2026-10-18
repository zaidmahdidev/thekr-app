import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/calendar/models/islamic_occasion.dart';
import 'package:thekr_app/features/calendar/services/calendar_service.dart';

/// Month grid (week starts on Saturday). [primaryIsHijri] decides which date is
/// the big number; the other calendar is shown small underneath.
class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({
    super.key,
    required this.cells,
    required this.primaryIsHijri,
    required this.selected,
    required this.today,
    required this.onSelected,
  });

  final List<DateTime?> cells;
  final bool primaryIsHijri;
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelected;

  static const _weekdayShort = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < 7; i++)
              Expanded(
                child: SizedBox(
                  height: 28.h,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _weekdayShort[i],
                        style: context.textStyles.labelSmall?.copyWith(
                          color: i == 6
                              ? context.colors.secondary
                              : context.colors.textSecondary,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: cells.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 56.h,
          ),
          itemBuilder: (context, index) {
            final date = cells[index];
            if (date == null) return const SizedBox.shrink();
            return _DayCell(
              info: CalendarService.day(date),
              primaryIsHijri: primaryIsHijri,
              isSelected: DateUtils.isSameDay(date, selected),
              isToday: DateUtils.isSameDay(date, today),
              onTap: () => onSelected(date),
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.info,
    required this.primaryIsHijri,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final CalendarDay info;
  final bool primaryIsHijri;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  List<Color> _dots(BuildContext context) {
    final kinds = <OccasionKind>{
      for (final o in info.occasions) o.kind,
      if (info.hasFasting) OccasionKind.fasting,
    };
    return [for (final k in kinds.take(3)) k.color(context)];
  }

  @override
  Widget build(BuildContext context) {
    final big = primaryIsHijri ? info.hijri.hDay : info.date.day;
    final small = primaryIsHijri ? info.date.day : info.hijri.hDay;

    Color numberColor = context.colors.textPrimary;
    Color smallColor = context.colors.textSecondary;
    Color? fill;
    Border? border;

    if (isSelected) {
      fill = context.colors.primary;
      numberColor = context.colors.surface;
      smallColor = context.colors.surface.withValues(alpha: 0.75);
    } else if (isToday) {
      fill = context.colors.secondary.withValues(alpha: 0.14);
      border = Border.all(color: context.colors.secondary, width: 1.2);
      numberColor = context.colors.secondary;
    } else if (info.isFriday) {
      numberColor = context.colors.secondary;
    }

    final dots = _dots(context);

    return Padding(
      padding: EdgeInsets.all(2.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.md),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: fill,
              border: border,
              borderRadius: BorderRadius.circular(context.corners.md),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$big',
                  style: context.textStyles.bodyLarge?.copyWith(
                    color: numberColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    height: 1.1,
                  ),
                ),
                Text(
                  '$small',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: smallColor,
                    fontSize: 9.5.sp,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  height: 5.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final color in dots)
                        Container(
                          width: 5.w,
                          height: 5.w,
                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? context.colors.surface : color,
                          ),
                        ),
                    ],
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
