import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// The round icon at the start of the account card.
class AccountBadge extends StatelessWidget {
  const AccountBadge({super.key, required this.icon});

  final AppIconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.corners.md),
      ),
      child: Center(
        child: AppIcon(icon, color: colors.primary, size: 24.sp),
      ),
    );
  }
}
