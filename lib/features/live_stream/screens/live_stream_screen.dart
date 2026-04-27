import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/live_stream_model.dart';
import '../providers/live_stream_provider.dart';
import '../widgets/stream_player_widget.dart';

@RoutePage()
class LiveStreamScreen extends ConsumerStatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  ConsumerState<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends ConsumerState<LiveStreamScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();

    final initialStream = ref.read(selectedStreamProvider);
    _controller = YoutubePlayerController(
      initialVideoId: initialStream.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        isLive: true,
        disableDragSeek: true,
      ),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedStream = ref.watch(selectedStreamProvider);

    // Update video if stream changed
    ref.listen(selectedStreamProvider, (previous, next) {
      if (next.youtubeId != previous?.youtubeId) {
        _controller.load(next.youtubeId);
      }
    });

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: false,
        liveUIColor: context.colors.primary,
        bottomActions: [
          const PlayPauseButton(),
          const SizedBox(width: 8),
          const FullScreenButton(),
        ],
      ),
      builder: (context, player) {
        return AppScaffold(
          title: 'البث المباشر',
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Player
                StreamPlayerWidget(player: player),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.insets.lg),
                  child: Text(
                    'اختر القناة',
                    style: AppTypography.h3.copyWith(color: context.colors.primary),
                  ),
                ),

                SizedBox(height: context.insets.md),

                // Stream List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: context.insets.md),
                  itemCount: LiveStream.defaults.length,
                  itemBuilder: (context, index) {
                    final stream = LiveStream.defaults[index];
                    final isSelected = selectedStream.id == stream.id;

                    return _StreamCard(
                      stream: stream,
                      isSelected: isSelected,
                      onTap: () =>
                          ref.read(selectedStreamProvider.notifier).state = stream,
                    );
                  },
                ),

                SizedBox(height: context.insets.xl),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StreamCard extends StatelessWidget {
  final LiveStream stream;
  final bool isSelected;
  final VoidCallback onTap;

  const _StreamCard({
    required this.stream,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.insets.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(
          color: isSelected
              ? context.colors.primary
              : context.colors.background.withValues(alpha: 0.1),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? context.shadows.low : null,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.all(context.insets.md),
        leading: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.primary
                : context.colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.live_tv_rounded,
            color: isSelected ? Colors.white : context.colors.primary,
          ),
        ),
        title: Text(
          stream.title,
          style: AppTypography.h3.copyWith(
            fontSize: 14.sp,
            color: isSelected
                ? context.colors.primary
                : context.colors.textPrimary,
          ),
        ),
        subtitle: stream.description != null
            ? Text(
                stream.description!,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              )
            : null,
      ),
    );
  }
}
