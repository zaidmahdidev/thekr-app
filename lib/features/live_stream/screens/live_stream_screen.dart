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
import 'package:thekr_app/core/utils/connectivity_utils.dart';

@RoutePage()
class LiveStreamScreen extends ConsumerStatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  ConsumerState<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends ConsumerState<LiveStreamScreen> {
  late YoutubePlayerController _controller;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _checkInitialConnection();

    final initialStream = ref.read(selectedStreamProvider);
    _controller = YoutubePlayerController(
      initialVideoId: initialStream.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        isLive: false,
        disableDragSeek: true,
        loop: false,
      ),
    );
  }

  Future<void> _checkInitialConnection() async {
    final hasNet = await ConnectivityUtils.hasInternet();
    setState(() {
      _isConnected = hasNet;
    });
    if (!hasNet) {
      showToast(
        text: 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة',
        state: ToastStates.ERROR,
      );
    }
  }

  Future<void> _handleStreamChange(String youtubeId) async {
    if (await ConnectivityUtils.hasInternet()) {
      _controller.load(youtubeId);
      setState(() => _isConnected = true);
    } else {
      setState(() => _isConnected = false);
      showToast(text: 'لا يوجد اتصال بالإنترنت', state: ToastStates.ERROR);
    }
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
        _handleStreamChange(next.youtubeId);
      }
    });

    return YoutubePlayerBuilder(
      onEnterFullScreen: () => WakelockPlus.enable(),
      onExitFullScreen: () => WakelockPlus.enable(),
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: false,
        onReady: () => setState(() => _isConnected = true),
      ),
      builder: (context, player) {
        return AppScaffold(
          title: 'البث المباشر',
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Player with Custom Overlay
                if (_isConnected)
                  Container(
                    width: double.infinity,
                    // aspectRatio: 16 / 9,
                    margin: EdgeInsets.all(context.insets.md),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.corners.lg),
                      boxShadow: context.shadows.low,
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        player,
                        // Custom Controls Overlay
                        Positioned.fill(
                          child: _PlayerControlsOverlay(
                            controller: _controller,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _NoInternetPlaceholder(onRetry: _checkInitialConnection),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.insets.lg),
                  child: Text(
                    'اختر القناة',
                    style: AppTypography.h3.copyWith(
                      color: context.colors.primary,
                    ),
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
                          ref.read(selectedStreamProvider.notifier).state =
                              stream,
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

class _PlayerControlsOverlay extends StatefulWidget {
  final YoutubePlayerController controller;

  const _PlayerControlsOverlay({required this.controller});

  @override
  State<_PlayerControlsOverlay> createState() => _PlayerControlsOverlayState();
}

class _PlayerControlsOverlayState extends State<_PlayerControlsOverlay> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isVisible = !_isVisible),
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black26,
          child: Stack(
            children: [
              // Center Play/Pause
              Center(
                child: IconButton(
                  icon: Icon(
                    widget.controller.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 50.w,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (widget.controller.value.isPlaying) {
                      widget.controller.pause();
                    } else {
                      widget.controller.play();
                    }
                    setState(() {});
                  },
                ),
              ),
              // Bottom Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(context.insets.sm),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Badge (Live)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.insets.xl,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.error,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'مباشر',
                          style: context.textStyles.bodySmall!.copyWith(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Full Screen Button
                      IconButton(
                        icon: const Icon(
                          Icons.fullscreen_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            widget.controller.toggleFullScreenMode(),
                      ),
                    ],
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

class _NoInternetPlaceholder extends StatelessWidget {
  final VoidCallback onRetry;

  const _NoInternetPlaceholder({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.h,
      margin: EdgeInsets.all(context.insets.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        boxShadow: context.shadows.low,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 48.w,
            color: context.colors.error.withValues(alpha: 0.5),
          ),
          SizedBox(height: context.insets.md),
          Text(
            'لا يوجد اتصال بالإنترنت',
            style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
          ),
          SizedBox(height: context.insets.sm),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.primary,
            ),
          ),
        ],
      ),
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
