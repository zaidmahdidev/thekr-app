import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/utils/app_digits.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/habit_tracker/models/daily_habit_model.dart';
import 'package:thekr_app/features/habit_tracker/providers/habit_tracker_provider.dart';

/// A slim strip for the home screen: the five prayers of today as round
/// buttons, ticked with one tap, and a link to the full record.
class HomeHabitsCard extends ConsumerWidget {
  const HomeHabitsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(habitTrackerProvider);
    final notifier = ref.read(habitTrackerProvider.notifier);
    final today = DateUtils.dateOnly(DateTime.now());
    final habit = notifier.habitFor(today);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.insets.md,
        vertical: context.insets.sm,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          context.insets.md,
          context.insets.sm + 2.h,
          context.insets.md,
          context.insets.md,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(context.corners.xl),
          boxShadow: context.shadows.low,
          border: Border.all(color: colors.primary.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          habit.isFardComplete
                              ? 'أتممتَ صلواتك، تقبّل الله'
                              : 'صلواتك اليوم',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.titleSmall?.copyWith(
                            color: habit.isFardComplete
                                ? colors.success
                                : colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: context.insets.sm),
                      _Count(done: habit.fardCount),
                      if (state.currentStreak > 0) ...[
                        SizedBox(width: context.insets.sm),
                        _Streak(days: state.currentStreak),
                      ],
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(context.corners.md),
                  onTap: () => context.router.push(const HabitTrackerRoute()),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 4.h,
                    ),
                    child: Text(
                      'السجل',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.insets.sm + 2.h),
            Row(
              children: [
                for (final field in HabitField.fard)
                  Expanded(
                    child: _PrayerButton(
                      label: field.label,
                      done: habit.isDone(field),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        notifier.toggle(today, field);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerButton extends StatelessWidget {
  const _PrayerButton({
    required this.label,
    required this.done,
    required this.onTap,
  });

  final String label;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done
                  ? colors.primary
                  : colors.primary.withValues(alpha: 0.06),
              border: Border.all(
                color: done
                    ? colors.primary
                    : colors.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: done
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.3),
                        blurRadius: 8.r,
                        offset: Offset(0, 3.h),
                      ),
                    ]
                  : null,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: done
                  ? AppIcon(
                      HugeIcons.strokeRoundedTick02,
                      key: const ValueKey('done'),
                      size: 22.sp,
                      color: onPrimary,
                    )
                  : const SizedBox.shrink(key: ValueKey('open')),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            maxLines: 1,
            style: context.textStyles.bodySmall?.copyWith(
              color: done ? colors.primary : colors.textSecondary,
              fontWeight: done ? FontWeight.bold : FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.done});

  final int done;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.corners.xl),
      ),
      child: Text(
        '${AppDigits.of(done)} من ${AppDigits.of(5)}',
        style: context.textStyles.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
    );
  }
}

class _Streak extends StatelessWidget {
  const _Streak({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.secondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(HugeIcons.strokeRoundedFire, size: 16.sp, color: color),
        SizedBox(width: 2.w),
        Text(
          AppDigits.of(days),
          style: context.textStyles.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
