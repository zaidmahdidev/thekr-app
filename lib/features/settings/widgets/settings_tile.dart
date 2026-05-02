import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.corners.lg),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.insets.md,
          vertical: context.insets.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(context.corners.md),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: context.insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: (context.textStyles.bodyLarge ?? const TextStyle())
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                          fontSize: 13.sp,
                        ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: (context.textStyles.bodySmall ?? const TextStyle())
                          .copyWith(
                            color: context.colors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                            fontWeight: onTap != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 11.sp,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 16.sp,
                    color: context.colors.textSecondary.withValues(alpha: 0.4),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
