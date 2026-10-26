import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_button.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Shown under the times only when something was changed from the defaults, so
/// the way back is in sight as soon as the user needs it.
class PrayerCalcResetBar extends StatelessWidget {
  const PrayerCalcResetBar({super.key, required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: EdgeInsets.only(top: context.insets.sm),
      padding: EdgeInsets.symmetric(
        horizontal: context.insets.md,
        vertical: context.insets.sm,
      ),
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.corners.lg),
      ),
      child: Row(
        children: [
          AppIcon(
            HugeIcons.strokeRoundedSettings02,
            size: 20.sp,
            color: colors.secondary,
          ),
          SizedBox(width: context.insets.sm),
          Expanded(
            child: Text(
              'إعدادات مخصّصة',
              style: (context.textStyles.bodyMedium ?? const TextStyle())
                  .copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
            ),
          ),
          AppButton(
            text: 'إعادة الضبط',
            size: AppButtonSize.small,
            variant: AppButtonVariant.outline,
            isFullWidth: false,
            onTap: onReset,
          ),
        ],
      ),
    );
  }
}
