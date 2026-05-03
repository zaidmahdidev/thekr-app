import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

class DeveloperSocialCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DeveloperSocialCard({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.corners.md),
      child: Container(
        padding: EdgeInsets.all(context.insets.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(context.corners.md),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Icon(icon, size: 18.sp, color: color),
      ),
    );
  }
}
