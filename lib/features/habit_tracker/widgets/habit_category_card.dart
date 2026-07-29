import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

class HabitCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<HabitItemData> items;

  const HabitCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.insets.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.insets.md,
              vertical: context.insets.sm,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.corners.xl),
                topRight: Radius.circular(context.corners.xl),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24.sp),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: context.textStyles.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Items
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.insets.sm),
            child: Column(
              children: items.map((item) => _buildHabitItem(context, item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitItem(BuildContext context, HabitItemData item) {
    return InkWell(
      onTap: item.onToggle,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.insets.md,
          vertical: context.insets.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: item.isDone ? context.colors.textPrimary.withValues(alpha: 0.6) : context.colors.textPrimary,
                  decoration: item.isDone ? TextDecoration.lineThrough : null,
                  fontWeight: item.isDone ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: item.isDone ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isDone ? color : context.colors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: item.isDone
                  ? Icon(Icons.check, color: Colors.white, size: 18.sp)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class HabitItemData {
  final String title;
  final bool isDone;
  final VoidCallback onToggle;

  HabitItemData({
    required this.title,
    required this.isDone,
    required this.onToggle,
  });
}
