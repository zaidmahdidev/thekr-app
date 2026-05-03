import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';

class BrandedRefreshHeader extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const BrandedRefreshHeader({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: onRefresh,
      refreshTriggerPullDistance: 100.0,
      refreshIndicatorExtent: 80.0,
      builder: (
        context,
        refreshState,
        pulledExtent,
        refreshTriggerPullDistance,
        refreshIndicatorExtent,
      ) {
        final double percentage = (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating background (subtle)
              Transform.rotate(
                angle: percentage * 3.14 * 2,
                child: Opacity(
                  opacity: percentage * 0.5,
                  child: Image.asset(
                    AppAssets.around,
                    width: 60.w,
                    color: context.colors.secondary.withValues(alpha: 0.3),
                  ),
                ),
              ),
              
              // Pulsing Logo
              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 1.0,
                  end: refreshState == RefreshIndicatorMode.refresh ? 1.2 : 1.0,
                ),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: (percentage * 0.8) + (refreshState == RefreshIndicatorMode.refresh ? (scale - 1.0) : 0.0),
                    child: Opacity(
                      opacity: percentage.clamp(0.3, 1.0),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.primary.withValues(alpha: 0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AppAssets.logo,
                          width: 35.w,
                          height: 35.w,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Loading Spinner (Subtle, only during refresh)
              if (refreshState == RefreshIndicatorMode.refresh)
                Positioned(
                  bottom: 0,
                  child: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.secondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
