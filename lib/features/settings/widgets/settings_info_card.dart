import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';

class SettingsInfoCard extends StatelessWidget {
  const SettingsInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: context.colors.primary,
            size: 22.r,
          ),
          SizedBox(width: context.insets.md),
          Expanded(
            child: Text(
              'سيتم تذكيرك يومياً بذكر الله في الأوقات التي تختارها.',
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
