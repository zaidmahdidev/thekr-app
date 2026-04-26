import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';

class AppearanceCard extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const AppearanceCard({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.1),
        ),
        boxShadow: context.shadows.low,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.insets.lg,
              context.insets.md,
              context.insets.lg,
              context.insets.xl ?? 4.w,
            ),
            child: Text(
              'المظهر',
              style: AppTypography.label.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: context.insets.lg),
            leading: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: context.colors.primary,
                size: 24.r,
              ),
            ),
            title: Text(
              'الوضع الليلي',
              style: AppTypography.h3.copyWith(
                color: context.colors.textPrimary,
                fontSize: 16.sp,
              ),
            ),
            trailing: Switch.adaptive(
              value: isDarkMode,
              onChanged: onThemeChanged,
              activeThumbColor: context.colors.primary,
              activeTrackColor: context.colors.primary.withValues(alpha: 0.3),
            ),
          ),
          SizedBox(height: context.insets.sm),
        ],
      ),
    );
  }
}
