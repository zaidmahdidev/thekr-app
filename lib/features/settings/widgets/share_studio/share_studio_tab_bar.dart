import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

class ShareStudioTab {
  final IconData icon;
  final String label;

  const ShareStudioTab({required this.icon, required this.label});
}

/// Pill-shaped segmented control used to switch the studio's editing panel.
class ShareStudioTabBar extends StatelessWidget {
  const ShareStudioTabBar({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });

  final List<ShareStudioTab> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(context.corners.xl),
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(vertical: 9.h),
                  decoration: BoxDecoration(
                    color: i == selected
                        ? context.colors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(context.corners.xl),
                    boxShadow: i == selected ? context.shadows.low : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tabs[i].icon,
                        size: 17.sp,
                        color: i == selected
                            ? context.colors.surface
                            : context.colors.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        tabs[i].label,
                        style: context.textStyles.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: i == selected
                              ? context.colors.surface
                              : context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
