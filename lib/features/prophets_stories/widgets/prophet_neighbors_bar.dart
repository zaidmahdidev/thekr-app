import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/router/app_router.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../data/prophets_data.dart';
import '../models/prophet_story.dart';

/// Previous / next prophet buttons at the end of a story.
class ProphetNeighborsBar extends StatelessWidget {
  const ProphetNeighborsBar({super.key, required this.prophet});

  final ProphetStory prophet;

  @override
  Widget build(BuildContext context) {
    final stories = ProphetsData.stories;
    final index = stories.indexWhere((p) => p.id == prophet.id);
    if (index < 0) return const SizedBox.shrink();

    final previous = index > 0 ? stories[index - 1] : null;
    final next = index < stories.length - 1 ? stories[index + 1] : null;

    return Row(
      children: [
        Expanded(
          child: previous == null
              ? const SizedBox.shrink()
              : _NeighborButton(
                  label: 'السابق',
                  name: previous.name,
                  icon: Icons.arrow_forward_ios_rounded,
                  iconFirst: true,
                  onTap: () => context.replaceRoute(
                    ProphetDetailsRoute(prophet: previous),
                  ),
                ),
        ),
        SizedBox(width: context.insets.md),
        Expanded(
          child: next == null
              ? const SizedBox.shrink()
              : _NeighborButton(
                  label: 'التالي',
                  name: next.name,
                  icon: Icons.arrow_back_ios_new_rounded,
                  iconFirst: false,
                  onTap: () =>
                      context.replaceRoute(ProphetDetailsRoute(prophet: next)),
                ),
        ),
      ],
    );
  }
}

class _NeighborButton extends StatelessWidget {
  const _NeighborButton({
    required this.label,
    required this.name,
    required this.icon,
    required this.iconFirst,
    required this.onTap,
  });

  final String label;
  final String name;
  final IconData icon;
  final bool iconFirst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Forced LTR so the arrow is not mirrored by the RTL layout: the previous
    // button sits on the right and points right, the next one on the left.
    final iconWidget = Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(icon, size: 14.sp, color: context.colors.primary),
    );

    return Material(
      color: context.colors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(context.corners.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.corners.lg),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.insets.md,
            vertical: context.insets.sm + 2.h,
          ),
          child: Row(
            children: [
              if (iconFirst) ...[iconWidget, SizedBox(width: context.insets.sm)],
              Expanded(
                child: Column(
                  crossAxisAlignment: iconFirst
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Text(
                      label,
                      style: context.textStyles.labelSmall?.copyWith(
                        color: context.colors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.titleSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (!iconFirst) ...[SizedBox(width: context.insets.sm), iconWidget],
            ],
          ),
        ),
      ),
    );
  }
}
