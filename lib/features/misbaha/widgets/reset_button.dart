import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

class MinimalistResetButton extends StatelessWidget {
  final VoidCallback onReset;
  const MinimalistResetButton({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onReset,
      borderRadius: BorderRadius.circular(context.corners.rc360),
      child: Container(
        padding: EdgeInsets.all(context.insets.md),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.secondary.withValues(alpha: 0.1),
          border: Border.all(color: context.colors.secondary.withValues(alpha: 0.2)),
        ),
        child: Icon(
          Icons.refresh_rounded,
          color: context.colors.secondary,
          size: 24.w,
        ),
      ),
    );
  }
}
