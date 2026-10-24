import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/features/home/models/app_prayer_times.dart';

/// The place prayer times are calculated for.
class PrayerLocation {
  final Coordinates coordinates;

  /// True when no real location is known yet and Mecca is used instead.
  final bool isDefault;

  /// True when the location permission is denied.
  final bool isPermissionOff;

  const PrayerLocation({
    required this.coordinates,
    required this.isDefault,
    required this.isPermissionOff,
  });
}

class PrayerService {
  static const String _latKey = 'cached_lat';
  static const String _lngKey = 'cached_lng';

  static const _meccaLat = 21.4225;
  static const _meccaLng = 39.8262;

  /// Where the prayer times are calculated for: the user's last known
  /// location, or Mecca when none is available yet.
  static Future<PrayerLocation> getLocation() async {
    final usedDefault = !_hasSavedLocation();
    final coordinates = await _getEffectiveCoordinates();
    final stillDefault =
        usedDefault &&
        coordinates.latitude == _meccaLat &&
        coordinates.longitude == _meccaLng;

    var permissionOff = false;
    try {
      final permission = await Geolocator.checkPermission();
      permissionOff =
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever;
    } catch (_) {}

    return PrayerLocation(
      coordinates: coordinates,
      isDefault: stillDefault,
      isPermissionOff: permissionOff,
    );
  }

  static bool _hasSavedLocation() =>
      CacheHelper.getData(key: _latKey) != null &&
      CacheHelper.getData(key: _lngKey) != null;

  /// Prayer times of [date] at [location]. Pure calculation (no internet).
  static AppPrayerTimes timesFor(DateTime date, PrayerLocation location) {
    final params = CalculationMethod.umm_al_qura.getParameters();
    params.madhab = Madhab.shafi;

    final adhanTimes = PrayerTimes(
      location.coordinates,
      DateComponents.from(date),
      params,
    );
    return _convertToAppModel(
      adhanTimes,
      isLocationOff: location.isPermissionOff,
      isDefaultLocation: location.isDefault,
    );
  }

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
    return Coordinates(_meccaLat, _meccaLng);
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

  static AppPrayerTimes _convertToAppModel(
    PrayerTimes times, {
    bool isLocationOff = false,
    bool isDefaultLocation = false,
  }) {
    return AppPrayerTimes(
      fajr: times.fajr,
      sunrise: times.sunrise,
      dhuhr: times.dhuhr,
      asr: times.asr,
      maghrib: times.maghrib,
      isha: times.isha,
      isLocationOff: isLocationOff,
      isDefaultLocation: isDefaultLocation,
    );
  }

  static Future<AppPrayerTimes?> getCurrentPrayerTimes() async {
    try {
      return timesFor(DateTime.now(), await getLocation());
    } catch (e) {
      return null;
    }
  }

  static Future<AppPrayerTimes?> getNextDayPrayerTimes() async {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return timesFor(tomorrow, await getLocation());
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
