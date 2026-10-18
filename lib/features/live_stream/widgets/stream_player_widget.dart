import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'stream_card.dart';

/// Frame around the YouTube player with a live badge.
class StreamPlayerWidget extends StatelessWidget {
  final Widget player;

  const StreamPlayerWidget({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.corners.xl),
        boxShadow: context.shadows.medium,
        color: Colors.black,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          player,
          PositionedDirectional(
            top: 10,
            start: 10,
            child: IgnorePointer(child: const LiveBadge()),
          ),
        ],
      ),
    );
  }
}
