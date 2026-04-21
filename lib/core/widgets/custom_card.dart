import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/widgets/my_card.dart';

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

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  style: AppTypography.h3.copyWith(
                    color: widget.isHighlighted
                        ? context.colors.primary
                        : context.colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                if (widget.subTitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    widget.subTitle!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
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
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.w,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.around),
          fit: BoxFit.contain,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          widget.leading!,
          style: AppTypography.bodyMedium.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
