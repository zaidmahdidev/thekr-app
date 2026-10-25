import 'package:intl/intl.dart' as intl;
import 'package:thekr_app/features/calendar/services/calendar_service.dart';

/// Text helpers for the prayer times screen.
class PrayerFormatters {
  PrayerFormatters._();

  /// "5:02" (12-hour clock, no period).
  static String clock(DateTime time) =>
      intl.DateFormat('h:mm', 'en').format(time);

  /// "الجمعة".
  static String weekday(DateTime date) =>
      CalendarService.weekdayNames[(date.weekday + 1) % 7];
}
