import 'package:flutter/material.dart';
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
        enableCaption: false,
        forceHD: false,
        // تعطيل التفاعل مع شريط البحث في البث المباشر لتجنب الأخطاء
        disableDragSeek: true,
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
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: false,
        liveUIColor: context.colors.primary,
        onReady: () {
          debugPrint('YouTube Player is ready.');
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
