import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// One prayer with a minus and a plus to move it by minutes.
class PrayerAdjustmentRow extends StatelessWidget {
  const PrayerAdjustmentRow({
    super.key,
    required this.name,
    required this.minutes,
    required this.onChanged,
  });

  final String name;

  /// The current adjustment, negative for earlier.
  final int minutes;

  /// Called with +1 or -1.
  final ValueChanged<int> onChanged;

  String get _label {
    if (minutes == 0) return '0';
    return minutes > 0 ? '+$minutes' : '$minutes';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final changed = minutes != 0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.insets.md,
        vertical: context.insets.sm / 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: (context.textStyles.bodyLarge ?? const TextStyle())
                  .copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
            ),
          ),
          _StepButton(
            icon: HugeIcons.strokeRoundedMinusSign,
            tooltip: 'أبكر بدقيقة',
            onTap: () => onChanged(-1),
          ),
          SizedBox(
            width: 52.w,
            child: Text(
              _label,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: (context.textStyles.bodyLarge ?? const TextStyle())
                  .copyWith(
                    fontWeight: FontWeight.bold,
                    color: changed ? colors.primary : colors.textSecondary,
                  ),
            ),
          ),
          _StepButton(
            icon: HugeIcons.strokeRoundedAdd01,
            tooltip: 'أخّر بدقيقة',
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final AppIconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: context.colors.primary.withValues(alpha: 0.1),
      ),
      icon: AppIcon(icon, size: 20.sp, color: context.colors.primary),
    );
  }
}
