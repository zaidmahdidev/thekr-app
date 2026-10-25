import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/calendar/services/calendar_service.dart';
import 'package:thekr_app/features/prayer_times/models/prayer_day.dart';
import 'package:thekr_app/features/prayer_times/providers/prayer_times_providers.dart';
import 'package:thekr_app/features/prayer_times/utils/prayer_formatters.dart';
import 'package:thekr_app/features/prayer_times/widgets/prayer_nav_button.dart';

/// Month timetable with Gregorian and Hijri dates. The column titles stay on
/// top while the days scroll, and the month opens scrolled to today.
class PrayerMonthTable extends ConsumerStatefulWidget {
  const PrayerMonthTable({super.key});

  @override
  ConsumerState<PrayerMonthTable> createState() => _PrayerMonthTableState();
}

class _PrayerMonthTableState extends ConsumerState<PrayerMonthTable> {
  final _scrollController = ScrollController();
  final _todayKey = GlobalKey();

  late final DateTime _today = DateUtils.dateOnly(DateTime.now());
  late DateTime _month = DateTime(_today.year, _today.month);

  /// True once the current month has been scrolled to today.
  bool _scrolledToToday = false;

  bool get _isCurrentMonth =>
      _month.year == _today.year && _month.month == _today.month;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _shift(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _scrolledToToday = false;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _goToToday() {
    setState(() {
      _month = DateTime(_today.year, _today.month);
      _scrolledToToday = false;
    });
  }

  void _scrollToTodayOnce() {
    if (_scrolledToToday) return;
    _scrolledToToday = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final todayContext = _todayKey.currentContext;
      if (!mounted || todayContext == null) return;
      Scrollable.ensureVisible(todayContext, alignment: 0.15);
    });
  }

  /// "ربيع الآخر - جمادى الأولى 1448 هـ" for the visible month.
  String _hijriSubtitle(List<PrayerDay> days) {
    final first = CalendarService.hijriOf(days.first.date);
    final last = CalendarService.hijriOf(days.last.date);
    final a = CalendarService.hijriMonthName(first.hMonth);
    final b = CalendarService.hijriMonthName(last.hMonth);
    if (first.hMonth == last.hMonth) return '$a ${first.hYear} هـ';
    return first.hYear == last.hYear
        ? '$a - $b ${last.hYear} هـ'
        : '$a ${first.hYear} - $b ${last.hYear} هـ';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final days = ref.watch(prayerMonthProvider(_month)).value;

    if (days != null && _isCurrentMonth) _scrollToTodayOnce();

    return Column(
      children: [
        Row(
          children: [
            PrayerNavButton(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              tooltip: 'الشهر السابق',
              onTap: () => _shift(-1),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${CalendarService.gregorianMonths[_month.month - 1]} ${_month.year} م',
                    textAlign: TextAlign.center,
                    style: context.textStyles.titleLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  if (days != null && days.isNotEmpty)
                    Text(
                      _hijriSubtitle(days),
                      textAlign: TextAlign.center,
                      style: context.textStyles.labelMedium?.copyWith(
                        color: colors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),
            PrayerNavButton(
              icon: HugeIcons.strokeRoundedArrowRight01,
              tooltip: 'الشهر التالي',
              onTap: () => _shift(1),
            ),
          ],
        ),
        if (!_isCurrentMonth)
          TextButton.icon(
            onPressed: _goToToday,
            icon: AppIcon(HugeIcons.strokeRoundedCalendar03, size: 18.sp),
            label: const Text('العودة لليوم'),
            style: TextButton.styleFrom(foregroundColor: colors.secondary),
          ),
        SizedBox(height: context.insets.sm),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(context.corners.xl),
              border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
              boxShadow: context.shadows.low,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const _HeaderRow(),
                Expanded(
                  child: days == null
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              for (final day in days)
                                _DayRow(
                                  key: day.date == _today ? _todayKey : null,
                                  day: day,
                                  isToday: day.date == _today,
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Column widths: dates are wider than the six time columns.
const _gregorianFlex = 13;
const _hijriFlex = 10;
const _timeFlex = 11;

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.textStyles.labelMedium?.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );

    Widget cell(String text, int flex) => Expanded(
      flex: flex,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: style),
      ),
    );

    return Container(
      color: colors.primary.withValues(alpha: 0.1),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
      child: Row(
        children: [
          cell('ميلادي', _gregorianFlex),
          cell('هجري', _hijriFlex),
          for (final prayer in AppPrayer.values)
            cell(prayer.nameArabic, _timeFlex),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({super.key, required this.day, required this.isToday});

  final PrayerDay day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFriday = day.date.weekday == DateTime.friday;
    final hijri = CalendarService.hijriOf(day.date);
    final nextPrayer = isToday ? day.times.nextPrayer(DateTime.now()) : null;

    final background = isToday
        ? colors.secondary.withValues(alpha: 0.2)
        : isFriday
        ? colors.primary.withValues(alpha: 0.07)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border(
          bottom: BorderSide(color: colors.primary.withValues(alpha: 0.06)),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            flex: _gregorianFlex,
            child: Column(
              children: [
                Text(
                  '${day.date.day}',
                  style: context.textStyles.titleMedium?.copyWith(
                    color: isToday ? colors.secondary : colors.primary,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    PrayerFormatters.weekday(day.date),
                    style: context.textStyles.labelSmall?.copyWith(
                      color: colors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: _hijriFlex,
            child: Column(
              children: [
                Text(
                  '${hijri.hDay}',
                  style: context.textStyles.titleSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                // The month name is shown on the first day of each month.
                if (hijri.hDay == 1)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CalendarService.hijriMonthName(hijri.hMonth),
                      style: context.textStyles.labelSmall?.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          for (final prayer in AppPrayer.values)
            Expanded(
              flex: _timeFlex,
              child: _TimeCell(
                text: PrayerFormatters.clock(day.times.getTimeFor(prayer)),
                isToday: isToday,
                isNext: prayer == nextPrayer,
              ),
            ),
        ],
      ),
    );
  }
}

/// A prayer time. On today's row the coming prayer is filled with gold.
class _TimeCell extends StatelessWidget {
  const _TimeCell({
    required this.text,
    required this.isToday,
    required this.isNext,
  });

  final String text;
  final bool isToday;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: isNext ? colors.secondary.withValues(alpha: 0.35) : null,
        borderRadius: BorderRadius.circular(context.corners.md),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: context.textStyles.bodyMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
