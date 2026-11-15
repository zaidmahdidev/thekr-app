import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/providers/feature_badge_provider.dart';

class NewFeatureBadge extends ConsumerWidget {
  final Widget child;
  final String featureId;
  final String addedInVersion;
  final bool showBadge;

  const NewFeatureBadge({
    super.key,
    required this.child,
    required this.featureId,
    required this.addedInVersion,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeState = ref.watch(featureBadgeProvider);
    final notifier = ref.read(featureBadgeProvider.notifier);
    
    // Check logic
    final bool shouldShow = showBadge && notifier.shouldShowBadge(featureId, addedInVersion);

    if (!shouldShow) return child;

    // passthrough: the card gets the constraints as they come. In a grid cell
    // they are tight, so the card fills the cell; in a list the height is not
    // bounded, so the card keeps its own height. (StackFit.expand made the
    // settings tiles disappear in a list, leaving only the badge.)
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -8.h,
          left: -8.w, // Top left since app is RTL usually, or top right? RTL left means top-left of the container physically.
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800), // Gold/Orange for "New"
              borderRadius: BorderRadius.circular(context.corners.md),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.4),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'جديد',
                  style: context.textStyles.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
