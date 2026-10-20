import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/hero_pattern.dart';
import 'radio_player_card.dart';

/// Pinned header of the radio screen. It starts as the full player and, as the
/// list scrolls, shrinks into a slim bar so the controls never leave the screen.
class RadioPlayerHeaderDelegate extends SliverPersistentHeaderDelegate {
  RadioPlayerHeaderDelegate({required this.expandedHeight});

  final double expandedHeight;

  double get _collapsedHeight => 84.h;

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => _collapsedHeight;

  @override
  bool shouldRebuild(covariant RadioPlayerHeaderDelegate old) =>
      old.expandedHeight != expandedHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = (maxExtent - minExtent).clamp(1.0, double.infinity);
    final t = (shrinkOffset / range).clamp(0.0, 1.0);

    final primary = context.colors.primary;
    final hsl = HSLColor.fromColor(primary);
    final darker = hsl.withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0)).toColor();

    // The full player fades out in the first half, the slim one fades in during
    // the second half, so the two never overlap visibly.
    final expandedOpacity = (1 - t * 2).clamp(0.0, 1.0);
    final miniOpacity = (t * 2 - 1).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.insets.md,
        context.insets.sm,
        context.insets.md,
        context.insets.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.corners.xl),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [primary, darker],
          ),
          boxShadow: context.shadows.medium,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.corners.xl),
          child: Stack(
            children: [
              const Positioned.fill(
                child: IgnorePointer(child: HeroPattern(opacity: 0.18)),
              ),
              if (expandedOpacity > 0)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: expandedOpacity < 0.5,
                    child: Opacity(
                      opacity: expandedOpacity,
                      child: OverflowBox(
                        alignment: Alignment.topCenter,
                        minHeight: 0,
                        maxHeight: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.all(context.insets.md),
                          child: const RadioExpandedPlayer(),
                        ),
                      ),
                    ),
                  ),
                ),
              if (miniOpacity > 0)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: miniOpacity < 0.5,
                    child: Opacity(
                      opacity: miniOpacity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.insets.md,
                        ),
                        child: const Center(child: RadioMiniPlayer()),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pinned strip under the player that holds the category chips.
class RadioChipsHeaderDelegate extends SliverPersistentHeaderDelegate {
  RadioChipsHeaderDelegate({required this.child, required this.background});

  final Widget child;
  final Color background;

  double get _height => 54.h;

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(covariant RadioChipsHeaderDelegate old) =>
      old.background != background;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: background,
      alignment: Alignment.center,
      child: SizedBox(height: 38.h, child: child),
    );
  }
}
