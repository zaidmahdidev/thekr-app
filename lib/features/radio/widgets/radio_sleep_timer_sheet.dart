import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_bottom_sheet.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Lets the user pick when the radio should fade out and stop on its own.
/// Pops with the chosen [Duration], or [Duration.zero] to cancel the timer.
class RadioSleepTimerSheet extends StatelessWidget {
  const RadioSleepTimerSheet({super.key, required this.timerActive});

  final bool timerActive;

  static const List<int> _minutes = [15, 30, 45, 60, 90, 120];

  static Future<Duration?> show(
    BuildContext context, {
    required bool timerActive,
  }) {
    return AppBottomSheet.show<Duration>(
      context: context,
      title: 'مؤقت النوم',
      child: RadioSleepTimerSheet(timerActive: timerActive),
    );
  }

  static String _label(int minutes) {
    if (minutes < 60) return '$minutes دقيقة';
    if (minutes == 60) return 'ساعة';
    if (minutes == 120) return 'ساعتان';
    return 'ساعة ونصف';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'يتوقف البث تدريجياً بعد المدة التي تختارها.',
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: context.insets.md),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: context.insets.sm,
          runSpacing: context.insets.sm,
          children: [
            for (final minutes in _minutes)
              ActionChip(
                avatar: AppIcon(
                  HugeIcons.strokeRoundedTimer02,
                  size: 18.w,
                  color: context.colors.primary,
                ),
                label: Text(_label(minutes)),
                labelStyle: context.textStyles.bodyMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: context.colors.primary.withValues(alpha: 0.08),
                side: BorderSide(
                  color: context.colors.primary.withValues(alpha: 0.25),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.corners.xl),
                ),
                onPressed: () =>
                    Navigator.of(context).pop(Duration(minutes: minutes)),
              ),
          ],
        ),
        if (timerActive) ...[
          SizedBox(height: context.insets.md),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(Duration.zero),
            icon: AppIcon(
              HugeIcons.strokeRoundedCancel01,
              size: 18.w,
              color: context.colors.error,
            ),
            label: const Text('إلغاء المؤقت'),
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
          ),
        ],
      ],
    );
  }
}
