import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/location_name_service.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:thekr_app/features/home/models/app_prayer_times.dart';
import 'package:thekr_app/features/prayer_times/models/prayer_calc_settings.dart';

/// The place prayer times are calculated for.
class PrayerLocation {
  final Coordinates coordinates;

  /// True when the user's location is not known. [coordinates] is then only a
  /// placeholder: no prayer times are made from it (see [isKnown]).
  final bool isDefault;

  /// True when the location permission is denied.
  final bool isPermissionOff;

  const PrayerLocation({
    required this.coordinates,
    required this.isDefault,
    required this.isPermissionOff,
  });

  /// Whether [coordinates] are the user's own.
  bool get isKnown => !isDefault;
}

class PrayerService {
  static const String _latKey = 'cached_lat';
  static const String _lngKey = 'cached_lng';

  static const _meccaLat = 21.4225;
  static const _meccaLng = 39.8262;

  /// Where the prayer times are calculated for: the user's last known
  /// location. Without one, [PrayerLocation.isKnown] is false and there are no
  /// prayer times: those of another city would be wrong, and the athan would
  /// ring at the wrong time.
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

    // 3. Not known. The coordinates are only a placeholder (see
    // [PrayerLocation.isKnown]). Nothing is asked of the phone here:
    // recalculating the times must never start a location reading, which can
    // bring up Google's dialog again and again.
    return Coordinates(_meccaLat, _meccaLng);
  }

  /// A reading is given this long: the first position after switching the
  /// location on can take a while, and the user is waiting with a spinner.
  static const Duration _readingLimit = Duration(seconds: 60);

  /// A last known position older than this is not used.
  static const Duration _lastKnownMaxAge = Duration(days: 3);

  static bool _reading = false;

  /// Finds where the user is now and saves it. Called only on purpose: after the
  /// user allows the location, presses a button, or pulls the page to refresh.
  /// Nothing starts it by itself, so Google's "turn on location" dialog, which a
  /// reading can bring up, appears once per press. Returns whether it worked.
  static Future<bool> refreshLocation() async {
    if (_reading) return false; // already looking
    _reading = true;
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return false;
      }
      try {
        // The standard reading (Google Play services when the phone has them).
        // City level is enough for prayer times, and works indoors.
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: _readingLimit,
          ),
        );
        _saveLocationToCache(position.latitude, position.longitude);
        return true;
      } catch (_) {
        // No fix in time, or the user refused to turn the location on: the
        // phone may still know where it was a little while ago.
        final known = await Geolocator.getLastKnownPosition();
        if (known != null &&
            DateTime.now().difference(known.timestamp).abs() <= _lastKnownMaxAge) {
          _saveLocationToCache(known.latitude, known.longitude);
          return true;
        }
        return false;
      }
    } catch (_) {
      return false;
    } finally {
      _reading = false;
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

  /// Today's times, or null when the user's location is not known.
  static Future<AppPrayerTimes?> getCurrentPrayerTimes() async {
    try {
      final location = await getLocation();
      if (!location.isKnown) return null;
      return timesFor(DateTime.now(), location);
    } catch (e) {
      return null;
    }
  }

  /// Tomorrow's times, or null when the user's location is not known.
  static Future<AppPrayerTimes?> getNextDayPrayerTimes() async {
    try {
      final location = await getLocation();
      if (!location.isKnown) return null;
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return timesFor(tomorrow, location);
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
