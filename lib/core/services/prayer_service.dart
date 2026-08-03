import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/features/home/models/app_prayer_times.dart';

class PrayerService {


  static const String _latKey = 'cached_lat';
  static const String _lngKey = 'cached_lng';

  static Future<Coordinates> _getEffectiveCoordinates() async {
    // 1. Try to get from Cache (Fastest)
    final lat = CacheHelper.getData(key: _latKey);
    final lng = CacheHelper.getData(key: _lngKey);

    if (lat != null && lng != null) {
      return Coordinates(lat as double, lng as double);
    }

    // 2. Try to get Last Known Position (Fast)
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        _saveLocationToCache(position.latitude, position.longitude);
        return Coordinates(position.latitude, position.longitude);
      }
    } catch (_) {}

    // 3. Fallback to Mecca (Safe)
    // We don't wait for getCurrentPosition here to keep it instant
    // The background update will eventually get the real location
    _updateLocationInBackground();
    return Coordinates(21.4225, 39.8262);
  }

  static Future<void> refreshLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        // High accuracy for manual refresh
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        _saveLocationToCache(position.latitude, position.longitude);
      }
    } catch (_) {}
  }

  static void _updateLocationInBackground() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        // Use a lower accuracy for faster results and less battery usage
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            distanceFilter: 10000, // Only update if moved 10km
          ),
        );
        _saveLocationToCache(position.latitude, position.longitude);
      }
    } catch (_) {}
  }

  static void _saveLocationToCache(double lat, double lng) {
    CacheHelper.saveData(key: _latKey, value: lat);
    CacheHelper.saveData(key: _lngKey, value: lng);
  }

  static AppPrayerTimes _convertToAppModel(PrayerTimes times,
      {bool isLocationOff = false}) {
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
      final coordinates = await _getEffectiveCoordinates();
      
      // Check if permission is denied to show the "Location Off" indicator if needed
      bool isLocationOff = false;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        isLocationOff = permission == LocationPermission.denied || 
                       permission == LocationPermission.deniedForever;
      } catch (_) {}

      final params = CalculationMethod.umm_al_qura.getParameters();
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
      final coordinates = await _getEffectiveCoordinates();
      
      bool isLocationOff = false;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        isLocationOff = permission == LocationPermission.denied || 
                       permission == LocationPermission.deniedForever;
      } catch (_) {}

      final params = CalculationMethod.umm_al_qura.getParameters();
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
