import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/features/home/models/app_prayer_times.dart';

class PrayerService {
  static Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  static AppPrayerTimes _convertToAppModel(PrayerTimes times, {bool isLocationOff = false}) {
    return AppPrayerTimes(
      fajr: times.fajr,
      sunrise: times.sunrise,
      dhuhr: times.dhuhr,
      asr: times.asr,
      maghrib: times.maghrib,
      isha: times.isha,
      isLocationOff: isLocationOff,
    );
  }

  static Future<AppPrayerTimes?> getCurrentPrayerTimes() async {
    try {
      Coordinates coordinates = Coordinates(21.4225, 39.8262); // Mecca fallback
      bool isLocationOff = false;

      try {
        LocationPermission permission = await Geolocator.checkPermission();
        
        if (permission == LocationPermission.always || 
            permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition();
          coordinates = Coordinates(position.latitude, position.longitude);
        } else if (permission == LocationPermission.denied) {
          // Check if we have already asked for permission once to avoid repeated prompts
          final dynamic hasRequestedData = CacheHelper.getData(key: 'location_requested');
          final bool hasRequested = (hasRequestedData is bool) ? hasRequestedData : false;
          
          if (!hasRequested) {
            // This is likely the first time, or we haven't recorded a request yet
            await CacheHelper.saveData(key: 'location_requested', value: true);
            permission = await Geolocator.requestPermission();
            
            if (permission == LocationPermission.always || 
                permission == LocationPermission.whileInUse) {
              Position position = await Geolocator.getCurrentPosition();
              coordinates = Coordinates(position.latitude, position.longitude);
            } else {
              isLocationOff = true;
            }
          } else {
            // We have already asked once, and the user denied. 
            // We show the button instead of showing the system dialog again automatically.
            isLocationOff = true;
          }
        } else {
          isLocationOff = true;
        }
      } catch (e) {
        isLocationOff = true;
      }

      final params = CalculationMethod.karachi.getParameters();
      params.madhab = Madhab.shafi;

      final dateComponents = DateComponents.from(DateTime.now());
      final adhanTimes = PrayerTimes(coordinates, dateComponents, params);
      return _convertToAppModel(adhanTimes, isLocationOff: isLocationOff);
    } catch (e) {
      return null;
    }
  }

  static Future<AppPrayerTimes?> getNextDayPrayerTimes() async {
    try {
      Coordinates coordinates = Coordinates(21.4225, 39.8262);
      bool isLocationOff = false;

      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always || 
            permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition();
          coordinates = Coordinates(position.latitude, position.longitude);
        } else {
          isLocationOff = true;
        }
      } catch (e) {
        isLocationOff = true;
      }

      final params = CalculationMethod.karachi.getParameters();
      params.madhab = Madhab.shafi;

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dateComponents = DateComponents.from(tomorrow);
      final adhanTimes = PrayerTimes(coordinates, dateComponents, params);

      return _convertToAppModel(adhanTimes, isLocationOff: isLocationOff);
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
        return 'الفجر';
    }
  }
}
