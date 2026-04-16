import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:thekr_app/features/home/models/app_prayer_times.dart';

class PrayerService {
  static Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  static AppPrayerTimes _convertToAppModel(PrayerTimes times) {
    return AppPrayerTimes(
      fajr: times.fajr,
      sunrise: times.sunrise,
      dhuhr: times.dhuhr,
      asr: times.asr,
      maghrib: times.maghrib,
      isha: times.isha,
    );
  }

  static Future<AppPrayerTimes?> getCurrentPrayerTimes() async {
    try {
      // Default coordinates (Mecca)
      Coordinates coordinates = Coordinates(21.4225, 39.8262);

      try {
        Position position = await _determinePosition();
        coordinates = Coordinates(position.latitude, position.longitude);
      } catch (e) {
        debugPrint('Geolocator error: $e');
      }

      final params = CalculationMethod.karachi.getParameters();
      params.madhab = Madhab.shafi;

      final dateComponents = DateComponents.from(DateTime.now());
      final adhanTimes = PrayerTimes(coordinates, dateComponents, params);
      return _convertToAppModel(adhanTimes);
    } catch (e) {
      debugPrint('Error getting prayer times: $e');
      return null;
    }
  }

  static Future<AppPrayerTimes?> getNextDayPrayerTimes() async {
    try {
      Coordinates coordinates = Coordinates(21.4225, 39.8262);
      try {
        Position position = await _determinePosition();
        coordinates = Coordinates(position.latitude, position.longitude);
      } catch (e) {
        /* Fallback to Mecca */
      }

      final params = CalculationMethod.karachi.getParameters();
      params.madhab = Madhab.shafi;

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dateComponents = DateComponents.from(tomorrow);
      final adhanTimes = PrayerTimes(coordinates, dateComponents, params);

      return _convertToAppModel(adhanTimes);
    } catch (e) {
      return null;
    }
  }

  static String getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return 'الفجر'; // Default to Fajr for next day logic
    }
  }
}
