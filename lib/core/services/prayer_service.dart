import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/location_attempt_gate.dart';
import 'package:thekr_app/core/services/location_name_service.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:thekr_app/features/home/models/app_prayer_times.dart';
import 'package:thekr_app/features/prayer_times/models/prayer_calc_settings.dart';

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
  ///
  /// [settings] are the user's calculation choices; without them the saved ones
  /// are used (which are the app's original method until the user changes it).
  static AppPrayerTimes timesFor(
    DateTime date,
    PrayerLocation location, {
    PrayerCalcSettings? settings,
  }) {
    final calc = settings ?? PrayerCalcSettings.load();
    final params = _parametersFor(calc, date);

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

  /// The `adhan` parameters for the user's choices on [date].
  static CalculationParameters _parametersFor(
    PrayerCalcSettings calc,
    DateTime date,
  ) {
    final params = _adhanMethod(calc.method).getParameters();
    params.madhab = calc.madhab == AsrMadhab.hanafi
        ? Madhab.hanafi
        : Madhab.shafi;
    params.highLatitudeRule = switch (calc.highLatitude) {
      HighLatitudeMode.middleOfNight => HighLatitudeRule.middle_of_the_night,
      HighLatitudeMode.seventhOfNight => HighLatitudeRule.seventh_of_the_night,
      HighLatitudeMode.twilightAngle => HighLatitudeRule.twilight_angle,
    };

    // Umm al-Qura: Isha is 120 minutes after Maghrib in Ramadan. The library
    // always uses 90, so the month is checked here.
    if (calc.method == PrayerCalcMethod.ummAlQura &&
        calc.ramadanIsha &&
        isRamadan(date)) {
      params.ishaInterval = 120;
    }

    params.adjustments = PrayerAdjustments(
      fajr: calc.adjustmentOf(AppPrayer.fajr),
      sunrise: calc.adjustmentOf(AppPrayer.sunrise),
      dhuhr: calc.adjustmentOf(AppPrayer.dhuhr),
      asr: calc.adjustmentOf(AppPrayer.asr),
      maghrib: calc.adjustmentOf(AppPrayer.maghrib),
      isha: calc.adjustmentOf(AppPrayer.isha),
    );
    return params;
  }

  /// Whether [date] falls in Ramadan of the Hijri calendar.
  static bool isRamadan(DateTime date) {
    try {
      return HijriCalendar.fromDate(date).hMonth == 9;
    } catch (_) {
      return false;
    }
  }

  static CalculationMethod _adhanMethod(PrayerCalcMethod method) {
    switch (method) {
      case PrayerCalcMethod.ummAlQura:
        return CalculationMethod.umm_al_qura;
      case PrayerCalcMethod.muslimWorldLeague:
        return CalculationMethod.muslim_world_league;
      case PrayerCalcMethod.egyptian:
        return CalculationMethod.egyptian;
      case PrayerCalcMethod.karachi:
        return CalculationMethod.karachi;
      case PrayerCalcMethod.northAmerica:
        return CalculationMethod.north_america;
      case PrayerCalcMethod.dubai:
        return CalculationMethod.dubai;
      case PrayerCalcMethod.kuwait:
        return CalculationMethod.kuwait;
      case PrayerCalcMethod.qatar:
        return CalculationMethod.qatar;
      case PrayerCalcMethod.singapore:
        return CalculationMethod.singapore;
      case PrayerCalcMethod.turkey:
        return CalculationMethod.turkey;
      case PrayerCalcMethod.tehran:
        return CalculationMethod.tehran;
      case PrayerCalcMethod.moonSighting:
        return CalculationMethod.moon_sighting_committee;
    }
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

  /// One attempt at a time, and automatic ones only now and then, so that
  /// recalculating the times never turns into a stream of location requests.
  static final LocationAttemptGate _gate = LocationAttemptGate();

  /// How the phone is asked for its position. Prayer times need the city, not
  /// the street, so low accuracy is enough. On Android the system's own
  /// location manager is used instead of Google Play services: the latter
  /// opens a "Location Accuracy" dialog of its own when that setting is off,
  /// and it came back again and again.
  static LocationSettings get _quietSettings {
    const limit = Duration(seconds: 20);
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.low,
        forceLocationManager: true,
        timeLimit: limit,
      );
    }
    return const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: limit);
  }

  /// Reads the position and saves it. Called when the user asks (pull to
  /// refresh, the "allow location" buttons). Returns whether it worked.
  static Future<bool> refreshLocation() async {
    if (!_gate.tryStartManual()) return false;
    try {
      return await _readAndSave();
    } finally {
      _gate.finish();
    }
  }

  /// The same, started by the app when no position is saved yet. It is limited
  /// by the gate, and never shows anything to the user.
  static Future<void> _updateLocationInBackground() async {
    if (!_gate.tryStartAutomatic()) return;
    try {
      await _readAndSave();
    } finally {
      _gate.finish();
    }
  }

  static Future<bool> _readAndSave() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return false;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _quietSettings,
      );
      _saveLocationToCache(position.latitude, position.longitude);
      return true;
    } catch (_) {
      // Location switched off, no signal, or too slow: the saved position (or
      // Mecca) keeps being used and the user is not disturbed.
      return false;
    }
  }

  static void _saveLocationToCache(double lat, double lng) {
    CacheHelper.saveData(key: _latKey, value: lat);
    CacheHelper.saveData(key: _lngKey, value: lng);
    // Names are looked up in the background; prayer times never wait for them.
    LocationNameService.refresh(lat, lng);
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
