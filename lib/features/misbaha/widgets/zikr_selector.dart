import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import '../models/misbaha_models.dart';

class OrnamentalZikrSelector extends StatelessWidget {
  final MisbahaZikr currentZikr;
  final Function(MisbahaZikr) onChanged;

  const OrnamentalZikrSelector({
    super.key,
    required this.currentZikr,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.insets.md,
        vertical: context.insets.sm / 2,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: context.colors.secondary.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MisbahaZikr>(
          value: currentZikr,
          dropdownColor: context.colors.surface,
          icon: Icon(
            Icons.expand_more_rounded,
            color: context.colors.secondary,
            size: 18.w,
          ),
          items: MisbahaZikr.values.map((zikr) {
            return DropdownMenuItem(
              value: zikr,
              child: Text(
                zikr.label,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
            );
          }).toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}
