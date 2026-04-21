import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/features/asma_allah/data/asma_allah_data.dart';

class AsmaAllahGridItem extends StatelessWidget {
  final AsmaAllah item;

  const AsmaAllahGridItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.corners.md),
        side: BorderSide(color: context.colors.primary.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.corners.md),
        onTap: () => _showMeaningDialog(context),
        child: Center(
          child: Text(
            item.name,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
              fontFamily: 'hafs',
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  void _showMeaningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.corners.xl),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.insets.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name,
                style: AppTypography.h2.copyWith(
                  color: context.colors.secondary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'hafs',
                  fontSize: 24.sp,
                ),
              ),
              SizedBox(height: context.insets.md),
              Text(
                item.meaning,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  height: 1.5,
                  color: context.colors.textPrimary,
                ),
              ),
              SizedBox(height: context.insets.lg),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إغلاق',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
