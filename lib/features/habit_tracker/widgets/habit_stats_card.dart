import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/app_digits.dart';
import 'package:thekr_app/core/widgets/hero_pattern.dart';

/// Three numbers at the top: the current streak, the longest one, and the days
/// of the month on which all five prayers were prayed.
class HabitStatsCard extends StatelessWidget {
  const HabitStatsCard({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    required this.fullDays,
  });

  final int currentStreak;
  final int bestStreak;
  final int fullDays;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final hsl = HSLColor.fromColor(primary);
    final darker = hsl
        .withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0))
        .toColor();
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final line = onPrimary.withValues(alpha: 0.25);

    // The same look as the home header and the radio player: the brand
    // gradient with the lattice, so the screen belongs to the app.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.corners.xl),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [primary, darker],
        ),
        boxShadow: context.shadows.medium,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.corners.xl),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(child: HeroPattern(opacity: 0.18)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.insets.md),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    _Stat(
                      value: currentStreak,
                      label: 'السلسلة الحالية',
                      color: onPrimary,
                    ),
                    VerticalDivider(width: 1, thickness: 1, color: line),
                    _Stat(
                      value: bestStreak,
                      label: 'أطول سلسلة',
                      color: onPrimary,
                    ),
                    VerticalDivider(width: 1, thickness: 1, color: line),
                    _Stat(
                      value: fullDays,
                      label: 'أيام كاملة هذا الشهر',
                      color: onPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppDigits.of(value),
            style: context.textStyles.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.insets.sm),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.textStyles.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.85),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
