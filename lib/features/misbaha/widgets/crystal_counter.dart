import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';

class CrystalCounter extends StatelessWidget {
  final int count;
  const CrystalCounter({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.corners.xl),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 140.w,
          padding: EdgeInsets.symmetric(vertical: context.insets.lg),
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(context.corners.xl),
            border: Border.all(
              color: context.colors.secondary.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _formatNumber(count),
                  style: AppTypography.h1.copyWith(
                    fontSize: 50.sp,
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: context.insets.sm),
              Text(
                'تَسبيحَة',
                style: AppTypography.label.copyWith(
                  color: context.colors.primary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
