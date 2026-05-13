import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/theme_extension.dart';

class ProphetVerseCard extends StatelessWidget {
  final String verse;
  final VoidCallback onCopy;
  final double fontSize;

  const ProphetVerseCard({
    super.key,
    required this.verse,
    required this.onCopy,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: context.insets.sm),
      padding: EdgeInsets.all(context.insets.sm),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(context.corners.md),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: onCopy,
              child: Icon(
                Icons.copy_rounded,
                size: 20.w,
                color: context.colors.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            verse,
            textAlign: TextAlign.center,
            style: context.textStyles.bodyLarge?.copyWith(
              color: context.colors.primary,
              fontSize: fontSize.sp - 2.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
