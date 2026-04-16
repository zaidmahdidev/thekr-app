import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:thekr_app/features/home/models/app_prayer_times.dart';

class NextPrayerHeader extends StatelessWidget {
  final AppPrayerTimes? prayerTimes;
  final AppPrayerTimes? tomorrowTimes;

  const NextPrayerHeader({super.key, this.prayerTimes, this.tomorrowTimes});

  @override
  Widget build(BuildContext context) {
    final bool isLoading = prayerTimes == null;

    // Use our local model logic for next prayer
    final AppPrayer? currentDayNext = isLoading
        ? null
        : prayerTimes!.nextPrayer(DateTime.now());

    AppPrayer nextPrayer;
    DateTime? time;

    if (currentDayNext == null && !isLoading) {
      // It's after Isha, use tomorrow's Fajr
      nextPrayer = AppPrayer.fajr;
      time = tomorrowTimes?.fajr;
    } else {
      nextPrayer = currentDayNext ?? AppPrayer.fajr;
      time = isLoading ? null : prayerTimes!.getTimeFor(nextPrayer);
    }

    final name = isLoading ? 'جاري التحميل...' : nextPrayer.nameArabic;

    return Container(
      margin: EdgeInsets.all(context.insets.md),
      height: 100.h,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(context.corners.xl),
              border: Border.all(color: context.colors.secondary, width: 1),
              boxShadow: context.shadows.medium,
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.corners.xl),
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(AppAssets.around, fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.insets.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الصلاة القادمة',
                      style: AppTypography.label.copyWith(
                        color: context.colors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      name,
                      style: AppTypography.h2.copyWith(
                        color: Colors.white,
                        fontSize: 26.sp,
                      ),
                    ),
                  ],
                ),
                if (time != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.insets.md,
                      vertical: context.insets.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.corners.lg),
                      border: Border.all(
                        color: context.colors.secondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      intl.DateFormat('h:mm a', 'ar').format(time),
                      style: AppTypography.h1.copyWith(
                        color: context.colors.secondary,
                        fontSize: 26.sp,
                      ),
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
