import 'package:thekr_app/core/utils/enums/prayer_enum.dart';

class AppPrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  AppPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  DateTime getTimeFor(AppPrayer prayer) {
    switch (prayer) {
      case AppPrayer.fajr:
        return fajr;
      case AppPrayer.sunrise:
        return sunrise;
      case AppPrayer.dhuhr:
        return dhuhr;
      case AppPrayer.asr:
        return asr;
      case AppPrayer.maghrib:
        return maghrib;
      case AppPrayer.isha:
        return isha;
    }
  }

  /// Calculates which prayer is next based on current time
  AppPrayer? nextPrayer(DateTime now) {
    if (now.isBefore(fajr)) return AppPrayer.fajr;
    if (now.isBefore(sunrise)) return AppPrayer.sunrise;
    if (now.isBefore(dhuhr)) return AppPrayer.dhuhr;
    if (now.isBefore(asr)) return AppPrayer.asr;
    if (now.isBefore(maghrib)) return AppPrayer.maghrib;
    if (now.isBefore(isha)) return AppPrayer.isha;
    return null; // All passed
  }
}
