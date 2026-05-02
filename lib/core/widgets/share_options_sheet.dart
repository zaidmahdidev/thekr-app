import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_bottom_sheet.dart';

class ShareOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  ShareOption({required this.icon, required this.label, required this.onTap});

  factory ShareOption.text({required VoidCallback onTap}) {
    return ShareOption(
      icon: Icons.text_fields_rounded,
      label: 'مشاركة كنص',
      onTap: onTap,
    );
  }

  factory ShareOption.image({required VoidCallback onTap}) {
    return ShareOption(
      icon: Icons.image_outlined,
      label: 'مشاركة كصورة',
      onTap: onTap,
    );
  }
}

class ShareOptionsSheet extends StatelessWidget {
  final List<ShareOption> options;

  const ShareOptionsSheet({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < options.length; i++) ...[
          _buildOption(context, options[i]),
          if (i < options.length - 1)
            Divider(
              height: 1,
              thickness: 0.5,
              color: context.colors.textSecondary.withValues(alpha: 0.05),
            ),
        ],
        SizedBox(height: context.insets.sm),
      ],
    );
  }

  Widget _buildOption(BuildContext context, ShareOption option) {
    final isText = option.icon == Icons.text_fields_rounded;
    final color = isText ? Colors.blue : Colors.amber;
    final subtitle = isText
        ? 'نسخ النص أو مشاركته مباشرة'
        : 'توليد صورة احترافية';

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        option.onTap();
      },
      borderRadius: BorderRadius.circular(context.corners.md),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: context.insets.md,
          horizontal: context.insets.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(context.corners.md),
              ),
              child: Icon(option.icon, color: color, size: 22.sp),
            ),
            SizedBox(width: context.insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: context.textStyles.bodyLarge?.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: context.colors.textSecondary.withValues(alpha: 0.2),
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required List<ShareOption> options,
    String title = 'خيارات المشاركة',
  }) {
    return AppBottomSheet.show(
      context: context,
      title: title,
      child: ShareOptionsSheet(options: options),
    );
  }
}
