import 'dart:ui' show Locale;

import 'package:geocoding/geocoding.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/features/sync/services/sync_rules.dart';

/// Looks up the city and district name of coordinates the app already has.
///
/// It never asks for the location permission and never fails the caller: with
/// no internet, or no geocoder on the device, the names are simply left empty.
class LocationNameService {
  LocationNameService._();

  /// Coordinates the names were last looked up for.
  static const String _resolvedForKey = 'cached_place_for';

  /// Saves the city and district for [lat], [lng] unless they are already
  /// saved for (nearly) the same place.
  static Future<void> refresh(double lat, double lng) async {
    try {
      final tag = '${lat.toStringAsFixed(2)},${lng.toStringAsFixed(2)}';
      final alreadyDone =
          CacheHelper.getData(key: _resolvedForKey) == tag &&
          CacheHelper.getData(key: SyncRules.cityKey) != null;
      if (alreadyDone) return;

      final places = await Geocoding().placemarkFromCoordinates(
        lat,
        lng,
        locale: const Locale('ar'),
      );
      if (places.isEmpty) return;

      final place = places.first;
      final city = _firstNonEmpty([
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
      ]);
      final district = _firstNonEmpty([
        place.subLocality,
        place.thoroughfare,
      ]);
      if (city == null && district == null) return;

      if (city != null) {
        await CacheHelper.saveData(key: SyncRules.cityKey, value: city);
      }
      if (district != null) {
        await CacheHelper.saveData(key: SyncRules.districtKey, value: district);
      }
      await CacheHelper.saveData(key: _resolvedForKey, value: tag);
    } catch (_) {
      // Best effort only.
    }
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      final t = v?.trim();
      if (t != null && t.isNotEmpty) return t;
    }
    return null;
  }
}
