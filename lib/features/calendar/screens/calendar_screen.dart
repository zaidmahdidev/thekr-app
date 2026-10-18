import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/core/widgets/base_app_bar.dart';
import 'package:thekr_app/features/calendar/services/calendar_service.dart';
import 'package:thekr_app/features/calendar/widgets/calendar_day_details.dart';
import 'package:thekr_app/features/calendar/widgets/calendar_hero_card.dart';
import 'package:thekr_app/features/calendar/widgets/calendar_month_grid.dart';
import 'package:thekr_app/features/calendar/widgets/upcoming_occasions_card.dart';

/// Islamic calendar: Hijri or Gregorian month grid with occasions, recommended
/// fasting days, a day details card and the coming special days.
@RoutePage()
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final DateTime _today = DateTime.now();
  late final CalendarDay _todayInfo = CalendarService.day(_today);
  late final List<UpcomingOccasion> _upcoming = CalendarService.upcoming(
    _today,
  );

  bool _hijriMode = true;
  late DateTime _selected = DateTime(_today.year, _today.month, _today.day);

  // Visible month: (year, month) in the active calendar.
  late int _hijriYear = _todayInfo.hijri.hYear;
  late int _hijriMonth = _todayInfo.hijri.hMonth;
  late int _gregYear = _today.year;
  late int _gregMonth = _today.month;

  bool get _isOnTodayMonth => _hijriMode
      ? _hijriYear == _todayInfo.hijri.hYear &&
            _hijriMonth == _todayInfo.hijri.hMonth
      : _gregYear == _today.year && _gregMonth == _today.month;

  void _shift(int delta) {
    setState(() {
      if (_hijriMode) {
        int month = _hijriMonth + delta;
        int year = _hijriYear;
        if (month > 12) {
          month = 1;
          year++;
        } else if (month < 1) {
          month = 12;
          year--;
        }
        if (year < CalendarService.minHijriYear ||
            year > CalendarService.maxHijriYear) {
          return;
        }
        _hijriYear = year;
        _hijriMonth = month;
      } else {
        final next = DateTime(_gregYear, _gregMonth + delta);
        if (next.year < 1940 || next.year > 2070) return;
        _gregYear = next.year;
        _gregMonth = next.month;
      }
    });
  }

  /// Shows the month that contains [date] in the active calendar.
  void _focusOn(DateTime date) {
    final info = CalendarService.day(date);
    setState(() {
      _selected = DateTime(date.year, date.month, date.day);
      _hijriYear = info.hijri.hYear;
      _hijriMonth = info.hijri.hMonth;
      _gregYear = date.year;
      _gregMonth = date.month;
    });
  }

  void _setMode(bool hijri) {
    if (hijri == _hijriMode) return;
    setState(() => _hijriMode = hijri);
    _focusOn(_selected);
  }

  List<DateTime?> get _cells => _hijriMode
      ? CalendarService.hijriMonthCells(_hijriYear, _hijriMonth)
      : CalendarService.gregorianMonthCells(_gregYear, _gregMonth);

  String get _title => _hijriMode
      ? '${CalendarService.hijriMonthName(_hijriMonth)} $_hijriYear هـ'
      : '${CalendarService.gregorianMonths[_gregMonth - 1]} $_gregYear م';

  /// The other calendar's months covered by the visible month.
  String get _subtitle {
    final cells = _cells.whereType<DateTime>().toList();
    if (cells.isEmpty) return '';
    final first = CalendarService.day(cells.first);
    final last = CalendarService.day(cells.last);
    if (_hijriMode) {
      final a = CalendarService.gregorianMonths[cells.first.month - 1];
      final b = CalendarService.gregorianMonths[cells.last.month - 1];
      final year = cells.last.year;
      return a == b ? '$a $year م' : '$a - $b $year م';
    }
    final a = first.hijri.getLongMonthName();
    final b = last.hijri.getLongMonthName();
    return a == b
        ? '$a ${first.hijri.hYear} هـ'
        : '$a - $b ${last.hijri.hYear} هـ';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const BaseAppBar(title: 'التقويم الإسلامي', showBlur: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.insets.md,
          context.insets.md,
          context.insets.md,
          context.insets.xl,
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            CalendarHeroCard(
              today: _todayInfo,
              next: _upcoming.isEmpty ? null : _upcoming.first,
            ),
            SizedBox(height: context.insets.md),
            _buildCalendarCard(context),
            SizedBox(height: context.insets.md),
            CalendarDayDetails(day: CalendarService.day(_selected)),
            SizedBox(height: context.insets.md),
            UpcomingOccasionsCard(items: _upcoming, onSelected: _focusOn),
            SizedBox(height: context.insets.sm),
            Text(
              'قد يختلف التاريخ الهجري يوماً واحداً عن رؤية الهلال في بلدك.',
              textAlign: TextAlign.center,
              style: context.textStyles.labelSmall?.copyWith(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.1),
        ),
        boxShadow: context.shadows.low,
      ),
      child: GestureDetector(
        // Swipe to change month: right = previous in the RTL layout.
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v.abs() < 250) return;
          _shift(v > 0 ? -1 : 1);
        },
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: context.colors.primary.withValues(
                    alpha: 0.14,
                  ),
                  selectedForegroundColor: context.colors.primary,
                  foregroundColor: context.colors.textSecondary,
                  side: BorderSide(
                    color: context.colors.primary.withValues(alpha: 0.2),
                  ),
                ),
                segments: const [
                  ButtonSegment(value: true, label: Text('هجري')),
                  ButtonSegment(value: false, label: Text('ميلادي')),
                ],
                selected: {_hijriMode},
                onSelectionChanged: (v) => _setMode(v.first),
              ),
            ),
            SizedBox(height: context.insets.md),
            Row(
              children: [
                _NavButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'الشهر السابق',
                  onTap: () => _shift(-1),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _title,
                        style: context.textStyles.titleLarge?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      Text(
                        _subtitle,
                        style: context.textStyles.labelMedium?.copyWith(
                          color: context.colors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                _NavButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'الشهر التالي',
                  onTap: () => _shift(1),
                ),
              ],
            ),
            SizedBox(height: context.insets.sm),
            CalendarMonthGrid(
              cells: _cells,
              primaryIsHijri: _hijriMode,
              selected: _selected,
              today: _today,
              onSelected: (date) => setState(() => _selected = date),
            ),
            SizedBox(height: context.insets.sm),
            const CalendarLegend(),
            if (!_isOnTodayMonth) ...[
              SizedBox(height: context.insets.sm),
              TextButton.icon(
                onPressed: () => _focusOn(_today),
                icon: Icon(Icons.today_rounded, size: 18.sp),
                label: const Text('العودة لليوم'),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.secondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: context.colors.primary.withValues(alpha: 0.1),
      ),
      icon: Icon(icon, color: context.colors.primary),
    );
  }
}
