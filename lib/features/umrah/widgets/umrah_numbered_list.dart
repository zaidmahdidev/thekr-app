import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import '../providers/umrah_text.dart';
import 'package:thekr_app/core/utils/app_digits.dart';

/// Instructions in order, each with its number in a circle. Plain reading:
/// nothing to tap, so the page stays calm for every age.
class UmrahNumberedList extends ConsumerWidget {
  const UmrahNumberedList({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.12)),
        boxShadow: context.shadows.low,
      ),
      child: Column(
        children: [
          for (final (index, item) in items.indexed)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : context.insets.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30.w,
                    height: 30.w,
                    margin: EdgeInsets.only(top: 4.h),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Text(
                        AppDigits.of(index + 1),
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.insets.sm + 4.w),
                  Expanded(child: Text(item, style: text.body(context))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
