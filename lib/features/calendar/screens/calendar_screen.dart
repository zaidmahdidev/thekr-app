import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/core/widgets/base_app_bar.dart';

@RoutePage()
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const BaseAppBar(
        title: 'التقويم الإسلامي',
        showBlur: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.insets.lg),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(context.corners.lg),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              padding: EdgeInsets.all(context.insets.md),
              child: TableCalendar(
                locale: 'ar',
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2050, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'شهر',
                },
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: context.textStyles.titleLarge!.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left_rounded,
                    color: context.colors.primary,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right_rounded,
                    color: context.colors.primary,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: context.textStyles.bodyMedium!.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendStyle: context.textStyles.bodySmall!.copyWith(
                    color: context.colors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
                daysOfWeekHeight: 30.h,
                rowHeight: 52.h,
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    final text = DateFormat.E('ar').format(day);
                    final isWeekend = day.weekday == DateTime.friday || day.weekday == DateTime.saturday;
                    return Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Text(
                            text,
                            style: context.textStyles.bodySmall?.copyWith(
                              color: isWeekend ? context.colors.secondary : context.colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) => _buildCalendarCell(context, day, false),
                  selectedBuilder: (context, day, focusedDay) => _buildCalendarCell(context, day, true),
                  todayBuilder: (context, day, focusedDay) => _buildCalendarCell(context, day, false, isToday: true),
                  outsideBuilder: (context, day, focusedDay) => _buildCalendarCell(context, day, false, isOutside: true),
                ),
              ),
            ),
            SizedBox(height: context.insets.xl),
            _buildSelectedDayDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCell(
    BuildContext context,
    DateTime day,
    bool isSelected, {
    bool isToday = false,
    bool isOutside = false,
  }) {
    final hijriDate = HijriCalendar.fromDate(day);
    
    Color bgColor = Colors.transparent;
    Color textColor = context.colors.textPrimary;
    Color hijriColor = context.colors.primary.withValues(alpha: 0.6);
    
    if (isSelected) {
      bgColor = context.colors.primary;
      textColor = context.colors.surface;
      hijriColor = context.colors.surface.withValues(alpha: 0.8);
    } else if (isToday) {
      bgColor = context.colors.secondary.withValues(alpha: 0.2);
      textColor = context.colors.secondary;
      hijriColor = context.colors.secondary.withValues(alpha: 0.8);
    } else if (isOutside) {
      textColor = context.colors.textPrimary.withValues(alpha: 0.3);
      hijriColor = context.colors.primary.withValues(alpha: 0.2);
    } else if (day.weekday == DateTime.friday) {
      textColor = context.colors.secondary;
    }

    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(context.corners.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: context.textStyles.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          Text(
            '${hijriDate.hDay}',
            style: context.textStyles.bodySmall?.copyWith(
              color: hijriColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetails(BuildContext context) {
    if (_selectedDay == null) return const SizedBox.shrink();

    final hijriDate = HijriCalendar.fromDate(_selectedDay!);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.insets.lg),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear} هـ',
            style: context.textStyles.titleLarge?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.insets.sm),
          Text(
            '${_selectedDay!.day} / ${_selectedDay!.month} / ${_selectedDay!.year} م',
            style: context.textStyles.titleMedium?.copyWith(
              color: context.colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
