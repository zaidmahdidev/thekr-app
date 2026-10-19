import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/settings/models/share_card_style.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Format tab: image shape, text size and the app signature.
class ShareFormatPanel extends StatelessWidget {
  const ShareFormatPanel({
    super.key,
    required this.style,
    required this.onRatioChanged,
    required this.onFontScaleChanged,
    required this.onSignatureChanged,
  });

  final ShareCardStyle style;
  final ValueChanged<ShareCardRatio> onRatioChanged;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<bool> onSignatureChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('شكل الصورة'),
        SizedBox(height: context.insets.sm),
        Row(
          children: [
            for (final ratio in ShareCardRatio.values)
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: ratio == ShareCardRatio.values.last
                        ? 0
                        : context.insets.sm,
                  ),
                  child: _RatioTile(
                    ratio: ratio,
                    selected: ratio == style.ratio,
                    onTap: () => onRatioChanged(ratio),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: context.insets.md),
        _SectionLabel('حجم الخط'),
        Row(
          children: [
            AppIcon(
              HugeIcons.strokeRoundedZoomOut,
              size: 18.sp,
              color: context.colors.textSecondary,
            ),
            Expanded(
              child: Slider.adaptive(
                value: style.fontScale.clamp(0.7, 1.4),
                min: 0.7,
                max: 1.4,
                divisions: 7,
                activeColor: context.colors.primary,
                onChanged: onFontScaleChanged,
              ),
            ),
            AppIcon(
              HugeIcons.strokeRoundedZoomIn,
              size: 18.sp,
              color: context.colors.textSecondary,
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                'إظهار توقيع التطبيق',
                style: context.textStyles.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Switch.adaptive(
              value: style.showSignature,
              activeThumbColor: context.colors.primary,
              onChanged: onSignatureChanged,
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textStyles.labelLarge?.copyWith(
        color: context.colors.textSecondary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _RatioTile extends StatelessWidget {
  const _RatioTile({
    required this.ratio,
    required this.selected,
    required this.onTap,
  });

  final ShareCardRatio ratio;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colors.primary
        : context.colors.textSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: context.insets.sm + 2.h),
        decoration: BoxDecoration(
          color: selected
              ? context.colors.primary.withValues(alpha: 0.1)
              : context.colors.background,
          borderRadius: BorderRadius.circular(context.corners.lg),
          border: Border.all(
            color: selected
                ? context.colors.primary
                : context.colors.primary.withValues(alpha: 0.12),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            AppIcon(ratio.icon, size: 22.sp, color: color),
            SizedBox(height: 4.h),
            Text(
              ratio.label,
              style: context.textStyles.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ratio.hint,
              style: context.textStyles.labelSmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
