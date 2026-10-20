import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import '../../providers/umrah_text.dart';

/// Card that frames an illustration: a title, the drawing, an info panel that
/// explains whatever was tapped, and a note that the drawing is schematic.
class UmrahIllustrationFrame extends ConsumerWidget {
  const UmrahIllustrationFrame({
    super.key,
    required this.title,
    required this.child,
    this.infoTitle,
    this.infoBody,
    this.hint = 'اضغط على أي علامة في الرسم لتعرف معناها.',
    this.footer,
  });

  final String title;
  final Widget child;

  /// What the user tapped; when null the [hint] is shown instead.
  final String? infoTitle;
  final String? infoBody;
  final String hint;

  /// Controls under the drawing, such as a play button.
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
        boxShadow: context.shadows.low,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.title(context, color: colors.primary)),
          SizedBox(height: context.insets.sm),
          child,
          if (footer != null) ...[
            SizedBox(height: context.insets.sm),
            footer!,
          ],
          SizedBox(height: context.insets.sm),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              child: Container(
                padding: EdgeInsets.all(context.insets.sm + 4.w),
                decoration: BoxDecoration(
                  color: (infoTitle == null ? colors.textSecondary : colors.secondary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.corners.md),
                ),
                child: infoTitle == null
                    ? Text(
                        hint,
                        style: text.small(context, color: colors.textSecondary),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(infoTitle!, style: text.title(context)),
                          if (infoBody != null)
                            Text(infoBody!, style: text.body(context)),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: context.insets.sm),
          Text(
            'رسم توضيحي تقريبي وليس بمقياس رسم.',
            style: text
                .small(context, color: colors.textSecondary)
                .copyWith(fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}
