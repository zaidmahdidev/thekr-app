import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import '../providers/umrah_text.dart';

/// Reminder that the guide summarises the rulings and does not replace asking
/// a scholar. Shown at the bottom of the screens that state rulings.
class UmrahDisclaimer extends ConsumerWidget {
  const UmrahDisclaimer({
    super.key,
    this.text =
        'المحتوى ملخّص من القرآن والسنة وإرشادات وزارة الحج والعمرة وفتاوى '
        'أهل العلم. وللمسائل الخاصة بحالتك راجع أهل العلم الثقات.',
  });

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.watch(umrahTextProvider);
    final color = context.colors.secondary;
    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: AppIcon(
              HugeIcons.strokeRoundedInformationCircle,
              size: 20.w,
              color: color,
            ),
          ),
          SizedBox(width: context.insets.sm),
          Expanded(
            child: Text(
              text,
              style: styles.small(
                context,
                color: context.colors.textPrimary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
