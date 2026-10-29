import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/core/widgets/base_app_bar.dart';
import 'package:thekr_app/features/calendar/services/calendar_service.dart';
import 'package:thekr_app/features/habit_tracker/providers/habit_tracker_provider.dart';
import 'package:thekr_app/features/habit_tracker/widgets/habit_category_card.dart';
import 'package:thekr_app/features/habit_tracker/widgets/habit_summary_card.dart';
import 'package:thekr_app/features/habit_tracker/widgets/habit_week_chart.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/utils/app_digits.dart';

/// Worship tracker: pick a day, tick what you did, and follow your progress,
/// streak and points.
@RoutePage()
class HabitTrackerScreen extends ConsumerStatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  ConsumerState<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends ConsumerState<HabitTrackerScreen> {
  final ScrollController _dateScrollController = ScrollController();
  late final List<DateTime> _dates = _generateDates();

  static List<DateTime> _generateDates() {
    final today = DateTime.now();
    return [
      for (int i = HabitTrackerNotifier.historyDays - 1; i >= 0; i--)
        today.subtract(Duration(days: i)),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dateScrollController.hasClients) {
        _dateScrollController.jumpTo(
          _dateScrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(habitTrackerProvider);
    final notifier = ref.read(habitTrackerProvider.notifier);
    final habit = state.habit;
    final isToday = DateUtils.isSameDay(state.selectedDate, DateTime.now());

    return AppScaffold(
      appBar: BaseAppBar(
        title: 'متتبع العبادات',
        showBlur: true,
        actions: [_StreakBadge(days: state.currentStreak)],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _DateSelector(
              dates: _dates,
              progress: state.recentProgress,
              selected: state.selectedDate,
              controller: _dateScrollController,
              onSelected: notifier.selectDate,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              context.insets.md,
              context.insets.sm,
              context.insets.md,
              context.insets.xl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                HabitSummaryCard(
                  habit: habit,
                  isToday: isToday,
                  currentStreak: state.currentStreak,
                  bestStreak: state.bestStreak,
                  totalPoints: state.totalAllTimePoints,
                ),
                SizedBox(height: context.insets.md),
                HabitWeekChart(
                  progress: state.recentProgress,
                  average: state.weeklyAverage,
                  selectedDate: state.selectedDate,
                  onSelected: notifier.selectDate,
                ),
                SizedBox(height: context.insets.md),
                HabitCategoryCard(
                  title: 'الصلوات المفروضة',
                  icon: HugeIcons.strokeRoundedMosque01,
                  color: context.colors.primary,
                  items: [
                    HabitItemData(
                      title: 'صلاة الفجر',
                      isDone: habit.fajr,
                      onToggle: notifier.toggleFajr,
                      points: 10,
                    ),
                    HabitItemData(
                      title: 'صلاة الظهر',
                      isDone: habit.dhuhr,
                      onToggle: notifier.toggleDhuhr,
                      points: 10,
                    ),
                    HabitItemData(
                      title: 'صلاة العصر',
                      isDone: habit.asr,
                      onToggle: notifier.toggleAsr,
                      points: 10,
                    ),
                    HabitItemData(
                      title: 'صلاة المغرب',
                      isDone: habit.maghrib,
                      onToggle: notifier.toggleMaghrib,
                      points: 10,
                    ),
                    HabitItemData(
                      title: 'صلاة العشاء',
                      isDone: habit.isha,
                      onToggle: notifier.toggleIsha,
                      points: 10,
                    ),
                  ],
                ),
                HabitCategoryCard(
                  title: 'النوافل والسنن',
                  icon: HugeIcons.strokeRoundedMoon02,
                  color: context.colors.secondary,
                  items: [
                    HabitItemData(
                      title: 'السنن الرواتب (12 ركعة)',
                      isDone: habit.rawatib,
                      onToggle: notifier.toggleRawatib,
                      points: 15,
                    ),
                    HabitItemData(
                      title: 'قيام الليل / الوتر',
                      isDone: habit.qiyam,
                      onToggle: notifier.toggleQiyam,
                      points: 15,
                    ),
                  ],
                ),
                HabitCategoryCard(
                  title: 'القرآن والأذكار',
                  icon: HugeIcons.strokeRoundedBookOpen01,
                  color: context.colors.success,
                  items: [
                    HabitItemData(
                      title: 'الورد القرآني',
                      isDone: habit.quranWird,
                      onToggle: notifier.toggleQuranWird,
                      points: 10,
                    ),
                    HabitItemData(
                      title: 'أذكار الصباح',
                      isDone: habit.morningAzkar,
                      onToggle: notifier.toggleMorningAzkar,
                      points: 10,
                    ),
                    HabitItemData(
                      title: 'أذكار المساء',
                      isDone: habit.eveningAzkar,
                      onToggle: notifier.toggleEveningAzkar,
                      points: 10,
                    ),
                  ],
                ),
                Text(
                  'إكمال جميع الطاعات في اليوم يمنحك ${AppDigits.of(40)} نقطة إضافية.',
                  textAlign: TextAlign.center,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.secondary;

    return Center(
      child: Tooltip(
        message: 'أيام متتالية بإتمام الصلوات الخمس',
        child: Container(
          margin: EdgeInsetsDirectional.only(end: context.insets.sm),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(context.corners.xl),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                HugeIcons.strokeRoundedFire,
                size: 18.sp,
                color: color,
              ),
              SizedBox(width: 4.w),
              Text(
                AppDigits.of(days),
                style: context.textStyles.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal list of the last days. A small bar under each day shows how much
/// of that day was completed.
class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.dates,
    required this.progress,
    required this.selected,
    required this.controller,
    required this.onSelected,
  });

  final List<DateTime> dates;
  final List<double> progress;
  final DateTime selected;
  final ScrollController controller;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92.h,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: context.insets.md,
          vertical: context.insets.sm,
        ),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final value = index < progress.length ? progress[index] : 0.0;
          return _DateCard(
            date: date,
            progress: value,
            isSelected: DateUtils.isSameDay(date, selected),
            isToday: index == dates.length - 1,
            onTap: () => onSelected(date),
          );
        },
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.date,
    required this.progress,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final double progress;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dayName = CalendarService.weekdayNames[(date.weekday + 1) % 7];
    final onColor = isSelected
        ? context.colors.surface
        : context.colors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 62.w,
        margin: EdgeInsetsDirectional.only(end: context.insets.sm),
        padding: EdgeInsets.symmetric(vertical: context.insets.sm),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : context.colors.surface,
          borderRadius: BorderRadius.circular(context.corners.lg),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : isToday
                ? context.colors.secondary
                : context.colors.primary.withValues(alpha: 0.12),
            width: isToday && !isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.3),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isToday ? 'اليوم' : dayName,
                style: context.textStyles.labelMedium?.copyWith(
                  color: onColor.withValues(alpha: isSelected ? 0.85 : 0.6),
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
            Text(
              AppDigits.of(date.day),
              style: context.textStyles.titleLarge?.copyWith(
                color: isSelected
                    ? context.colors.surface
                    : context.colors.primary,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: 30.w,
              height: 4.h,
              decoration: BoxDecoration(
                color:
                    (isSelected
                            ? context.colors.surface
                            : context.colors.primary)
                        .withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: progress >= 1.0
                        ? context.colors.secondary
                        : (isSelected
                              ? context.colors.surface
                              : context.colors.primary),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
