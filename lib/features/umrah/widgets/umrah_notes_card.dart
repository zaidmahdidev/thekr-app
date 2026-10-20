import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import '../providers/umrah_text.dart';

/// Points the pilgrim should not miss, in a tinted card.
class UmrahNotesCard extends ConsumerWidget {
  const UmrahNotesCard({super.key, required this.notes});

  final List<String> notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final color = context.colors.secondary;
    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          for (final (index, note) in notes.indexed)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == notes.length - 1 ? 0 : context.insets.sm + 2.w,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: AppIcon(
                      HugeIcons.strokeRoundedIdea01,
                      size: 20.w,
                      color: color,
                    ),
                  ),
                  SizedBox(width: context.insets.sm),
                  Expanded(child: Text(note, style: text.body(context))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
