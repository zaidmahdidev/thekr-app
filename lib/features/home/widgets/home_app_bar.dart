import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/router/app_router.dart';

import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/hero_pattern.dart';

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
            // context.colors.background,
            context.colors.background,
          ],
          // stops: const [0.0, 0.85, 1.0],
        ),
        icon: HugeIcons.strokeRoundedMoon02,
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
          icon: HugeIcons.strokeRoundedMoon02,
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
          icon: HugeIcons.strokeRoundedSun03,
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
          icon: HugeIcons.strokeRoundedSunset,
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
          icon: HugeIcons.strokeRoundedSunset,
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
          icon: HugeIcons.strokeRoundedMoon02,
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
            // Islamic lattice and a soft glow behind the clock.
            const HeroPattern(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.1),
                  radius: 0.75,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0),
                  ],
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
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      todayDate,
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13.sp,
                        height: 1.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      intl.DateFormat('h:mm', 'en').format(currentTime),
                      style: context.textStyles.displayLarge?.copyWith(
                        fontSize: 60.sp,
                        // The big clock needs no extra leading (it overflowed with Amiri).
                        height: 1.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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
                            AppIcon(
                              theme.icon,
                              color: context.colors.secondary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              remainingTime,
                              style: context.textStyles.labelLarge?.copyWith(
                                fontSize: 12.sp,
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
          padding: EdgeInsetsDirectional.only(end: context.insets.sm),
          child: Center(
            child: Tooltip(
              message: 'الإعدادات',
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: CircleBorder(
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.router.push(const SettingsRoute()),
                      child: SizedBox(
                        width: 40.w,
                        height: 40.w,
                        child: Center(
                          child: AppIcon(
                            HugeIcons.strokeRoundedSettings02,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
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
  final AppIconData icon;

  _AppBarTheme({required this.gradient, required this.icon});
}
