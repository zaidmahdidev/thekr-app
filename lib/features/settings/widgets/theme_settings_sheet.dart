import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/design_tokens.dart';
import 'package:thekr_app/core/widgets/app_button.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

class ThemeSettingsSheet extends ConsumerWidget {
  const ThemeSettingsSheet({super.key});

  Color _getPrimaryColor(AppThemeType type, bool isDark) {
    switch (type) {
      case AppThemeType.defaultTheme:
        return isDark ? AppColors.dark.primary : AppColors.light.primary;
      case AppThemeType.desert:
        return isDark
            ? AppColors.desertDark.primary
            : AppColors.desertLight.primary;
      case AppThemeType.forest:
        return isDark
            ? AppColors.forestDark.primary
            : AppColors.forestLight.primary;
    }
  }

  Color _getSecondaryColor(AppThemeType type, bool isDark) {
    switch (type) {
      case AppThemeType.defaultTheme:
        return isDark ? AppColors.dark.secondary : AppColors.light.secondary;
      case AppThemeType.desert:
        return isDark
            ? AppColors.desertDark.secondary
            : AppColors.desertLight.secondary;
      case AppThemeType.forest:
        return isDark
            ? AppColors.forestDark.secondary
            : AppColors.forestLight.secondary;
    }
  }

  String _getThemeTitle(AppThemeType type) {
    switch (type) {
      case AppThemeType.defaultTheme:
        return 'الزمردي (الافتراضي)';
      case AppThemeType.desert:
        return 'الصحراوي الدافئ';
      case AppThemeType.forest:
        return 'الزيتي الهادئ';
    }
  }

  String _getThemeDescription(AppThemeType type) {
    switch (type) {
      case AppThemeType.defaultTheme:
        return 'أناقة الزمرد مع لمسات ذهبية مشرقة';
      case AppThemeType.desert:
        return 'دفء ألوان الصحراء والرمال الذهبية';
      case AppThemeType.forest:
        return 'سكينة الطبيعة بدرجات الزيتي والزيتوني';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(
      settingsProvider.select((s) => s.appTheme),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.corners.xl),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.insets.lg,
        vertical: context.insets.md,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.colors.textSecondary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(context.corners.sm),
                ),
              ),
            ),
            SizedBox(height: context.insets.md),

            // Header
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: context.colors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(context.corners.md),
                  ),
                  child: Center(
                    child: AppIcon(
                      HugeIcons.strokeRoundedPalette,
                      color: context.colors.secondary,
                      size: 18.sp,
                    ),
                  ),
                ),
                SizedBox(width: context.insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ألوان التطبيق',
                        style: (context.textStyles.bodyLarge ??
                                const TextStyle())
                            .copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        'اختر الطابع اللوني المفضل لواجهة التطبيق',
                        style: (context.textStyles.bodySmall ??
                                const TextStyle())
                            .copyWith(
                          color: context.colors.textSecondary,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.insets.lg),

            // Theme Options List
            ...AppThemeType.values.map((theme) {
              final isSelected = currentTheme == theme;
              final primary = _getPrimaryColor(theme, isDark);
              final secondary = _getSecondaryColor(theme, isDark);

              return Padding(
                padding: EdgeInsets.only(bottom: context.insets.sm),
                child: InkWell(
                  onTap: () {
                    ref.read(settingsProvider.notifier).updateAppTheme(theme);
                  },
                  borderRadius: BorderRadius.circular(context.corners.lg),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.insets.md,
                      vertical: context.insets.md,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.primary.withValues(alpha: 0.06)
                          : context.colors.background,
                      borderRadius: BorderRadius.circular(context.corners.lg),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.textSecondary.withValues(alpha: 0.12),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: context.colors.primary.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Dual color circles
                        SizedBox(
                          width: 38.w,
                          height: 28.h,
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Positioned(
                                right: 0,
                                child: Container(
                                  width: 26.w,
                                  height: 26.w,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primary.withValues(alpha: 0.35),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 14.w,
                                child: Container(
                                  width: 20.w,
                                  height: 20.w,
                                  decoration: BoxDecoration(
                                    color: secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.colors.surface,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: secondary.withValues(alpha: 0.3),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: context.insets.md),

                        // Title & Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getThemeTitle(theme),
                                style: (context.textStyles.bodyMedium ??
                                        const TextStyle())
                                    .copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? context.colors.primary
                                      : context.colors.textPrimary,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                _getThemeDescription(theme),
                                style: (context.textStyles.bodySmall ??
                                        const TextStyle())
                                    .copyWith(
                                  color: context.colors.textSecondary,
                                  fontSize: 10.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Selection indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? context.colors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? context.colors.primary
                                  : context.colors.textSecondary
                                      .withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: AppIcon(
                                    HugeIcons.strokeRoundedTick02,
                                    color: context.colors.surface,
                                    size: 13.sp,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
           
            SizedBox(height: context.insets.lg),

            // Done Button
            AppButton(
              text: 'إغلاق',
              variant: AppButtonVariant.primary,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
