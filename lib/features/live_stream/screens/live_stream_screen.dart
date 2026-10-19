import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/live_stream_model.dart';
import '../providers/live_stream_provider.dart';
import '../widgets/stream_card.dart';
import '../widgets/stream_player_widget.dart';
import 'package:thekr_app/core/utils/connectivity_utils.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Live broadcasts of the two holy mosques. The screen stays awake while the
/// stream plays.
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
    if (!mounted) return;
    setState(() => _isConnected = hasNet);
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
      if (mounted) setState(() => _isConnected = true);
    } else {
      if (mounted) setState(() => _isConnected = false);
      showToast(text: 'لا يوجد اتصال بالإنترنت', state: ToastStates.ERROR);
    }
  }

  Future<void> _reload() async {
    final stream = ref.read(selectedStreamProvider);
    if (await ConnectivityUtils.hasInternet()) {
      _controller.load(stream.youtubeId);
      if (mounted) setState(() => _isConnected = true);
    } else {
      if (mounted) setState(() => _isConnected = false);
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
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(context.insets.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isConnected)
                  StreamPlayerWidget(player: player)
                else
                  _NoInternetPlaceholder(onRetry: _checkInitialConnection),
                SizedBox(height: context.insets.md),
                _NowPlaying(stream: selectedStream, onReload: _reload),
                SizedBox(height: context.insets.lg),
                Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 18.h,
                      decoration: BoxDecoration(
                        color: context.colors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: context.insets.sm),
                    Text(
                      'اختر القناة',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.insets.md),
                for (final stream in LiveStream.all)
                  StreamCard(
                    stream: stream,
                    isSelected: selectedStream.id == stream.id,
                    onTap: () =>
                        ref.read(selectedStreamProvider.notifier).state =
                            stream,
                  ),
                SizedBox(height: context.insets.lg),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Title of the channel being played with a reload button.
class _NowPlaying extends StatelessWidget {
  const _NowPlaying({required this.stream, required this.onReload});

  final LiveStream stream;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stream.title,
                style: context.textStyles.titleMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                  height: 1.35,
                ),
              ),
              if (stream.description != null)
                Text(
                  stream.description!,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.5,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: context.insets.sm),
        IconButton(
          onPressed: onReload,
          tooltip: 'إعادة تحميل البث',
          style: IconButton.styleFrom(
            backgroundColor: context.colors.primary.withValues(alpha: 0.1),
          ),
          icon: AppIcon(HugeIcons.strokeRoundedRefresh, color: context.colors.primary),
        ),
      ],
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
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: context.colors.error.withValues(alpha: 0.2)),
        boxShadow: context.shadows.low,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            HugeIcons.strokeRoundedWifiDisconnected01,
            size: 48.w,
            color: context.colors.error.withValues(alpha: 0.6),
          ),
          SizedBox(height: context.insets.md),
          Text(
            'لا يوجد اتصال بالإنترنت',
            style: context.textStyles.titleMedium?.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.insets.sm),
          TextButton.icon(
            onPressed: onRetry,
            icon: const AppIcon(HugeIcons.strokeRoundedRefresh),
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
