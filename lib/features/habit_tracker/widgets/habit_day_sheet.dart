import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/app_digits.dart';
import 'package:thekr_app/core/widgets/app_button.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/habit_tracker/models/daily_habit_model.dart';
import 'package:thekr_app/features/habit_tracker/providers/habit_tracker_provider.dart';

/// Opens the sheet to tick what was done on [date] (a day of the calendar).
Future<void> showHabitDaySheet(BuildContext context, DateTime date) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _HabitDaySheet(date: date),
  );
}

class _HabitDaySheet extends ConsumerWidget {
  const _HabitDaySheet({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    ref.watch(habitTrackerProvider); // read the day again after each tick
    final notifier = ref.read(habitTrackerProvider.notifier);
    final habit = notifier.habitFor(date);
    final title = AppDigits.latin(
      DateFormat('EEEE، d MMMM yyyy', 'ar').format(date),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.corners.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: context.insets.sm),
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(context.corners.sm),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.insets.md,
                vertical: context.insets.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: context.textStyles.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${AppDigits.of(habit.fardCount)} من ${AppDigits.of(5)}',
                    style: context.textStyles.titleSmall?.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: context.insets.md),
                children: [
                  for (final field in HabitField.fard)
                    _FieldRow(
                      label: field.label,
                      done: habit.isDone(field),
                      muted: false,
                      onTap: () => notifier.toggle(date, field),
                    ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: context.insets.md,
                      bottom: 2.h,
                    ),
                    child: Text(
                      'النوافل والأذكار',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  for (final field in HabitField.extras)
                    _FieldRow(
                      label: field.label,
                      done: habit.isDone(field),
                      muted: true,
                      onTap: () => notifier.toggle(date, field),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(context.insets.md),
              child: AppButton(
                text: 'تم',
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.done,
    required this.muted,
    required this.onTap,
  });

  final String label;
  final bool done;

  /// An extra act (not one of the five prayers): drawn a little quieter.
  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Material(
        color: done
            ? colors.primary.withValues(alpha: 0.1)
            : colors.primary.withValues(alpha: muted ? 0.03 : 0.05),
        borderRadius: BorderRadius.circular(context.corners.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.lg),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.insets.md,
              vertical: context.insets.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: context.textStyles.bodyLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: muted ? FontWeight.w500 : FontWeight.bold,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: done ? colors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(context.corners.md),
                    border: Border.all(
                      color: done
                          ? colors.primary
                          : colors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: done
                      ? Center(
                          child: AppIcon(
                            HugeIcons.strokeRoundedTick02,
                            size: 18.sp,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
