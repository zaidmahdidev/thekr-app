import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_button.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Explains which place the times are for and offers to turn the location on.
class PrayerLocationNotice extends StatelessWidget {
  const PrayerLocationNotice({
    super.key,
    required this.isDefaultLocation,
    required this.onRequestLocation,
  });

  /// True when no location is known, so there are no times to show.
  final bool isDefaultLocation;
  final VoidCallback onRequestLocation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final message = isDefaultLocation
        ? 'موقعك غير محدد بعد، فعّل الموقع لتظهر أوقات مدينتك.'
        : 'خدمة الموقع غير مفعّلة، والأوقات حسب آخر موقع محفوظ في جهازك.';

    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIcon(
                HugeIcons.strokeRoundedLocation01,
                color: colors.secondary,
                size: 26.sp,
              ),
              SizedBox(width: context.insets.sm),
              Expanded(
                child: Text(
                  message,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.insets.sm),
          AppButton(
            text: 'تفعيل الموقع',
            icon: HugeIcons.strokeRoundedLocation01,
            size: AppButtonSize.small,
            isFullWidth: false,
            onTap: onRequestLocation,
          ),
        ],
      ),
    );
  }
}
