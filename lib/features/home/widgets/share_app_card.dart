import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';

class ShareAppCard extends StatelessWidget {
  const ShareAppCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      // padding: EdgeInsets.symmetric(
      //   horizontal: context.insets.md,
      //   vertical: context.insets.sm,
      // ),
      child: Container(
        margin: EdgeInsets.all(context.insets.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.colors.primary,
              context.colors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(context.corners.xl),
          boxShadow: context.shadows.medium,
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.only(
                  bottomLeft: Radius.circular(context.corners.xl),
                  topLeft: Radius.circular(context.corners.xl),
                ),
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(AppAssets.bg, width: 95.h),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.insets.md,
                vertical: context.insets.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(context.insets.sm),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            context.corners.md,
                          ),
                        ),
                        child: Icon(
                          Icons.volunteer_activism,
                          color: context.colors.secondary,
                        ),
                      ),
                      SizedBox(width: context.insets.sm),
                      Text(
                        'الدال على الخير كفاعله',
                        style: context.textStyles.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.insets.md),
                  Text(
                    'ساهم في نشر التطبيق ليكون صدقة جارية لك ولنا إن شاء الله.',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  SizedBox(height: context.insets.sm),
                  ElevatedButton.icon(
                    onPressed: () {
                      Share.share(AppConstants.shareMessage);
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('مشاركة التطبيق الآن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: context.colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.corners.md),
                      ),
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
