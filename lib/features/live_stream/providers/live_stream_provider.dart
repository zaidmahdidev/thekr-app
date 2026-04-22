import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/live_stream_model.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

final selectedStreamProvider = StateProvider<LiveStream>((ref) {
  return LiveStream.defaults.first;
});

final youtubeControllerProvider = Provider.family<YoutubePlayerController, String>((ref, videoId) {
  final controller = YoutubePlayerController.fromVideoId(
    videoId: videoId,
    autoPlay: true,
    params: const YoutubePlayerParams(
      showFullscreenButton: true,
      mute: false,
      showControls: true,
    ),
  );
  
  ref.onDispose(() {
    controller.close();
  });
  
  return controller;
});
