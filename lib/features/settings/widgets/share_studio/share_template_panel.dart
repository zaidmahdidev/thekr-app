import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/share_card_view.dart';
import 'package:thekr_app/features/settings/models/share_card_style.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

/// Template tab: horizontally scrolling live thumbnails of every template.
class ShareTemplatePanel extends StatelessWidget {
  const ShareTemplatePanel({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ShareTemplate selected;
  final ValueChanged<ShareTemplate> onSelected;

  static const _sample = 'سبحان الله وبحمده';
  static const _thumbStyle = ShareCardStyle(
    ratio: ShareCardRatio.portrait,
    showSignature: false,
  );

  @override
  Widget build(BuildContext context) {
    final thumbWidth = 84.w;
    final thumbHeight = thumbWidth / ShareCardRatio.portrait.aspect;

    return SizedBox(
      height: thumbHeight + 30.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: ShareTemplate.values.length,
        separatorBuilder: (_, _) => SizedBox(width: context.insets.sm + 2.w),
        itemBuilder: (context, index) {
          final template = ShareTemplate.values[index];
          final isSelected = template == selected;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(template),
            child: SizedBox(
              width: thumbWidth,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: thumbWidth,
                    height: thumbHeight,
                    padding: EdgeInsets.all(2.5.r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        context.corners.lg + 3,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected ? context.shadows.medium : null,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            context.corners.lg,
                          ),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: ShareCardView(
                              template: template,
                              content: _sample,
                              style: _thumbStyle,
                            ),
                          ),
                        ),
                        if (isSelected)
                          PositionedDirectional(
                            top: 4.h,
                            end: 4.w,
                            child: Container(
                              padding: EdgeInsets.all(2.r),
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 12.sp,
                                color: context.colors.surface,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    template.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.labelSmall?.copyWith(
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
