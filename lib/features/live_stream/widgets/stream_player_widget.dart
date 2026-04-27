import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

class StreamPlayerWidget extends StatelessWidget {
  final Widget player;

  const StreamPlayerWidget({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.corners.lg),
        boxShadow: context.shadows.medium,
        color: Colors.black,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          player,
          // مؤشر البث المباشر
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'مباشر',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
