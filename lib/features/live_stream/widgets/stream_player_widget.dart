import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

class StreamPlayerWidget extends StatefulWidget {
  final String videoId;

  const StreamPlayerWidget({super.key, required this.videoId});

  @override
  State<StreamPlayerWidget> createState() => _StreamPlayerWidgetState();
}

class _StreamPlayerWidgetState extends State<StreamPlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    String finalId = _extractId(widget.videoId);
    debugPrint('YouTube Player Initializing with ID: $finalId');

    _controller = YoutubePlayerController(
      initialVideoId: finalId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        isLive: true,
        disableDragSeek: true,
        hideControls: false,
      ),
    );
  }

  String _extractId(String input) {
    if (input.isEmpty) return '';
    if (input.length == 11 && !input.contains('/')) return input;

    final id = YoutubePlayer.convertUrlToId(input);
    return id ?? input.trim();
  }

  @override
  void didUpdateWidget(StreamPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      final newId = _extractId(widget.videoId);
      _controller.load(newId);
    }
  }

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
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: false,
            liveUIColor: context.colors.primary,
            bottomActions: [
              const PlayPauseButton(),
              const SizedBox(width: 8),
              const FullScreenButton(),
            ],
          ),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
