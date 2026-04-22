import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/tokens/typography.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../data/prophets_data.dart';
import '../models/prophet_story.dart';

@RoutePage()
class ProphetsListScreen extends StatelessWidget {
  const ProphetsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'قصص الأنبياء',
      body: GridView.builder(
        padding: EdgeInsets.all(context.insets.md),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: context.insets.sm,
          mainAxisSpacing: context.insets.sm,
        ),
        itemCount: ProphetsData.stories.length,
        itemBuilder: (context, index) {
          final prophet = ProphetsData.stories[index];
          return _ProphetGridItem(prophet: prophet);
        },
      ),
    );
  }
}

class _ProphetGridItem extends StatelessWidget {
  final ProphetStory prophet;

  const _ProphetGridItem({required this.prophet});

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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.corners.lg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () =>
                context.pushRoute(ProphetDetailsRoute(prophet: prophet)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.insets.xl,
                vertical: context.insets.sm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon/Symbol Circle
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          context.colors.primary,
                          context.colors.primary.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        prophet.name[0],
                        style: AppTypography.h2.copyWith(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.insets.sm),
                  Text(
                    prophet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.h3.copyWith(
                      color: context.colors.textPrimary,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: context.insets.sm),
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
