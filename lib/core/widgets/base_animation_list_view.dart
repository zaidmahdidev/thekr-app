import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class BaseAnimationListView extends StatelessWidget {
  BaseAnimationListView({
    super.key,
    required this.index,
    required this.child,
    this.duration,
    this.horizontalOffset = 200,
    this.verticalOffset = 0,
  });

  final int index;
  final Widget child;
  final int? duration;
  final double horizontalOffset;
  final double verticalOffset;

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: Duration(milliseconds: duration ?? 800),
      child: SlideAnimation(
        horizontalOffset: horizontalOffset,
        verticalOffset: verticalOffset,
        child: FadeInAnimation(child: child),
      ),
    );
  }
}
