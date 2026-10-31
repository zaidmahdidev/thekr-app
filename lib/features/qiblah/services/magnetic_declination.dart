import 'package:flutter/services.dart';

/// How far magnetic north (what the compass shows) is from true north at a
/// place, in degrees, east positive. The Qibla bearing is measured from true
/// north, so this is added to the compass heading. Answers 0 where the phone
/// cannot tell (it is then simply not corrected, as before).
class MagneticDeclination {
  const MagneticDeclination._();

  static const MethodChannel _channel = MethodChannel('thekr/declination');

  static Future<double> at(double latitude, double longitude) async {
    try {
      final value = await _channel.invokeMethod<double>('declination', {
        'lat': latitude,
        'lng': longitude,
      });
      return (value != null && value.isFinite) ? value : 0;
    } catch (_) {
      return 0;
    }
  }
}
