import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/calendar/models/islamic_occasion.dart';
import 'package:thekr_app/features/calendar/services/calendar_service.dart';
import 'package:thekr_app/features/calendar/widgets/calendar_hero_card.dart';

/// The next special days with a countdown.
class UpcomingOccasionsCard extends StatelessWidget {
  const UpcomingOccasionsCard({
    super.key,
    required this.items,
    required this.onSelected,
  });

  final List<UpcomingOccasion> items;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

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
                'المناسبات القادمة',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ],
          ),
          SizedBox(height: context.insets.sm),
          for (final item in items) _Row(item: item, onTap: onSelected),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.onTap});

  final UpcomingOccasion item;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final isEid = item.occasion.kind == OccasionKind.eid;
    final color = isEid ? context.colors.secondary : context.colors.primary;
    final hijri = item.hijri;

    return InkWell(
      borderRadius: BorderRadius.circular(context.corners.lg),
      onTap: () => onTap(item.date),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.insets.sm),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.occasion.kind.icon, size: 19.sp, color: color),
            ),
            SizedBox(width: context.insets.sm + 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.occasion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.titleSmall?.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    '${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear} هـ',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.insets.sm + 2.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.corners.xl),
              ),
              child: Text(
                CalendarHeroCard.daysLabel(item.daysLeft),
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
    );
  }
}
