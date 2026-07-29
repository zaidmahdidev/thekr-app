import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/core/widgets/base_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:thekr_app/features/habit_tracker/providers/habit_tracker_provider.dart';
import 'package:thekr_app/features/habit_tracker/widgets/habit_category_card.dart';

@RoutePage()
class HabitTrackerScreen extends ConsumerStatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  ConsumerState<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends ConsumerState<HabitTrackerScreen> {
  final ScrollController _dateScrollController = ScrollController();
  final List<DateTime> _dates = [];

  @override
  void initState() {
    super.initState();
    _generateDates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _generateDates() {
    final today = DateTime.now();
    for (int i = 30; i >= 0; i--) {
      _dates.add(today.subtract(Duration(days: i)));
    }
  }

  void _scrollToSelectedDate() {
    if (_dates.isNotEmpty && _dateScrollController.hasClients) {
      _dateScrollController.animateTo(
        _dateScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitTrackerProvider);
    final habitNotifier = ref.read(habitTrackerProvider.notifier);
    final habit = habitState.habit;

    return AppScaffold(
      appBar: BaseAppBar(
        title: 'متتبع العبادات',
        showBlur: true,
        actions: [
          Center(
            child: Container(
              margin: EdgeInsets.only(left: context.insets.md),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(context.corners.xl),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Text(
                    '${habitState.currentStreak}',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text('🔥', style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Dates Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: context.insets.lg),
              child: SizedBox(
                height: 90.h,
                child: ListView.builder(
                  controller: _dateScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: context.insets.md),
                  itemCount: _dates.length,
                  itemBuilder: (context, index) {
                    final date = _dates[index];
                    final isSelected = DateUtils.isSameDay(date, habitState.selectedDate);
                    return _buildDateCard(context, date, isSelected, () {
                      habitNotifier.selectDate(date);
                    });
                  },
                ),
              ),
            ),
          ),
          
          // Progress Ring
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(context.insets.lg),
              child: Container(
                padding: EdgeInsets.all(context.insets.lg),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(context.corners.xl),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      blurRadius: 20.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80.w,
                      height: 80.w,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: habit.progress,
                            strokeWidth: 8.w,
                            backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(context.colors.secondary),
                            strokeCap: StrokeCap.round,
                          ),
                          Center(
                            child: Text(
                              '${(habit.progress * 100).toInt()}%',
                              style: context.textStyles.titleLarge?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.insets.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إنجاز اليوم',
                            style: context.textStyles.titleMedium?.copyWith(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            habit.progress == 1.0 
                              ? 'ما شاء الله! لقد أتممت جميع عباداتك اليوم.'
                              : 'استمر! لقد أتممت ${habit.completedCount} من أصل ${habit.totalHabits} طاعات.',
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.textPrimary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Habit Lists
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: context.insets.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                HabitCategoryCard(
                  title: 'الصلوات المفروضة',
                  icon: Icons.mosque_rounded,
                  color: const Color(0xff16a085),
                  items: [
                    HabitItemData(title: 'صلاة الفجر', isDone: habit.fajr, onToggle: habitNotifier.toggleFajr),
                    HabitItemData(title: 'صلاة الظهر', isDone: habit.dhuhr, onToggle: habitNotifier.toggleDhuhr),
                    HabitItemData(title: 'صلاة العصر', isDone: habit.asr, onToggle: habitNotifier.toggleAsr),
                    HabitItemData(title: 'صلاة المغرب', isDone: habit.maghrib, onToggle: habitNotifier.toggleMaghrib),
                    HabitItemData(title: 'صلاة العشاء', isDone: habit.isha, onToggle: habitNotifier.toggleIsha),
                  ],
                ),
                HabitCategoryCard(
                  title: 'النوافل والسنن',
                  icon: Icons.brightness_3_rounded,
                  color: const Color(0xff8e44ad),
                  items: [
                    HabitItemData(title: 'السنن الرواتب (12 ركعة)', isDone: habit.rawatib, onToggle: habitNotifier.toggleRawatib),
                    HabitItemData(title: 'قيام الليل / الوتر', isDone: habit.qiyam, onToggle: habitNotifier.toggleQiyam),
                  ],
                ),
                HabitCategoryCard(
                  title: 'القرآن والأذكار',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xffe67e22),
                  items: [
                    HabitItemData(title: 'الورد القرآني', isDone: habit.quranWird, onToggle: habitNotifier.toggleQuranWird),
                    HabitItemData(title: 'أذكار الصباح', isDone: habit.morningAzkar, onToggle: habitNotifier.toggleMorningAzkar),
                    HabitItemData(title: 'أذكار المساء', isDone: habit.eveningAzkar, onToggle: habitNotifier.toggleEveningAzkar),
                  ],
                ),
                SizedBox(height: context.insets.xl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(BuildContext context, DateTime date, bool isSelected, VoidCallback onTap) {
    final dayName = DateFormat.E('ar').format(date);
    final dayNumber = date.day.toString();
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 65.w,
        margin: EdgeInsets.only(right: context.insets.sm),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : context.colors.surface,
          borderRadius: BorderRadius.circular(context.corners.lg),
          border: Border.all(
            color: isSelected ? context.colors.primary : context.colors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.3),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: context.textStyles.bodySmall?.copyWith(
                color: isSelected ? Colors.white : context.colors.textPrimary.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              dayNumber,
              style: context.textStyles.titleLarge?.copyWith(
                color: isSelected ? Colors.white : context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
