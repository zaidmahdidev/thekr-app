import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:thekr_app/features/home/models/app_prayer_times.dart';

class PrayerTimesCard extends StatelessWidget {
  const PrayerTimesCard({super.key, required this.prayerTimes});

  final AppPrayerTimes? prayerTimes;

  @override
  Widget build(BuildContext context) {
    final bool isLoading = prayerTimes == null;

    // Calculate next prayer using our own model logic
    final AppPrayer nextPrayer = isLoading
        ? AppPrayer.fajr
        : (prayerTimes!.nextPrayer(DateTime.now()) ?? AppPrayer.fajr);

    final List<_PrayerTimeDisplay> items = AppPrayer.values.map((p) {
      final time = isLoading
          ? '--:--'
          : intl.DateFormat('h:mm').format(prayerTimes!.getTimeFor(p));

      return _PrayerTimeDisplay(
        name: p.nameArabic,
        time: time,
        isNext: !isLoading && nextPrayer == p,
      );
    }).toList();

    return Container(
      margin: EdgeInsets.all(context.insets.sm),
      padding: EdgeInsets.symmetric(
        vertical: context.insets.sm,
        horizontal: context.insets.sm / 4,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(
          color: context.colors.secondary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((t) => _buildPrayerItem(context, t)).toList(),
        ),
      ),
    );
  }

  Widget _buildPrayerItem(BuildContext context, _PrayerTimeDisplay item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: item.isNext
            ? context.colors.secondary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(context.corners.md),
        border: Border.all(
          color: item.isNext
              ? context.colors.secondary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.name,
            style: AppTypography.label.copyWith(
              color: item.isNext
                  ? context.colors.secondary
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 12.5.sp,
              fontWeight: item.isNext ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            item.time,
            style: AppTypography.bodySmall.copyWith(
              color: item.isNext
                  ? context.colors.secondary
                  : context.colors.primary,
              fontSize: 14.5.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (item.isNext)
            Container(
              margin: EdgeInsets.only(top: 2.h),
              width: 4.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.colors.secondary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _PrayerTimeDisplay {
  final String name;
  final String time;
  final bool isNext;
  _PrayerTimeDisplay({
    required this.name,
    required this.time,
    required this.isNext,
  });
}
