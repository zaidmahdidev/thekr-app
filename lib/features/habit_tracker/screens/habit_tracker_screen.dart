import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/core/widgets/base_app_bar.dart';
import 'package:thekr_app/features/habit_tracker/providers/habit_tracker_provider.dart';
import 'package:thekr_app/features/habit_tracker/widgets/habit_day_sheet.dart';
import 'package:thekr_app/features/habit_tracker/widgets/habit_month_breakdown.dart';
import 'package:thekr_app/features/habit_tracker/widgets/habit_month_calendar.dart';
import 'package:thekr_app/features/habit_tracker/widgets/habit_stats_card.dart';
import 'package:thekr_app/features/habit_tracker/widgets/habit_today_card.dart';

/// Worship tracker. Today's prayers are ticked right at the top; below, the
/// month shows at a glance which days were full, and any day can be opened to
/// fix it.
@RoutePage()
class HabitTrackerScreen extends ConsumerStatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  ConsumerState<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends ConsumerState<HabitTrackerScreen> {
  late DateTime _month = _firstOfMonth(DateTime.now());

  static DateTime _firstOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  void _moveMonth(int by) =>
      setState(() => _month = DateTime(_month.year, _month.month + by));

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(habitTrackerProvider);
    final notifier = ref.read(habitTrackerProvider.notifier);
    final today = DateUtils.dateOnly(DateTime.now());
    final isCurrentMonth = _month == _firstOfMonth(today);

    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    var fullDays = 0;
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_month.year, _month.month, day);
      if (!date.isAfter(today) && notifier.habitFor(date).isFardComplete) {
        fullDays++;
      }
    }

    return AppScaffold(
      appBar: const BaseAppBar(title: 'متتبع العبادات', showBlur: true),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.insets.md,
          context.insets.sm,
          context.insets.md,
          context.insets.xl,
        ),
        children: [
          HabitStatsCard(
            currentStreak: state.currentStreak,
            bestStreak: state.bestStreak,
            fullDays: fullDays,
          ),
          SizedBox(height: context.insets.md),
          HabitTodayCard(
            habit: notifier.habitFor(today),
            onToggle: (field) {
              HapticFeedback.selectionClick();
              notifier.toggle(today, field);
            },
          ),
          SizedBox(height: context.insets.md),
          _Card(
            child: Column(
              children: [
                HabitMonthCalendar(
                  month: _month,
                  today: today,
                  habitFor: notifier.habitFor,
                  onPrevious: () => _moveMonth(-1),
                  onNext: isCurrentMonth ? null : () => _moveMonth(1),
                  onDayTap: (date) => showHabitDaySheet(context, date),
                ),
                if (!isCurrentMonth)
                  TextButton(
                    onPressed: () =>
                        setState(() => _month = _firstOfMonth(today)),
                    child: const Text('العودة إلى هذا الشهر'),
                  ),
              ],
            ),
          ),
          SizedBox(height: context.insets.md),
          _Card(
            child: HabitMonthBreakdown(
              month: _month,
              today: today,
              habitFor: notifier.habitFor,
            ),
          ),
        ],
      ),
    );
  }
}

/// A soft white card, the same as the one holding today's prayers.
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        boxShadow: context.shadows.low,
      ),
      child: child,
    );
  }
}
