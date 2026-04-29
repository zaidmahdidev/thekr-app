import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

class SettingsSection extends StatelessWidget {
  final List<Widget> children;
  const SettingsSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        boxShadow: context.shadows.low,
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Divider(
                  height: 1.h,
                  thickness: 0.5,
                  indent: 60.w,
                  endIndent: context.insets.md,
                  color: context.colors.secondary.withValues(alpha: 0.2),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: context.insets.sm,
        bottom: context.insets.sm,
      ),
      child: Text(
        title,
        style: (context.textStyles.bodyMedium ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.bold,
          color: context.colors.primary,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}
