import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import '../models/umrah_models.dart';
import '../providers/umrah_text.dart';

/// A pillar or obligation with its kind ("ركن" / "واجب") in a small tag.
class UmrahPillarTile extends ConsumerWidget {
  const UmrahPillarTile({required this.pillar});

  final UmrahPillar pillar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;
    final isPillar = pillar.kind == 'ركن';
    final accent = isPillar ? colors.primary : colors.secondary;

    return Container(
      margin: EdgeInsets.only(bottom: context.insets.sm + 2.w),
      padding: EdgeInsets.all(context.insets.sm + 4.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
        boxShadow: context.shadows.low,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.12),
            ),
            child: Center(
              child: AppIcon(pillar.icon, size: 24.w, color: accent),
            ),
          ),
          SizedBox(width: context.insets.sm + 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: context.insets.sm,
                  children: [
                    Text(pillar.title, style: text.title(context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(context.corners.xl),
                      ),
                      child: Text(
                        pillar.kind,
                        style: text
                            .small(context, color: accent)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Text(pillar.meaning, style: text.body(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
