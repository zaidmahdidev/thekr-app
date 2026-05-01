import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/core/services/share_service.dart';

class AppShareSheet extends StatelessWidget {
  const AppShareSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.corners.xl),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -50,
            left: -50,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(AppAssets.bg, width: 250.w),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(context.insets.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: context.insets.lg),
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(context.corners.sm),
                  ),
                ),

                Text(
                  'مشاركة التطبيق',
                  style: context.textStyles.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: context.insets.lg),

                // Static QR Code Container
                Container(
                  padding: EdgeInsets.all(context.insets.md),
                  decoration: BoxDecoration(
                    color: context.colors.background,
                    borderRadius: BorderRadius.circular(context.corners.xl),
                    boxShadow: context.shadows.medium,
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(context.corners.md),
                        child: Image.asset(
                          AppAssets.qrCode,
                          width: 160.w,
                          height: 160.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: context.insets.sm),
                      Text(
                        'امسح الكود لتحميل التطبيق',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.insets.lg),

                Text(
                  'انسخ الرابط أو شاركه مباشرة عبر تطبيقات التواصل الاجتماعي لنشر الخير',
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: context.insets.lg),

                // Copy Link Row
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(text: AppConstants.playStoreUrl),
                    );
                    Navigator.pop(context);
                    showToast(text: 'تم نسخ رابط التطبيق');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 20.w,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(context.corners.lg),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          size: 16.sp,
                          color: context.colors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'نسخ الرابط',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: context.insets.md),

                // Share App Button - Premium Styled
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ShareService.shareAsText(
                          context,
                          AppConstants.appName,
                          AppConstants.shareMessage,
                        );
                      },
                      icon: const Icon(
                        Icons.share_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        'مشاركة التطبيق الآن',
                        style: context.textStyles.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.corners.lg,
                          ),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
