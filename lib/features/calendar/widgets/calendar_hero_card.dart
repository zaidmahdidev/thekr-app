import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/brand_surface.dart';
import 'package:thekr_app/features/calendar/services/calendar_service.dart';

/// Today's Hijri and Gregorian date, plus the next special day.
class CalendarHeroCard extends StatelessWidget {
  const CalendarHeroCard({super.key, required this.today, this.next});

  final CalendarDay today;
  final UpcomingOccasion? next;

  static String daysLabel(int days) {
    if (days == 0) return 'اليوم';
    if (days == 1) return 'غداً';
    if (days == 2) return 'بعد يومين';
    if (days <= 10) return 'بعد $days أيام';
    return 'بعد $days يوماً';
  }

  @override
  Widget build(BuildContext context) {
    final style = BrandSurfaceStyle.of(context);
    final hijri = today.hijri;
    final date = today.date;
    final weekday = CalendarService.weekdayNames[(date.weekday + 1) % 7];
    final month = CalendarService.gregorianMonths[date.month - 1];

    return BrandSurface(
      padding: EdgeInsets.all(context.insets.md),
      child: Row(
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style.controlBackground,
              border: Border.all(color: style.gold.withValues(alpha: 0.4)),
            ),
            child: Icon(Icons.nightlight_round, size: 26.sp, color: style.gold),
          ),
          SizedBox(width: context.insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اليوم',
                  style: context.textStyles.labelMedium?.copyWith(
                    color: style.accent,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                Text(
                  '${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear} هـ',
                  style: context.textStyles.titleLarge?.copyWith(
                    color: style.text,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                Text(
                  '$weekday ${date.day} $month ${date.year} م',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: style.textMuted,
                    height: 1.3,
                  ),
                ),
                if (next != null) ...[
                  SizedBox(height: context.insets.sm),
                  Row(
                    children: [
                      Icon(Icons.event_rounded, size: 14.sp, color: style.gold),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          '${next!.occasion.title} ${daysLabel(next!.daysLeft)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.labelMedium?.copyWith(
                            color: style.text,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
