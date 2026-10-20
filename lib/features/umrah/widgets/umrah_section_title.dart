import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

/// Heading with the gold accent bar used across the app's list screens.
class UmrahSectionTitle extends StatelessWidget {
  const UmrahSectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: context.colors.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: context.insets.sm),
        Expanded(
          child: Text(
            title,
            style: context.textStyles.titleLarge?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
