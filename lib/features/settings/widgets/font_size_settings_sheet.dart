import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_button.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

class FontSizeSettingsSheet extends ConsumerWidget {
  const FontSizeSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(settingsProvider.select((s) => s.fontSize));

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
          children: [
            // Drag handle
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.colors.textSecondary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(context.corners.sm),
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
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.corners.md),
                  ),
                  child: AppIcon(
                    HugeIcons.strokeRoundedTextFont,
                    color: context.colors.primary,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: context.insets.md),
                Text(
                  'حجم الخط في القراءة',
                  style: (context.textStyles.bodyLarge ?? const TextStyle())
                      .copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(context.corners.sm),
                  ),
                  child: Text(
                    '${fontSize.toInt()} نقطة',
                    style: (context.textStyles.bodySmall ?? const TextStyle())
                        .copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.insets.lg),
            // Live Preview Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.insets.md),
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(context.corners.lg),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  textAlign: TextAlign.center,
                  style: (context.textStyles.bodyLarge ?? const TextStyle())
                      .copyWith(
                        fontSize: fontSize.sp,
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                  child: const Text(
                    '« سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ »',
                  ),
                ),
              ),
            ),
            SizedBox(height: context.insets.md),
            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: context.colors.primary,
                inactiveTrackColor:
                    context.colors.primary.withValues(alpha: 0.15),
                thumbColor: context.colors.primary,
                overlayColor: context.colors.primary.withValues(alpha: 0.12),
                trackHeight: 4.h,
              ),
              child: Slider.adaptive(
                value: fontSize.clamp(14.0, 24.0),
                min: 14.0,
                max: 24.0,
                divisions: 5,
                onChanged: (val) =>
                    ref.read(settingsProvider.notifier).updateFontSize(val),
              ),
            ),
            SizedBox(height: context.insets.sm),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'الافتراضي (16)',
                    variant: AppButtonVariant.secondary,
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .updateFontSize(16.0),
                  ),
                ),
                SizedBox(width: context.insets.md),
                Expanded(
                  child: AppButton(
                    text: 'تم',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.insets.sm),
          ],
        ),
      ),
    );
  }
}
