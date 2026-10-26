import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:thekr_app/features/prayer_times/providers/prayer_calc_provider.dart';
import 'package:thekr_app/features/prayer_times/utils/prayer_formatters.dart';

/// Today's six times, recalculated live as the user changes the settings.
class PrayerCalcPreview extends ConsumerWidget {
  const PrayerCalcPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final times = ref.watch(prayerCalcPreviewProvider).value;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.insets.sm,
        vertical: context.insets.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        boxShadow: context.shadows.low,
      ),
      child: times == null
          ? SizedBox(height: 48.h)
          : Row(
              children: [
                for (final prayer in AppPrayer.values)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          prayer.nameArabic,
                          style: (context.textStyles.bodySmall ??
                                  const TextStyle())
                              .copyWith(color: colors.textSecondary),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          PrayerFormatters.clock(times.getTimeFor(prayer)),
                          style: (context.textStyles.bodyLarge ??
                                  const TextStyle())
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
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
