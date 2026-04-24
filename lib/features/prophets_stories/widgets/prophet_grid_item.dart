import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/router/app_router.dart';
import '../models/prophet_story.dart';

class ProphetGridItem extends StatelessWidget {
  final ProphetStory prophet;

  const ProphetGridItem({
    super.key,
    required this.prophet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.corners.lg),
        boxShadow: context.shadows.low,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.surface.withValues(alpha: 0.9),
            context.colors.surface.withValues(alpha: 0.7),
          ],
        ),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.corners.lg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: InkWell(
            onTap: () => context.pushRoute(ProphetDetailsRoute(prophet: prophet)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.insets.sm,
                vertical: context.insets.sm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Container with Glassy Gradient
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.colors.primary.withValues(alpha: 0.1),
                          context.colors.primary.withValues(alpha: 0.05),
                        ],
                      ),
                      border: Border.all(
                        color: context.colors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        prophet.emoji,
                        style: TextStyle(
                          fontSize: 32.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.insets.sm),
                  Text(
                    prophet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTypography.h3.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    prophet.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      color: context.colors.textSecondary,
                      fontSize: 8.sp,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
