import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import '../data/hajj_days_data.dart';
import '../models/hajj_models.dart';
import 'package:thekr_app/core/utils/app_digits.dart';

/// Hajj on one glance: the six stages in order, each opening its lesson.
class HajjOverviewStrip extends StatelessWidget {
  const HajjOverviewStrip({super.key, required this.onOpen});

  final ValueChanged<HajjDay> onOpen;

  /// Short names that fit under an icon.
  static const Map<int, String> _short = {
    1: 'التروية',
    2: 'عرفة',
    3: 'مزدلفة',
    4: 'يوم النحر',
    5: 'التشريق',
    6: 'الوداع',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: context.insets.sm + 2.w,
      crossAxisSpacing: context.insets.sm + 2.w,
      childAspectRatio: 0.82,
      children: [
        for (final day in HajjDaysData.all)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(context.corners.lg),
              onTap: () => onOpen(day),
              child: Container(
                padding: EdgeInsets.all(context.insets.sm),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(context.corners.lg),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.18),
                  ),
                  boxShadow: context.shadows.low,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 46.w,
                          height: 46.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: AppIcon(
                              day.icon,
                              size: 24.w,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          top: -4.h,
                          end: -4.w,
                          child: Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.secondary,
                            ),
                            child: Center(
                              child: Text(
                                AppDigits.of(day.number),
                                style: context.textStyles.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Fixed sizes: the cell is a fixed shape, so it must not
                    // grow with the reading size.
                    Text(
                      _short[day.number] ?? day.title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        height: 1.4,
                      ),
                    ),
                    Text(
                      day.dayLabel,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 10.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
