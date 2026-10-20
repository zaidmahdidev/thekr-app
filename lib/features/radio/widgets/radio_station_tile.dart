import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import '../models/radio_station.dart';
import 'radio_equalizer.dart';

/// One station in the list. The station that is on air gets an accent border
/// and a live equalizer.
class RadioStationTile extends StatelessWidget {
  const RadioStationTile({
    super.key,
    required this.station,
    required this.isCurrent,
    required this.isPlaying,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  final RadioStation station;
  final bool isCurrent;
  final bool isPlaying;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: context.insets.sm + 2.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.lg),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(
              horizontal: context.insets.sm + 2.w,
              vertical: context.insets.sm,
            ),
            decoration: BoxDecoration(
              color: isCurrent
                  ? primary.withValues(alpha: 0.08)
                  : context.colors.surface,
              borderRadius: BorderRadius.circular(context.corners.lg),
              border: Border.all(
                color: isCurrent
                    ? primary.withValues(alpha: 0.55)
                    : context.colors.textSecondary.withValues(alpha: 0.12),
                width: isCurrent ? 1.4 : 1,
              ),
              boxShadow: isCurrent ? null : context.shadows.low,
            ),
            child: Row(
              children: [
                _Leading(station: station, isCurrent: isCurrent),
                SizedBox(width: context.insets.sm + 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.titleSmall?.copyWith(
                          color: isCurrent
                              ? primary
                              : context.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                      Text(
                        station.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 4.w),
                    child: RadioEqualizer(
                      active: isPlaying,
                      color: primary,
                      height: 18.h,
                      barWidth: 2.5.w,
                      bars: 4,
                    ),
                  ),
                IconButton(
                  onPressed: onFavorite,
                  tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 22.w,
                    color: isFavorite
                        ? context.colors.error
                        : context.colors.textSecondary.withValues(alpha: 0.7),
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

class _Leading extends StatelessWidget {
  const _Leading({required this.station, required this.isCurrent});

  final RadioStation station;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isCurrent
            ? LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [primary, primary.withValues(alpha: 0.75)],
              )
            : null,
        color: isCurrent ? null : primary.withValues(alpha: 0.1),
      ),
      child: Center(
        child: AppIcon(
          station.category.icon,
          size: 22.w,
          color: isCurrent ? Colors.white : primary,
        ),
      ),
    );
  }
}
