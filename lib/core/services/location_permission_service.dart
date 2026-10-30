import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/prayer_service.dart';

/// What [LocationPermissionService.askOnce] did.
enum LocationPromptResult {
  /// The permission was asked for and given: the location was read.
  granted,

  /// The permission was asked for and refused.
  denied,

  /// Nothing to ask: it was asked before, or the user already decided (given,
  /// or refused for good in the phone's settings).
  notNeeded,

  /// The app was not in front (a settings page was open): try again when it
  /// is back.
  deferred,
}

/// The few calls to the phone this service needs, apart so that tests can
/// replace them.
abstract class LocationPermissionGateway {
  Future<LocationPermission> check();
  Future<LocationPermission> request();
  Future<void> readLocation();
  bool get isInForeground;
}

class _DeviceGateway implements LocationPermissionGateway {
  const _DeviceGateway();

  @override
  Future<LocationPermission> check() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> request() => Geolocator.requestPermission();

  @override
  Future<void> readLocation() => PrayerService.refreshLocation();

  @override
  bool get isInForeground {
    final state = WidgetsBinding.instance.lifecycleState;
    // Null before the first frame: the app is just starting, in front.
    return state == null || state == AppLifecycleState.resumed;
  }
}

/// Asks for the location permission the first time the app is opened, the way
/// apps ask for notifications, so prayer times are right from the start.
///
/// It asks once. After a refusal the app never shows the system dialog on its
/// own again: the "allow location" buttons stay where the user can use them.
class LocationPermissionService {
  LocationPermissionService({LocationPermissionGateway? gateway})
    : _gateway = gateway ?? const _DeviceGateway();

  static final LocationPermissionService instance = LocationPermissionService();

  final LocationPermissionGateway _gateway;

  static const String askedKey = 'location_prompt_asked';

  /// How long to wait for the startup notification permissions (which may open
  /// a settings page) before giving up and asking anyway.
  static const Duration waitForOthers = Duration(seconds: 45);

  bool _running = false;

  bool get alreadyAsked => CacheHelper.getData(key: askedKey) == true;

  /// Asks if it has not been asked yet. [after] is another request that must
  /// finish first (the notification permissions): two system requests at the
  /// same time make one of them fail.
  Future<LocationPromptResult> askOnce({Future<Object?>? after}) async {
    if (alreadyAsked || _running) return LocationPromptResult.notNeeded;
    _running = true;
    try {
      if (after != null) await _waitFor(after);

      // A settings page may be open on top of the app; the dialog would not
      // show. The caller tries again when the app comes back.
      if (!_gateway.isInForeground) return LocationPromptResult.deferred;
      if (alreadyAsked) return LocationPromptResult.notNeeded;

      final current = await _gateway.check();
      if (current != LocationPermission.denied) {
        // Already given, or refused for good: nothing the dialog could change.
        await _markAsked();
        return LocationPromptResult.notNeeded;
      }

      // Marked before asking, so being killed with the dialog open cannot make
      // the app ask again and again.
      await _markAsked();
      final result = await _gateway.request();
      final granted =
          result == LocationPermission.whileInUse ||
          result == LocationPermission.always;
      if (!granted) return LocationPromptResult.denied;

      await _gateway.readLocation();
      return LocationPromptResult.granted;
    } catch (e) {
      debugPrint('Location prompt failed: $e');
      return LocationPromptResult.notNeeded;
    } finally {
      _running = false;
    }
  }

  /// Waits for [other], whether it finishes, fails or takes too long: either
  /// way, the location request goes on.
  Future<void> _waitFor(Future<Object?> other) async {
    try {
      await other.timeout(waitForOthers);
    } catch (_) {}
  }

  Future<void> _markAsked() => CacheHelper.saveData(key: askedKey, value: true);
}
