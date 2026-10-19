import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/widgets/brand_surface.dart';
import 'package:thekr_app/features/settings/widgets/app_share_sheet.dart';
import 'package:thekr_app/core/utils/constants/app_icons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Slim home banner that invites the user to share the app (sadaqah jariyah).
/// The whole banner is tappable. Colors adapt to light / dark mode.
class ShareAppCard extends StatelessWidget {
  const ShareAppCard({super.key});

  void _openShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AppShareSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = BrandSurfaceStyle.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.insets.md,
          context.insets.sm,
          context.insets.md,
          context.insets.lg,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(context.corners.xl),
            onTap: () => _openShareSheet(context),
            child: BrandSurface(
              padding: EdgeInsets.symmetric(
                horizontal: context.insets.md,
                vertical: context.insets.sm + 4.h,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(context.corners.lg),
                      border: Border.all(
                        color: style.gold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(context.corners.md),
                      child: Image.asset(
                        AppAssets.logo,
                        width: 36.w,
                        height: 36.w,
                      ),
                    ),
                  ),
                  SizedBox(width: context.insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'الدال على الخير كفاعله',
                          style: context.textStyles.titleSmall?.copyWith(
                            color: style.text,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'شارك التطبيق ليكون صدقة جارية لك ولنا',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.labelMedium?.copyWith(
                            color: style.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.insets.sm),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.insets.md,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: style.ctaBackground,
                      borderRadius: BorderRadius.circular(context.corners.xl),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          AppIcons.share,
                          size: 15.sp,
                          color: style.ctaForeground,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'شارك',
                          style: context.textStyles.labelLarge?.copyWith(
                            color: style.ctaForeground,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
