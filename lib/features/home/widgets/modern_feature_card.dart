import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModernFeatureCard extends StatelessWidget {
  const ModernFeatureCard({
    super.key,
    required this.title,
    required this.imgUrl,
    required this.onTap,
    this.color,
  });

  final String title;
  final String imgUrl;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.corners.xl),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(context.corners.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.05),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [context.colors.surface, context.colors.background],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.insets.sm * 1.5),
              decoration: BoxDecoration(
                color: (color ?? context.colors.secondary).withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                imgUrl,
                width: 35.w,
                height: 35.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.insets.sm),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
