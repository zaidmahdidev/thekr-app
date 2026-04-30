import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_bottom_sheet.dart';

class ShareOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  ShareOption({required this.icon, required this.label, required this.onTap});
}

class ShareOptionsSheet extends StatelessWidget {
  final List<ShareOption> options;

  const ShareOptionsSheet({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.insets.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options
            .map((option) => _buildOption(context, option))
            .toList(),
      ),
    );
  }

  Widget _buildOption(BuildContext context, ShareOption option) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        option.onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Icon(
              option.icon,
              color: context.colors.primary,
              size: 28.sp,
            ),
          ),
          SizedBox(height: context.insets.sm),
          Text(
            option.label,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
