import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/widgets/app_button.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:thekr_app/features/home/models/inspiration_item.dart';
import 'package:thekr_app/features/home/widgets/inspiration_reading.dart';
import 'package:thekr_app/core/utils/constants/app_icons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Full text of a daily inspiration with its source, copy and share.
class InspirationDetailSheet extends ConsumerWidget {
  const InspirationDetailSheet({super.key, required this.item});

  final InspirationItem item;

  static Future<void> show(BuildContext context, InspirationItem item) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => InspirationDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = context.colors.primary;

    final reading = InspirationReading.of(
      context,
      ref,
      item,
      color: context.colors.textPrimary,
      markColor: context.colors.secondary,
      isDark: context.isDarkMode,
      scale: 1.3,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.corners.xl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.insets.lg,
            context.insets.sm,
            context.insets.lg,
            context.insets.md,
          ),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon(item.type.icon, size: 18.sp, color: accent),
                  SizedBox(width: 6.w),
                  Text(
                    item.type.label,
                    style: context.textStyles.titleSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.insets.md),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Text.rich(reading.span, textAlign: TextAlign.center),
                      if (item.note != null) ...[
                        SizedBox(height: context.insets.md),
                        Text(
                          item.note!,
                          textAlign: TextAlign.center,
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: context.colors.textSecondary,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.insets.md),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.insets.md,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: context.colors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(context.corners.xl),
                ),
                child: Text(
                  item.source,
                  textAlign: TextAlign.center,
                  style: context.textStyles.labelMedium?.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: context.insets.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'نسخ',
                      icon: HugeIcons.strokeRoundedCopy01,
                      variant: AppButtonVariant.outline,
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: '${item.content}\n\n${item.source}',
                          ),
                        );
                        Navigator.pop(context);
                        showToast(text: 'تم النسخ');
                      },
                    ),
                  ),
                  SizedBox(width: context.insets.sm),
                  Expanded(
                    child: AppButton(
                      text: 'مشاركة',
                      icon: AppIcons.share,
                      onTap: () => ShareService.showShareSheet(
                        context,
                        ref,
                        content: item.content,
                        subtitle: item.source,
                        showSubtitleInImage: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
