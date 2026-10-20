import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:thekr_app/core/widgets/app_button.dart';
import 'package:thekr_app/features/home/models/app_prayer_times.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hugeicons/hugeicons.dart';

class PrayerTimesCard extends StatelessWidget {
  const PrayerTimesCard({
    super.key,
    required this.prayerTimes,
    this.onRequestLocation,
  });

  final AppPrayerTimes? prayerTimes;
  final VoidCallback? onRequestLocation;

  @override
  Widget build(BuildContext context) {
    final bool isLoading = prayerTimes == null;
    final bool isLocationOff = prayerTimes?.isLocationOff ?? false;
    final now = DateTime.now();

    final AppPrayer nextPrayer = isLoading
        ? AppPrayer.fajr
        : (prayerTimes!.nextPrayer(now) ?? AppPrayer.fajr);

    final items = AppPrayer.values.map((p) {
      final moment = isLoading ? null : prayerTimes!.getTimeFor(p);
      final isNext = !isLoading && nextPrayer == p;

      return _PrayerTimeDisplay(
        prayer: p,
        time: moment == null
            ? '--:--'
            : intl.DateFormat('h:mm', 'en').format(moment),
        period: moment == null ? null : (moment.hour < 12 ? 'ص' : 'م'),
        isNext: isNext,
        isPast: !isLoading && !isNext && moment!.isBefore(now),
      );
    }).toList();

    final colors = context.colors;

    return GestureDetector(
      onTap: () => context.pushRoute(const AthanSettingsRoute()),
      child: Container(
        margin: EdgeInsets.all(context.insets.sm),
        padding: EdgeInsets.symmetric(
          vertical: context.insets.sm / 2,
          horizontal: context.insets.sm / 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.corners.xl),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.surface,
              Color.alphaBlend(
                colors.secondary.withValues(alpha: 0.05),
                colors.surface,
              ),
            ],
          ),
          border: Border.all(color: colors.secondary.withValues(alpha: 0.18)),
          boxShadow: context.shadows.low,
        ),
        child: Column(
          children: [
            if (isLocationOff)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: AppButton(
                  text: 'سماح للموقع',
                  icon: HugeIcons.strokeRoundedLocation01,
                  size: AppButtonSize.small,
                  isFullWidth: false,
                  onTap: onRequestLocation,
                ),
              ),
            Row(
              children: [
                for (final item in items)
                  Expanded(child: _PrayerCell(item: item)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One prayer: its name and time. The next prayer is filled with gold and
/// the ones already prayed today are dimmed.
class _PrayerCell extends StatelessWidget {
  const _PrayerCell({required this.item});

  final _PrayerTimeDisplay item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = item.isNext ? colors.secondary : colors.primary;

    return Opacity(
      opacity: item.isPast ? 0.55 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 2.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.corners.lg),
          gradient: item.isNext
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.secondary.withValues(alpha: 0.22),
                    colors.secondary.withValues(alpha: 0.08),
                  ],
                )
              : null,
          border: Border.all(
            color: item.isNext
                ? colors.secondary.withValues(alpha: 0.55)
                : Colors.transparent,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.prayer.nameArabic,
                style: context.textStyles.bodySmall?.copyWith(
                  color: item.isNext
                      ? colors.secondary
                      : context.textStyles.bodyMedium?.color,
                  fontWeight: item.isNext ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              SizedBox(height: 5.h),
              Text.rich(
                TextSpan(
                  text: item.time,
                  children: [
                    if (item.period != null)
                      TextSpan(
                        text: ' ${item.period}',
                        style: context.textStyles.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                style: context.textStyles.bodyLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerTimeDisplay {
  final AppPrayer prayer;
  final String time;
  final String? period;
  final bool isNext;
  final bool isPast;

  _PrayerTimeDisplay({
    required this.prayer,
    required this.time,
    required this.period,
    required this.isNext,
    required this.isPast,
  });
}
