import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/app_digits.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/habit_tracker/models/daily_habit_model.dart';
import 'package:thekr_app/features/habit_tracker/widgets/habit_chip.dart';

/// Today: the five prayers to tick with one tap. The sunan, qiyam, wird and
/// adhkar sit in one line below that opens when wanted, so the card stays small.
class HabitTodayCard extends StatefulWidget {
  const HabitTodayCard({
    super.key,
    required this.habit,
    required this.onToggle,
  });

  final DailyHabit habit;
  final ValueChanged<HabitField> onToggle;

  @override
  State<HabitTodayCard> createState() => _HabitTodayCardState();
}

class _HabitTodayCardState extends State<HabitTodayCard> {
  bool _extrasOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final habit = widget.habit;
    final extrasDone = HabitField.extras.where(habit.isDone).length;

    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        boxShadow: context.shadows.low,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  habit.isFardComplete
                      ? 'يومك: أتممتَ صلواتك، تقبّل الله منك'
                      : 'يومك: علّم ما أدّيته',
                  style: context.textStyles.titleSmall?.copyWith(
                    color: habit.isFardComplete
                        ? colors.success
                        : colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _CountPill(done: habit.fardCount, total: 5),
            ],
          ),
          SizedBox(height: context.insets.sm),
          Row(
            children: [
              for (final field in HabitField.fard)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: HabitChip(
                      label: field.label,
                      done: habit.isDone(field),
                      onTap: () => widget.onToggle(field),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.insets.sm),
          InkWell(
            borderRadius: BorderRadius.circular(context.corners.md),
            onTap: () => setState(() => _extrasOpen = !_extrasOpen),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'النوافل والأذكار',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${AppDigits.of(extrasDone)} من ${AppDigits.of(HabitField.extras.length)}',
                    style: context.textStyles.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  AnimatedRotation(
                    turns: _extrasOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: AppIcon(
                      HugeIcons.strokeRoundedArrowDown01,
                      size: 20.sp,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _extrasOpen
                ? Padding(
                    padding: EdgeInsets.only(top: context.insets.sm),
                    child: Wrap(
                      spacing: context.insets.sm,
                      runSpacing: context.insets.sm,
                      children: [
                        for (final field in HabitField.extras)
                          HabitChip(
                            label: field.label,
                            compact: true,
                            done: habit.isDone(field),
                            onTap: () => widget.onToggle(field),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.insets.sm + 4.w,
        vertical: 3.h,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.corners.xl),
      ),
      child: Text(
        '${AppDigits.of(done)} من ${AppDigits.of(total)}',
        style: context.textStyles.bodySmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
