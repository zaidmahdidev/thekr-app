import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/brand_surface.dart';
import 'package:thekr_app/features/habit_tracker/models/daily_habit_model.dart';

/// Hero card of the habit tracker: the day's progress ring and the key numbers.
class HabitSummaryCard extends StatelessWidget {
  const HabitSummaryCard({
    super.key,
    required this.habit,
    required this.isToday,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalPoints,
  });

  final DailyHabit habit;
  final bool isToday;
  final int currentStreak;
  final int bestStreak;
  final int totalPoints;

  @override
  Widget build(BuildContext context) {
    final style = BrandSurfaceStyle.of(context);
    final done = habit.progress >= 1.0;

    return BrandSurface(
      padding: EdgeInsets.all(context.insets.md),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 84.w,
                height: 84.w,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: habit.progress),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8.w,
                        backgroundColor: style.controlBackground,
                        valueColor: AlwaysStoppedAnimation(style.gold),
                        strokeCap: StrokeCap.round,
                      ),
                      Center(
                        child: Text(
                          '${QuranText.digits((value * 100).round())}٪',
                          style: context.textStyles.titleLarge?.copyWith(
                            color: style.text,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: context.insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? 'إنجاز اليوم' : 'إنجاز هذا اليوم',
                      style: context.textStyles.titleMedium?.copyWith(
                        color: style.text,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      done
                          ? 'ما شاء الله! أتممت جميع الطاعات'
                          : 'أتممت ${QuranText.digits(habit.completedCount)} من ${QuranText.digits(habit.totalHabits)} طاعات',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: style.textMuted,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          size: 15.sp,
                          color: style.gold,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${QuranText.digits(habit.totalPoints)} نقطة اليوم',
                          style: context.textStyles.labelMedium?.copyWith(
                            color: style.text,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.insets.md),
          Row(
            children: [
              _Stat(
                icon: Icons.local_fire_department_rounded,
                value: currentStreak,
                label: 'أيام متتالية',
                style: style,
              ),
              SizedBox(width: context.insets.sm),
              _Stat(
                icon: Icons.emoji_events_rounded,
                value: bestStreak,
                label: 'أفضل سلسلة',
                style: style,
              ),
              SizedBox(width: context.insets.sm),
              _Stat(
                icon: Icons.workspace_premium_rounded,
                value: totalPoints,
                label: 'إجمالي النقاط',
                style: style,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.style,
  });

  final IconData icon;
  final int value;
  final String label;
  final BrandSurfaceStyle style;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.insets.sm),
        decoration: BoxDecoration(
          color: style.controlBackground,
          borderRadius: BorderRadius.circular(context.corners.lg),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18.sp, color: style.gold),
            SizedBox(height: 2.h),
            Text(
              QuranText.digits(value),
              style: context.textStyles.titleMedium?.copyWith(
                color: style.text,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              style: context.textStyles.labelSmall?.copyWith(
                color: style.textMuted,
                fontSize: 9.5.sp,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
