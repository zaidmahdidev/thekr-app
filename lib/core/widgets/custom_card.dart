import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/my_card.dart';
import 'package:thekr_app/core/widgets/number_badge.dart';

class CustomCard extends StatefulWidget {
  const CustomCard({
    Key? key,
    required this.title,
    this.subTitle,
    this.leading,
    this.trailing,
    this.fun,
    this.isHighlighted = false,
  }) : super(key: key);

  final String title;
  final String? subTitle;
  final String? leading;
  final String? trailing;
  final VoidCallback? fun;
  final bool isHighlighted;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MyCard(
      isHighlighted: widget.isHighlighted,
      onTap: widget.fun,
      child: Row(
        children: [
          if (widget.leading != null) ...[
            _buildLeading(context),
            SizedBox(width: context.insets.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: context.textStyles.titleLarge?.copyWith(
                    color: widget.isHighlighted
                        ? colors.primary
                        : colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    height: 1.35,
                  ),
                ),
                if (widget.subTitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    widget.subTitle!,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 13.sp,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            SizedBox(width: context.insets.sm),
            Text(
              widget.trailing!,
              style: context.textStyles.bodyMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (widget.fun != null) ...[
            SizedBox(width: context.insets.sm),
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppIcon(
                  HugeIcons.strokeRoundedArrowRight01,
                  color: colors.primary,
                  size: 18.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    return NumberBadge(number: widget.leading!, size: 46.w);
  }
}
