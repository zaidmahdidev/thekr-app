import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import '../models/umrah_models.dart';
import '../providers/umrah_text.dart';

/// A traveller situation to pick ("coming from Egypt", "by air"...).
class MiqatOriginTile extends ConsumerWidget {
  const MiqatOriginTile({
    super.key,
    required this.origin,
    required this.selected,
    required this.onTap,
  });

  final MiqatOrigin origin;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: context.insets.sm + 2.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.lg),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: EdgeInsets.symmetric(
              horizontal: context.insets.sm + 4.w,
              vertical: context.insets.sm + 4.w,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? colors.primary.withValues(alpha: 0.08)
                  : colors.surface,
              borderRadius: BorderRadius.circular(context.corners.lg),
              border: Border.all(
                color: selected
                    ? colors.primary.withValues(alpha: 0.6)
                    : colors.textSecondary.withValues(alpha: 0.12),
                width: selected ? 1.4 : 1,
              ),
              boxShadow: selected ? null : context.shadows.low,
            ),
            child: Row(
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(
                      alpha: selected ? 0.16 : 0.08,
                    ),
                  ),
                  child: Center(
                    child: AppIcon(
                      origin.icon,
                      size: 24.w,
                      color: colors.primary,
                    ),
                  ),
                ),
                SizedBox(width: context.insets.sm + 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        origin.label,
                        style: text.title(
                          context,
                          color: selected ? colors.primary : colors.textPrimary,
                        ),
                      ),
                      Text(
                        origin.hint,
                        style: text.small(context, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                AppIcon(
                  selected
                      ? HugeIcons.strokeRoundedCheckmarkCircle02
                      : HugeIcons.strokeRoundedArrowRight01,
                  size: 22.w,
                  color: selected
                      ? colors.primary
                      : colors.textSecondary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
