import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/tokens/typography.dart';

class ProphetVerseCard extends StatelessWidget {
  final String verse;
  final VoidCallback onCopy;

  const ProphetVerseCard({
    super.key,
    required this.verse,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: context.insets.sm),
      padding: EdgeInsets.all(context.insets.sm),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(context.corners.md),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: onCopy,
              child: Icon(
                Icons.copy_rounded,
                size: 20.w,
                color: context.colors.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
          Text(
            verse,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: context.colors.primary,
              fontFamily: 'hafs',
              fontSize: 18.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
