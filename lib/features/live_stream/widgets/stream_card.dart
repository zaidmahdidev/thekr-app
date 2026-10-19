import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import '../models/live_stream_model.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// A channel in the list: YouTube thumbnail, live badge, title and description.
class StreamCard extends StatelessWidget {
  const StreamCard({
    super.key,
    required this.stream,
    required this.isSelected,
    required this.onTap,
  });

  final LiveStream stream;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: context.insets.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.xl),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.all(context.insets.sm + 2.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? accent.withValues(alpha: 0.06)
                  : context.colors.surface,
              borderRadius: BorderRadius.circular(context.corners.xl),
              border: Border.all(
                color: isSelected ? accent : accent.withValues(alpha: 0.1),
                width: isSelected ? 1.6 : 1,
              ),
              boxShadow: isSelected ? context.shadows.low : null,
            ),
            child: Row(
              children: [
                _Thumbnail(stream: stream),
                SizedBox(width: context.insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stream.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.titleSmall?.copyWith(
                          color: isSelected
                              ? accent
                              : context.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                        ),
                      ),
                      if (stream.description != null) ...[
                        SizedBox(height: 3.h),
                        Text(
                          stream.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: context.insets.sm),
                AppIcon(
                  isSelected
                      ? HugeIcons.strokeRoundedAudioWave01
                      : HugeIcons.strokeRoundedPlayCircle,
                  color: isSelected
                      ? accent
                      : context.colors.textSecondary.withValues(alpha: 0.6),
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.stream});

  final LiveStream stream;

  @override
  Widget build(BuildContext context) {
    final width = 104.w;
    final height = width * 9 / 16;

    final fallback = Container(
      color: context.colors.primary.withValues(alpha: 0.12),
      child: AppIcon(
        HugeIcons.strokeRoundedTv01,
        color: context.colors.primary,
        size: 26.sp,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(context.corners.lg),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (stream.youtubeId.isEmpty)
              fallback
            else
              Image.network(
                'https://img.youtube.com/vi/${stream.youtubeId}/mqdefault.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback,
              ),
            PositionedDirectional(
              top: 5.h,
              start: 5.w,
              child: const LiveBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small red "مباشر" badge.
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(context.corners.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: context.colors.error,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'مباشر',
            style: context.textStyles.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
