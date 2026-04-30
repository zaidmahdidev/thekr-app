import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/router/app_router.dart';

import 'package:thekr_app/core/utils/enums/prayer_enum.dart';

class HomeAppBar extends StatelessWidget {
  final DateTime currentTime;
  final String todayDate;
  final String hijriDate;
  final String remainingTime;
  final AppPrayer? nextPrayer;

  const HomeAppBar({
    super.key,
    required this.currentTime,
    required this.todayDate,
    required this.hijriDate,
    required this.remainingTime,
    this.nextPrayer,
  });

  _AppBarTheme _getTheme(BuildContext context) {
    if (nextPrayer == null) {
      return _AppBarTheme(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.colors.primary,
            context.colors.background,
            context.colors.background,
          ],
          stops: const [0.0, 0.85, 1.0],
        ),
        icon: Icons.nightlight_round,
      );
    }

    switch (nextPrayer!) {
      case AppPrayer.fajr:
        return _AppBarTheme(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF203A43),
              // const Color(0xFF203A43),
              // const Color(0xFF2C5364),
              context.colors.background,
              context.colors.background,
            ],
            // stops: const [0.0, 0.3, 0.6, 0.85, 1.0],
          ),
          icon: Icons.brightness_3_rounded,
        );
      case AppPrayer.sunrise:
      case AppPrayer.dhuhr:
        return _AppBarTheme(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2193b0),
              // const Color(0xFF6dd5ed),
              // context.colors.background,
              context.colors.background,
            ],
            // stops: const [0.0, 0.6, 0.85, 1.0],
          ),
          icon: Icons.wb_sunny_rounded,
        );
      case AppPrayer.asr:
        return _AppBarTheme(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFf97a20),
              // const Color(0xFFf5af19),
              // context.colors.background,
              context.colors.background,
            ],
            // stops: const [0.0, 0.6, 0.85, 1.0],
          ),
          icon: Icons.wb_twilight_rounded,
        );
      case AppPrayer.maghrib:
        return _AppBarTheme(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6441A5),
              // const Color(0xFF2a0845),
              // context.colors.background,
              context.colors.background,
            ],
            // stops: const [0.0, 0.6, 0.85, 1.0],
          ),
          icon: Icons.wb_twilight_rounded,
        );
      case AppPrayer.isha:
        return _AppBarTheme(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F2027),
              // const Color(0xFF243B55),
              // context.colors.background,
              context.colors.background,
            ],
            // stops: const [0.0, 0.6, 0.85, 1.0],
          ),
          icon: Icons.nightlight_round,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme(context);

    return SliverAppBar(
      expandedHeight: 180.h,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(gradient: theme.gradient),
            ),
            // Subtle Islamic Pattern
            Align(
              alignment: Alignment.centerLeft,
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  AppAssets.hero,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            // Main Content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      hijriDate,
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      todayDate,
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      intl.DateFormat('h:mm', 'ar').format(currentTime),
                      style: context.textStyles.displayLarge?.copyWith(
                        fontSize: 64.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    if (remainingTime.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.insets.lg,
                          vertical: context.insets.sm,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.background.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            context.corners.xl,
                          ),
                          border: Border.all(
                            color: context.colors.secondary.withValues(
                              alpha: 0.2,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              theme.icon,
                              color: context.colors.secondary,
                              size: 14.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              remainingTime,
                              style: context.textStyles.labelLarge?.copyWith(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(left: context.insets.sm),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.background.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.secondary,
                    width: .2,
                  ),
                ),
                child: IconButton(
                  onPressed: () => context.router.push(const SettingsRoute()),
                  icon: Image.asset(AppAssets.notification, width: 40.w),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppBarTheme {
  final Gradient gradient;
  final IconData icon;

  _AppBarTheme({required this.gradient, required this.icon});
}
