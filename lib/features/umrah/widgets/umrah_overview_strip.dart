import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import '../data/umrah_steps_data.dart';
import '../models/umrah_models.dart';
import 'package:thekr_app/core/utils/app_digits.dart';

/// The whole Umrah on one glance: the six rites in order, each opening its
/// lesson. A map of what is coming before reading the details.
class UmrahOverviewStrip extends StatelessWidget {
  const UmrahOverviewStrip({super.key, required this.onOpen});

  final ValueChanged<UmrahStep> onOpen;

  /// Short names that fit under an icon.
  static const Map<int, String> _short = {
    1: 'الإحرام',
    2: 'دخول الحرم',
    3: 'الطواف',
    4: 'ركعتا الطواف',
    5: 'السعي',
    6: 'التقصير',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final steps = UmrahStepsData.all;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: context.insets.sm + 2.w,
      crossAxisSpacing: context.insets.sm + 2.w,
      childAspectRatio: 0.95,
      children: [
        for (final step in steps)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(context.corners.lg),
              onTap: () => onOpen(step),
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
                              step.icon,
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
                                AppDigits.of(step.number),
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
                    Text(
                      _short[step.number] ?? step.title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      // Fixed size: the cell is a fixed shape, so it must not grow
                      // with the reading size.
                      style: context.textStyles.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        height: 1.4,
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
