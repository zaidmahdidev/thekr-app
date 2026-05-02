import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/theme_extension.dart';

class ProphetLessonItem extends StatelessWidget {
  final String lesson;
  final double fontSize;
  const ProphetLessonItem({super.key, required this.lesson, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.insets.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Icon(
              Icons.circle,
              size: 6.r,
              color: context.colors.secondary,
            ),
          ),
          SizedBox(width: context.insets.md),
          Expanded(
            child: Text(
              lesson,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.textPrimary,
                height: 1.5,
                fontSize: fontSize.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
