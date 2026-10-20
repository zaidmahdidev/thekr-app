import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

/// Pill-shaped switch between a few options, used where a tab bar would be
/// too heavy.
class UmrahSegmentedControl<T> extends StatelessWidget {
  const UmrahSegmentedControl({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (value == selected) return;
                  HapticFeedback.selectionClick();
                  onChanged(value);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.symmetric(vertical: 11.h),
                  decoration: BoxDecoration(
                    color: value == selected
                        ? colors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(context.corners.xl),
                  ),
                  child: Text(
                    labelOf(value),
                    textAlign: TextAlign.center,
                    style: context.textStyles.titleSmall?.copyWith(
                      color: value == selected
                          ? Colors.white
                          : colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
