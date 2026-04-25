import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/tokens/typography.dart';

class ProphetSectionHeader extends StatelessWidget {
  final String title;
  const ProphetSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.insets.md,
        top: context.insets.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: context.colors.secondary,
              borderRadius: BorderRadius.circular(context.corners.sm),
            ),
          ),
          SizedBox(width: context.insets.sm),
          Text(
            title,
            style: AppTypography.h3.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class ProphetSectionTitle extends StatelessWidget {
  final String title;
  final bool isHero;
  const ProphetSectionTitle({super.key, required this.title, this.isHero = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.insets.sm),
      child: Text(
        title,
        style: (isHero ? AppTypography.h2 : AppTypography.h3).copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
