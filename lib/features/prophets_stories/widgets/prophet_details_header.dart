import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../models/prophet_story.dart';
import 'package:thekr_app/core/utils/constants/app_icons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Header of the story screen: a rounded banner with the prophet's name and
/// title that folds into a slim bar with the name when the story is scrolled.
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
    final topInset = MediaQuery.paddingOf(context).top;
    final expandedHeight = 168.h + topInset;
    final collapsedHeight = kToolbarHeight + topInset;
    final radius = Radius.circular(context.corners.xl);

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: expandedHeight,
      collapsedHeight: kToolbarHeight,
      toolbarHeight: kToolbarHeight,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: context.colors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: radius),
      ),
      clipBehavior: Clip.antiAlias,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final t =
              ((constraints.maxHeight - collapsedHeight) /
                      (expandedHeight - collapsedHeight))
                  .clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              _Backdrop(color: context.colors.primary),
              // Expanded content: fades out while the header folds.
              Positioned(
                left: context.insets.lg,
                right: context.insets.lg,
                bottom: context.insets.md,
                child: Opacity(
                  opacity: Curves.easeIn.transform(t),
                  child: _Identity(prophet: prophet),
                ),
              ),
              // Folded content: the name, shown once the banner is folded.
              Positioned(
                left: 0,
                right: 0,
                top: topInset,
                height: kToolbarHeight,
                child: Opacity(
                  opacity: Curves.easeIn.transform(1 - t),
                  child: Center(
                    child: Text(
                      prophet.name,
                      style: context.textStyles.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Buttons stay on top in both states.
              Positioned(
                left: context.insets.sm,
                right: context.insets.sm,
                top: topInset,
                height: kToolbarHeight,
                child: Row(
                  children: [
                    _GlassButton(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      tooltip: 'رجوع',
                      onPressed: () => context.maybePop(),
                    ),
                    const Spacer(),
                    _GlassButton(
                      icon: AppIcons.share,
                      tooltip: 'مشاركة',
                      onPressed: onShare,
                    ),
                    SizedBox(width: context.insets.sm),
                    _GlassButton(
                      icon: HugeIcons.strokeRoundedCopy01,
                      tooltip: 'نسخ القصة',
                      onPressed: onCopyAll,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(AppAssets.bg, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.78),
                color.withValues(alpha: 0.96),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.prophet});

  final ProphetStory prophet;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.14),
            border: Border.all(
              color: context.colors.secondary.withValues(alpha: 0.9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Hero(
              tag: 'prophet_emoji_${prophet.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(prophet.emoji, style: TextStyle(fontSize: 24.sp)),
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Hero(
          tag: 'prophet_name_${prophet.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              prophet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          prophet.title,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final AppIconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.16),
        shape: CircleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 42.w,
            height: 42.w,
            child: AppIcon(icon, color: Colors.white, size: 24.sp),
          ),
        ),
      ),
    );
  }
}
