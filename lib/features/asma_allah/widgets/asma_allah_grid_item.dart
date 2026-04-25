import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/features/asma_allah/data/asma_allah_data.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/services/share_service.dart';

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
        onTap: () => _showMeaningBottomSheet(context),
        child: Center(
          child: Text(
            item.name,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'hafs',
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  void _showMeaningBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.corners.xl),
            topRight: Radius.circular(context.corners.xl),
          ),
          boxShadow: context.shadows.medium,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.insets.md,
              context.insets.md,
              context.insets.md,
              context.insets.sm, // Smaller bottom padding as SafeArea handles the rest
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Bar
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: context.insets.sm),
                Text(
                  item.name,
                  style: AppTypography.h1.copyWith(
                    color: context.colors.primary,
                    fontFamily: 'hafs',
                    fontSize: 25.sp,
                  ),
                ),
                SizedBox(height: context.insets.sm),
                // Meaning Text
                Text(
                  item.meaning,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    height: 1.6,
                    color: context.colors.textPrimary,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: context.insets.xl),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ShareService.showShareSheet(
                            context,
                            content: item.name,
                            subtitle: item.meaning,
                          );
                        },
                        icon: Icon(Icons.share_outlined, size: 20.w),
                        label: const Text('مشاركة'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.primary,
                          side: BorderSide(
                            color: context.colors.primary.withValues(alpha: 0.2),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.corners.md),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.insets.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.check_circle_outline, size: 20.w),
                        label: const Text('فهمت'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.corners.md),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.insets.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
