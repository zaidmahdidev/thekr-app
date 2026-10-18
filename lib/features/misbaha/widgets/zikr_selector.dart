import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import '../models/misbaha_models.dart';

/// Pill showing the current dhikr. Tap to choose another one from a sheet that
/// also shows how many times each dhikr was counted.
class OrnamentalZikrSelector extends StatelessWidget {
  final MisbahaZikr currentZikr;
  final Map<MisbahaZikr, int> counts;
  final Function(MisbahaZikr) onChanged;

  const OrnamentalZikrSelector({
    super.key,
    required this.currentZikr,
    required this.counts,
    required this.onChanged,
  });

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ZikrSheet(
        current: currentZikr,
        counts: counts,
        onSelected: (zikr) {
          Navigator.pop(context);
          onChanged(zikr);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(context.corners.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.corners.xl),
        onTap: () => _openSheet(context),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.insets.md,
            vertical: context.insets.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.corners.xl),
            border: Border.all(
              color: context.colors.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  currentZikr.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.expand_more_rounded,
                color: context.colors.secondary,
                size: 20.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZikrSheet extends StatelessWidget {
  const _ZikrSheet({
    required this.current,
    required this.counts,
    required this.onSelected,
  });

  final MisbahaZikr current;
  final Map<MisbahaZikr, int> counts;
  final ValueChanged<MisbahaZikr> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.corners.xl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.insets.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: context.insets.md),
                decoration: BoxDecoration(
                  color: context.colors.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(context.corners.sm),
                ),
              ),
              Text(
                'اختر الذكر',
                style: context.textStyles.titleSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.insets.sm),
              for (final zikr in MisbahaZikr.values)
                _ZikrTile(
                  zikr: zikr,
                  count: counts[zikr] ?? 0,
                  selected: zikr == current,
                  onTap: () => onSelected(zikr),
                ),
              SizedBox(height: context.insets.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZikrTile extends StatelessWidget {
  const _ZikrTile({
    required this.zikr,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final MisbahaZikr zikr;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Material(
        color: selected
            ? context.colors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(context.corners.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.lg),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.insets.md,
              vertical: context.insets.sm + 2.h,
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20.sp,
                  color: selected
                      ? context.colors.primary
                      : context.colors.textSecondary,
                ),
                SizedBox(width: context.insets.md),
                Expanded(
                  child: Text(
                    zikr.label,
                    style: context.textStyles.titleSmall?.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                Text(
                  QuranText.digits(count),
                  style: context.textStyles.labelLarge?.copyWith(
                    color: context.colors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
