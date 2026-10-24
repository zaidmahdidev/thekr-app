import 'package:thekr_app/features/home/models/app_prayer_times.dart';

/// One calendar day with its prayer times (used by the month table).
class PrayerDay {
  final DateTime date;
  final AppPrayerTimes times;

  const PrayerDay({required this.date, required this.times});
}
