import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/prayer_service.dart';
import 'package:thekr_app/features/prayer_times/models/prayer_day.dart';
import 'package:thekr_app/features/prayer_times/providers/prayer_calc_provider.dart';

/// Where prayer times are calculated for (saved location, or Mecca).
final prayerLocationProvider = FutureProvider<PrayerLocation>((ref) {
  return PrayerService.getLocation();
});

/// Every day of the month that starts at [firstOfMonth], calculated offline.
final prayerMonthProvider =
    Provider.family<AsyncValue<List<PrayerDay>>, DateTime>((ref, firstOfMonth) {
      // The month follows the user's calculation choices as they change.
      final settings = ref.watch(prayerCalcProvider);
      return ref.watch(prayerLocationProvider).whenData((location) {
        // Without the user's location there is no timetable to show.
        if (!location.isKnown) return <PrayerDay>[];
        final days = DateTime(firstOfMonth.year, firstOfMonth.month + 1, 0).day;
        return [
          for (var d = 1; d <= days; d++)
            PrayerDay(
              date: DateTime(firstOfMonth.year, firstOfMonth.month, d),
              times: PrayerService.timesFor(
                DateTime(firstOfMonth.year, firstOfMonth.month, d),
                location,
                settings: settings,
              ),
            ),
        ];
      });
    });
