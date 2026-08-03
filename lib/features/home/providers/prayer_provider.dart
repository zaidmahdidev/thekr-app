import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/prayer_service.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:thekr_app/features/home/models/app_prayer_times.dart';

import 'package:thekr_app/core/services/notification_service.dart';

final prayerTimesProvider = FutureProvider<AppPrayerTimes?>((ref) async {
  final times = await PrayerService.getCurrentPrayerTimes();
  if (times != null) {
    NotificationService.refreshScheduledNotifications();
  }
  return times;
});

final tomorrowPrayerTimesProvider = FutureProvider<AppPrayerTimes?>((
  ref,
) async {
  return await PrayerService.getNextDayPrayerTimes();
});

final nextPrayerProvider = Provider<AppPrayer>((ref) {
  final prayerTimes = ref.watch(prayerTimesProvider).value;
  if (prayerTimes == null) return AppPrayer.fajr;

  // We use our own nextPrayer calculation now
  final next = prayerTimes.nextPrayer(DateTime.now());
  if (next == null) {
    return AppPrayer.fajr; // Rollover
  }
  return next;
});
