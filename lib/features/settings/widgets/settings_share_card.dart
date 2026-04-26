import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';

class SettingsShareCard extends StatelessWidget {
  const SettingsShareCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.insets.lg),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(context.corners.xl),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              AppAssets.logo,
              width: 40.w,
              height: 40.w,
            ),
          ),
          SizedBox(width: context.insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شارك التطبيق',
                  style: AppTypography.h3.copyWith(color: Colors.white),
                ),
                Text(
                  'ساهم في نشر الخير بين أحبائك',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Share.share(
                'حمل تطبيق "ذكر" - صدقة جارية\nتطبيق شامل للمصحف الشريف والأذكار والتسبيح\nhttps://play.google.com/store/apps/details?id=com.zaid.thekr_app',
              );
            },
            icon: Icon(
              Icons.share_rounded,
              color: Colors.white,
              size: 28.r,
            ),
          ),
        ],
      ),
    );
  }
}
