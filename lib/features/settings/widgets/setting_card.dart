import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';

class SettingCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isEnabled;
  final Function(bool) onToggle;
  final TimeOfDay time;
  final VoidCallback onTimeTap;
  final String Function(TimeOfDay) formatTime;

  const SettingCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isEnabled,
    required this.onToggle,
    required this.time,
    required this.onTimeTap,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl), // استخدام Token
        border: Border.all(
          color: isEnabled
              ? context.colors.primary.withValues(alpha: 0.1)
              : context.colors.background.withValues(alpha: 0.1),
        ),
        boxShadow: context.shadows.low, // استخدام Token
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.insets.lg, // استخدام Token
              vertical: context.insets.sm,
            ),
            leading: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.r),
            ),
            title: Text(
              title,
              style: AppTypography.h3.copyWith(
                color: context.colors.textPrimary,
                fontSize: 16.sp,
              ),
            ),
            trailing: Switch.adaptive(
              value: isEnabled,
              onChanged: onToggle,
              activeThumbColor: context.colors.primary,
              activeTrackColor: context.colors.primary.withValues(alpha: 0.3),
            ),
          ),
          if (isEnabled) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.insets.lg,
                0,
                context.insets.lg,
                context.insets.lg,
              ),
              child: InkWell(
                onTap: onTimeTap,
                borderRadius: BorderRadius.circular(context.corners.md),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: context.insets.md,
                    horizontal: context.insets.md,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.background.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(context.corners.md),
                    border: Border.all(
                      color: context.colors.background.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        color: context.colors.primary,
                        size: 20.r,
                      ),
                      SizedBox(width: context.insets.sm),
                      Text(
                        'ضبط الوقت: ',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      Text(
                        formatTime(time),
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.primary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: context.colors.textSecondary,
                        size: 14.r,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
