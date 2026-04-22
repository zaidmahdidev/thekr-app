import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import '../providers/live_stream_provider.dart';

class StreamPlayerWidget extends ConsumerWidget {
  final String videoId;

  const StreamPlayerWidget({super.key, required this.videoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(youtubeControllerProvider(videoId));

    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(context.insets.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.corners.lg),
            boxShadow: context.shadows.medium,
            color: Colors.black,
          ),
          clipBehavior: Clip.antiAlias,
          child: YoutubePlayer(
            controller: controller,
            aspectRatio: 16 / 9,
          ),
        ),
      ],
    );
  }
}
