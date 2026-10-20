import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import '../models/radio_station.dart';
import '../providers/radio_controller.dart';
import '../providers/radio_providers.dart';
import 'radio_equalizer.dart';
import 'radio_sleep_timer_sheet.dart';

/// Full "now playing" content: station, connection status and the transport
/// controls. It reflects every playback state, including offline and errors.
/// Drawn on the gradient surface supplied by the screen's collapsing header.
class RadioExpandedPlayer extends ConsumerWidget {
  const RadioExpandedPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radio = ref.watch(radioControllerProvider);
    final controller = ref.read(radioControllerProvider.notifier);
    final visible = ref.watch(visibleRadioStationsProvider);
    final queue = visible.isEmpty ? RadioStation.available : visible;
    final favorites = ref.watch(radioFavoritesProvider);
    final station = radio.station;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TopRow(
          radio: radio,
          onSleepTap: () => openRadioSleepTimer(context, controller, radio),
        ),
        SizedBox(height: context.insets.md),
        _Artwork(radio: radio, category: station?.category),
        SizedBox(height: context.insets.md),
        _Titles(radio: radio),
        _StatusMessage(
          radio: radio,
          onRetry: station == null ? null : () => controller.play(station),
        ),
        SizedBox(height: context.insets.md),
        _Controls(
          radio: radio,
          isFavorite: station != null && favorites.contains(station.id),
          onFavorite: station == null
              ? null
              : () =>
                    ref.read(radioFavoritesProvider.notifier).toggle(station.id),
          onToggle: () => controller.toggle(queue),
          onNext: () => controller.next(queue),
          onPrevious: () => controller.previous(queue),
          onSleep: () => openRadioSleepTimer(context, controller, radio),
        ),
      ],
    );
  }
}

/// Slim player shown once the full one has scrolled away, so the controls are
/// always within reach.
class RadioMiniPlayer extends ConsumerWidget {
  const RadioMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radio = ref.watch(radioControllerProvider);
    final controller = ref.read(radioControllerProvider.notifier);
    final visible = ref.watch(visibleRadioStationsProvider);
    final queue = visible.isEmpty ? RadioStation.available : visible;
    final station = radio.station;

    final status = switch (radio.status) {
      RadioStatus.connecting => 'جارٍ الاتصال…',
      RadioStatus.buffering => 'جارٍ التحميل…',
      RadioStatus.playing => 'بث مباشر',
      RadioStatus.offline => 'لا يوجد اتصال بالإنترنت',
      RadioStatus.error => 'تعذّر التشغيل',
      _ => station?.subtitle ?? 'اضغط تشغيل أو اختر من القائمة',
    };

    return Row(
      children: [
        Container(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.16),
          ),
          child: Center(
            child: RadioEqualizer(
              active: radio.isPlaying,
              color: Colors.white,
              height: 18.h,
              barWidth: 2.5.w,
              bars: 4,
            ),
          ),
        ),
        SizedBox(width: context.insets.sm + 4.w),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                station?.name ?? 'الإذاعة',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              Text(
                status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoundButton(
                icon: HugeIcons.strokeRoundedPrevious,
                tooltip: 'الإذاعة السابقة',
                size: 38.w,
                onPressed: () => controller.previous(queue),
              ),
              SizedBox(width: 6.w),
              _MiniPlayButton(
                radio: radio,
                onPressed: () => controller.toggle(queue),
              ),
              SizedBox(width: 6.w),
              _RoundButton(
                icon: HugeIcons.strokeRoundedNext,
                tooltip: 'الإذاعة التالية',
                size: 38.w,
                onPressed: () => controller.next(queue),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniPlayButton extends StatelessWidget {
  const _MiniPlayButton({required this.radio, required this.onPressed});

  final RadioState radio;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = 46.w;
    final primary = context.colors.primary;
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (radio.isLoading)
                SizedBox(
                  width: size - 8.w,
                  height: size - 8.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primary.withValues(alpha: 0.5),
                  ),
                ),
              AppIcon(
                radio.isActive
                    ? HugeIcons.strokeRoundedPause
                    : HugeIcons.strokeRoundedPlay,
                size: 24.w,
                color: primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> openRadioSleepTimer(
  BuildContext context,
  RadioController controller,
  RadioState radio,
) async {
  final choice = await RadioSleepTimerSheet.show(
    context,
    timerActive: radio.sleepEndsAt != null,
  );
  if (choice == null) return;
  if (choice == Duration.zero) {
    controller.setSleepTimer(null);
    showToast(text: 'تم إلغاء مؤقت النوم');
  } else {
    controller.setSleepTimer(choice);
    showToast(
      text: 'سيتوقف البث بعد ${choice.inMinutes} دقيقة',
      state: ToastStates.SUCCESS,
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.radio, required this.onSleepTap});

  final RadioState radio;
  final VoidCallback onSleepTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusPill(status: radio.status),
        const Spacer(),
        if (radio.sleepEndsAt != null)
          _SleepCountdown(endsAt: radio.sleepEndsAt!, onTap: onSleepTap),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final RadioStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, dot) = switch (status) {
      RadioStatus.idle => ('جاهز للتشغيل', Colors.white54),
      RadioStatus.connecting => ('جارٍ الاتصال…', context.colors.secondary),
      RadioStatus.buffering => ('جارٍ التحميل…', context.colors.secondary),
      RadioStatus.playing => ('بث مباشر', context.colors.error),
      RadioStatus.paused => ('متوقف', Colors.white54),
      RadioStatus.offline => ('لا يوجد اتصال', context.colors.error),
      RadioStatus.error => ('تعذّر التشغيل', context.colors.error),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.insets.sm + 2.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: context.textStyles.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepCountdown extends StatelessWidget {
  const _SleepCountdown({required this.endsAt, required this.onTap});

  final DateTime endsAt;
  final VoidCallback onTap;

  static String _format(Duration d) {
    final totalSeconds = d.inSeconds < 0 ? 0 : d.inSeconds;
    final h = totalSeconds ~/ 3600;
    final m = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.corners.xl),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.insets.sm + 2.w,
          vertical: 5.h,
        ),
        decoration: BoxDecoration(
          color: context.colors.secondary.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(context.corners.xl),
          border: Border.all(
            color: context.colors.secondary.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              HugeIcons.strokeRoundedMoon02,
              size: 14.w,
              color: Colors.white,
            ),
            SizedBox(width: 6.w),
            StreamBuilder<int>(
              stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
              builder: (context, _) => Text(
                _format(endsAt.difference(DateTime.now())),
                style: context.textStyles.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.radio, required this.category});

  final RadioState radio;
  final RadioCategory? category;

  @override
  Widget build(BuildContext context) {
    final size = 84.w;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.14),
            border: Border.all(
              color: Colors.white.withValues(alpha: radio.isPlaying ? 0.6 : 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(
                  alpha: radio.isPlaying ? 0.22 : 0,
                ),
                blurRadius: 28.r,
                spreadRadius: 4.r,
              ),
            ],
          ),
          child: Center(
            child: AppIcon(
              category?.icon ?? HugeIcons.strokeRoundedRadio01,
              size: 38.w,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: context.insets.sm + 2.w),
        RadioEqualizer(
          active: radio.isPlaying,
          color: Colors.white.withValues(alpha: 0.85),
          height: 22.h,
          barWidth: 3.w,
        ),
      ],
    );
  }
}

class _Titles extends StatelessWidget {
  const _Titles({required this.radio});

  final RadioState radio;

  @override
  Widget build(BuildContext context) {
    final station = radio.station;
    return Column(
      children: [
        Text(
          station?.name ?? 'اختر إذاعة للاستماع',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textStyles.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          station == null
              ? 'اضغط تشغيل أو اختر من القائمة'
              : station.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

/// Explains offline / error states and offers a retry. Takes no space when the
/// radio is working normally.
class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.radio, required this.onRetry});

  final RadioState radio;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final message = switch (radio.status) {
      RadioStatus.offline =>
        'لا يوجد اتصال بالإنترنت. سيعود البث تلقائياً عند توفر الاتصال.',
      RadioStatus.error =>
        'تعذّر الاتصال بهذه الإذاعة. حاول مرة أخرى أو اختر إذاعة أخرى.',
      _ => null,
    };

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      alignment: Alignment.topCenter,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: EdgeInsets.only(top: context.insets.sm),
              child: Column(
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                  if (radio.status == RadioStatus.error && onRetry != null)
                    TextButton.icon(
                      onPressed: onRetry,
                      icon: AppIcon(
                        HugeIcons.strokeRoundedRefresh,
                        size: 18.w,
                        color: Colors.white,
                      ),
                      label: const Text('إعادة المحاولة'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.radio,
    required this.isFavorite,
    required this.onFavorite,
    required this.onToggle,
    required this.onNext,
    required this.onPrevious,
    required this.onSleep,
  });

  final RadioState radio;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final VoidCallback onToggle;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSleep;

  @override
  Widget build(BuildContext context) {
    // Transport controls keep their left-to-right order in Arabic, like every
    // media player: previous on the left, next on the right.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundButton(
            icon: HugeIcons.strokeRoundedMoon02,
            tooltip: 'مؤقت النوم',
            highlighted: radio.sleepEndsAt != null,
            onPressed: onSleep,
          ),
          _RoundButton(
            icon: HugeIcons.strokeRoundedPrevious,
            tooltip: 'الإذاعة السابقة',
            size: 48.w,
            onPressed: onPrevious,
          ),
          _PlayButton(radio: radio, onPressed: onToggle),
          _RoundButton(
            icon: HugeIcons.strokeRoundedNext,
            tooltip: 'الإذاعة التالية',
            size: 48.w,
            onPressed: onNext,
          ),
          _RoundButton(
            icon: HugeIcons.strokeRoundedFavourite,
            tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
            highlighted: isFavorite,
            filled: isFavorite,
            onPressed: onFavorite,
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size,
    this.highlighted = false,
    this.filled = false,
  });

  final AppIconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double? size;
  final bool highlighted;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final box = size ?? 44.w;
    final active = highlighted
        ? context.colors.secondary
        : Colors.white.withValues(alpha: 0.9);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: highlighted ? 0.2 : 0.12),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: box,
            height: box,
            child: Center(
              child: filled
                  ? Icon(Icons.favorite_rounded, size: 22.w, color: active)
                  : AppIcon(icon, size: 22.w, color: active),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.radio, required this.onPressed});

  final RadioState radio;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = 68.w;
    final primary = context.colors.primary;
    return Semantics(
      button: true,
      label: radio.isActive ? 'إيقاف' : 'تشغيل',
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (radio.isLoading)
                  SizedBox(
                    width: size - 10.w,
                    height: size - 10.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: primary.withValues(alpha: 0.5),
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: AppIcon(
                    radio.isActive
                        ? HugeIcons.strokeRoundedPause
                        : HugeIcons.strokeRoundedPlay,
                    key: ValueKey(radio.isActive),
                    size: 32.w,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
