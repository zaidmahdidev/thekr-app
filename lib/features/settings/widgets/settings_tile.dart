import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final AppIconData icon;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Makes the tile a switch row: tapping anywhere on the row toggles it, not
  /// only the switch itself.
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  /// Optional value shown next to an enabled switch (for example a time).
  /// Tapping it runs [onValueTap] instead of toggling the switch.
  final String? switchValueLabel;
  final VoidCallback? onValueTap;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trailing,
    this.onTap,
    this.switchValue,
    this.onSwitchChanged,
    this.switchValueLabel,
    this.onValueTap,
  });

  bool get _isSwitch => switchValue != null && onSwitchChanged != null;

  @override
  Widget build(BuildContext context) {
    final tapHandler = _isSwitch
        ? () => onSwitchChanged!(!switchValue!)
        : onTap;

    return InkWell(
      onTap: tapHandler,
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
              child: AppIcon(icon, color: iconColor, size: 20.sp),
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
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
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
                            fontWeight: tapHandler != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (_isSwitch)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (switchValue! && switchValueLabel != null) ...[
                    InkWell(
                      onTap: onValueTap,
                      borderRadius: BorderRadius.circular(context.corners.md),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(context.corners.md),
                        ),
                        child: Text(
                          switchValueLabel!,
                          style: (context.textStyles.bodySmall ??
                                  const TextStyle())
                              .copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.insets.sm),
                  ],
                  Switch.adaptive(
                    value: switchValue!,
                    activeThumbColor: context.colors.primary,
                    activeTrackColor:
                        context.colors.primary.withValues(alpha: 0.5),
                    onChanged: onSwitchChanged,
                  ),
                ],
              )
            else
              trailing ??
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    HugeIcons.strokeRoundedArrowRight01,
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
