import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/hero_pattern.dart';

/// Banner at the top of the guide. It says what the guide is for: learning at
/// home, so the pilgrim can give the rites their full attention.
class UmrahHero extends StatelessWidget {
  const UmrahHero({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final hsl = HSLColor.fromColor(primary);
    final darker = hsl
        .withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0))
        .toColor();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.corners.xl),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [primary, darker],
        ),
        boxShadow: context.shadows.medium,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.corners.xl),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(child: HeroPattern(opacity: 0.18)),
            ),
            Padding(
              padding: EdgeInsets.all(context.insets.md + 2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تعلّم العمرة قبل أن تسافر',
                    style: context.textStyles.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'مرجع مبسّط لكل الأعمار، يشرح المناسك بالترتيب بأدلتها.',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.7,
                    ),
                  ),
                  SizedBox(height: context.insets.md),
                  Container(
                    padding: EdgeInsets.all(context.insets.sm + 4.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(context.corners.lg),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 3.h),
                          child: AppIcon(
                            HugeIcons.strokeRoundedBookOpen01,
                            size: 22.w,
                            color: context.colors.secondary,
                          ),
                        ),
                        SizedBox(width: context.insets.sm),
                        Expanded(
                          child: Text(
                            'اقرأه في بيتك وأنت مرتاح، وأثناء العمرة اترك '
                            'هاتفك في جيبك وتفرّغ للعبادة.',
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: Colors.white,
                              height: 1.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
