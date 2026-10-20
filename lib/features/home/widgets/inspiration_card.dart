import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/widgets/brand_surface.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:thekr_app/features/home/models/inspiration_item.dart';
import 'package:thekr_app/features/home/widgets/inspiration_detail_sheet.dart';
import 'package:thekr_app/features/home/widgets/inspiration_reading.dart';
import 'package:thekr_app/core/utils/constants/app_icons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Daily inspiration card with a FIXED size: one font size per type, at most
/// three lines. Longer text is cut with "قراءة المزيد" and opens the full text in
/// a sheet (tap anywhere on the card).
class InspirationCard extends ConsumerWidget {
  const InspirationCard({super.key, required this.item});

  static const int maxLines = 3;

  final InspirationItem item;

  void _copy() {
    Clipboard.setData(ClipboardData(text: '${item.content}\n\n${item.source}'));
    showToast(text: 'تم النسخ');
  }

  void _share(BuildContext context, WidgetRef ref) {
    ShareService.showShareSheet(
      context,
      ref,
      content: item.content,
      subtitle: item.source,
      showSubtitleInImage: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = BrandSurfaceStyle.of(context);
    final reading = InspirationReading.of(
      context,
      ref,
      item,
      color: style.text,
      markColor: style.gold,
      isDark: style.isDark,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(context.corners.xl),
        onTap: () => InspirationDetailSheet.show(context, item),
        child: BrandSurface(
          padding: EdgeInsets.fromLTRB(
            context.insets.md,
            context.insets.sm,
            context.insets.sm,
            context.insets.sm,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textWidth = constraints.maxWidth - context.insets.sm;
              final exceeded = (TextPainter(
                text: reading.span,
                textDirection: TextDirection.rtl,
                maxLines: InspirationCard.maxLines,
              )..layout(maxWidth: textWidth)).didExceedMaxLines;

              return Column(
                children: [
                  SizedBox(
                    height: 28.h,
                    child: Row(
                      children: [
                        AppIcon(item.type.icon, size: 15.sp, color: style.accent),
                        SizedBox(width: 6.w),
                        Text(
                          item.type.label,
                          style: context.textStyles.labelMedium?.copyWith(
                            color: style.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        _RoundButton(
                          icon: HugeIcons.strokeRoundedCopy01,
                          tooltip: 'نسخ',
                          style: style,
                          onTap: _copy,
                        ),
                        _RoundButton(
                          icon: AppIcons.share,
                          tooltip: 'مشاركة',
                          style: style,
                          onTap: () => _share(context, ref),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      // Safety net: if the lines are taller than the space (Mushaf
                      // fonts), shrink slightly instead of clipping.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: textWidth,
                          child: Text.rich(
                            reading.span,
                            textAlign: TextAlign.center,
                            maxLines: InspirationCard.maxLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 18.h,
                    child: _Footer(
                      item: item,
                      style: style,
                      showReadMore: exceeded,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.item,
    required this.style,
    required this.showReadMore,
  });

  final InspirationItem item;
  final BrandSurfaceStyle style;
  final bool showReadMore;

  @override
  Widget build(BuildContext context) {
    final label = context.textStyles.labelMedium?.copyWith(
      color: style.textMuted,
      fontWeight: FontWeight.w500,
    );

    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: showReadMore
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              _Diamond(color: style.gold),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  item.footer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: label,
                ),
              ),
              if (!showReadMore) ...[
                SizedBox(width: 6.w),
                _Diamond(color: style.gold),
              ],
            ],
          ),
        ),
        if (showReadMore)
          Text(
            'قراءة المزيد',
            style: label?.copyWith(
              color: style.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.style,
    required this.onTap,
  });

  final AppIconData icon;
  final String tooltip;
  final BrandSurfaceStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 6.w),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style.controlBackground,
            ),
            child: AppIcon(icon, size: 14.sp, color: style.controlForeground),
          ),
        ),
      ),
    );
  }
}

class _Diamond extends StatelessWidget {
  const _Diamond({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.7853981634,
      child: Container(width: 4.w, height: 4.w, color: color),
    );
  }
}
