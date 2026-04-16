import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/router/app_router.dart';

class HomeAppBar extends StatelessWidget {
  final DateTime currentTime;
  final String todayDate;
  final String remainingTime;

  const HomeAppBar({
    super.key,
    required this.currentTime,
    required this.todayDate,
    required this.remainingTime,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: 16.h),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppAssets.hero, fit: BoxFit.cover),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    todayDate,
                    style: AppTypography.h3.copyWith(letterSpacing: 1.2),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    intl.DateFormat('h:mm:ss', 'ar').format(currentTime),
                    style: AppTypography.h1.copyWith(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (remainingTime.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.insets.lg,
                        vertical: context.insets.sm,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colors.secondary.withValues(alpha: 0.2),
                            context.colors.secondary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(context.corners.xl),
                        border: Border.all(
                          color: context.colors.secondary.withValues(
                            alpha: 0.3,
                          ),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            color: context.colors.secondary,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            remainingTime,
                            style: AppTypography.label.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(context.insets.sm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () =>
                context.router.push(const NotificationSettingsRoute()),
            icon: Image.asset(
              AppAssets.notification,
              width: 22.w,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
