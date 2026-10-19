import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/calendar/models/islamic_occasion.dart';
import 'package:thekr_app/features/calendar/services/calendar_service.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Everything about the selected day: both dates, occasions, fasting and Friday.
class CalendarDayDetails extends StatelessWidget {
  const CalendarDayDetails({super.key, required this.day});

  final CalendarDay day;

  @override
  Widget build(BuildContext context) {
    final hijri = day.hijri;
    final date = day.date;
    final weekday = CalendarService.weekdayNames[(date.weekday + 1) % 7];
    final month = CalendarService.gregorianMonths[date.month - 1];

    final tiles = <Widget>[
      for (final o in day.occasions)
        _DetailTile(
          icon: o.kind.icon,
          color: o.kind.color(context),
          title: o.title,
          subtitle: o.note,
        ),
      if (day.hasFasting &&
          !day.occasions.any((o) => o.kind == OccasionKind.fasting))
        _DetailTile(
          icon: OccasionKind.fasting.icon,
          color: OccasionKind.fasting.color(context),
          title: day.fastingHints.join(' • '),
          subtitle: 'يُستحب الصيام في هذا اليوم.',
        ),
      if (day.isFriday)
        _DetailTile(
          icon: HugeIcons.strokeRoundedMosque01,
          color: context.colors.secondary,
          title: 'يوم الجمعة',
          subtitle: 'يُستحب قراءة سورة الكهف والإكثار من الصلاة على النبي ﷺ.',
        ),
    ];

    return Container(
      width: double.infinity,
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
          Text(
            '${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear} هـ',
            style: context.textStyles.titleLarge?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          Text(
            '$weekday ${date.day} $month ${date.year} م',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
              height: 1.3,
            ),
          ),
          SizedBox(height: context.insets.md),
          if (tiles.isEmpty)
            Text(
              'لا توجد مناسبات خاصة في هذا اليوم.',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            )
          else
            for (int i = 0; i < tiles.length; i++) ...[
              if (i > 0) SizedBox(height: context.insets.sm),
              tiles[i],
            ],
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final AppIconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.insets.sm + 2.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(context.corners.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: AppIcon(icon, size: 18.sp, color: color),
          ),
          SizedBox(width: context.insets.sm + 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyles.titleSmall?.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.5,
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

/// Legend under the grid.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (OccasionKind.eid, 'عيد'),
      (OccasionKind.special, 'مناسبة'),
      (OccasionKind.fasting, 'صيام مستحب'),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: context.insets.md,
      children: [
        for (final (kind, label) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kind.color(context),
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                label,
                style: context.textStyles.labelSmall?.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
