import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/tokens/typography.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../models/prophet_story.dart';

class ProphetDetailsHeader extends StatelessWidget {
  final ProphetStory prophet;
  final VoidCallback onCopyAll;
  final VoidCallback onShare;

  const ProphetDetailsHeader({
    super.key,
    required this.prophet,
    required this.onCopyAll,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final double expandedHeight = 150.h;
    final double collapsedHeight = 50.h;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      pinned: true,
      backgroundColor: context.colors.primary,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.maybePop(),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20.w,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white),
          onPressed: onShare,
        ),
        IconButton(
          icon: const Icon(Icons.copy_all_outlined, color: Colors.white),
          onPressed: onCopyAll,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: context.insets.md),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final double appBarHeight = constraints.maxHeight;
            final double t = ((expandedHeight + collapsedHeight/2) - appBarHeight) / (expandedHeight - collapsedHeight);
            final double opacity = (1.0 - t).clamp(0.0, 1.0);

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji Medallion - Fades out as we scroll up
                if (opacity > 0.1)
                  Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 54.w,
                      height: 54.w,
                      margin: EdgeInsets.only(bottom: context.insets.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'prophet_emoji_${prophet.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              prophet.emoji,
                              style: TextStyle(fontSize: 28.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Prophet Name
                Hero(
                  tag: 'prophet_name_${prophet.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      prophet.name,
                      style: AppTypography.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: (20 - (4 * t)).sp,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppAssets.bg, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.primary.withValues(alpha: 0.6),
                    context.colors.primary.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
