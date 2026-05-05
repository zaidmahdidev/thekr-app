import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static const String _madinahStreamIdKey = 'stream_madinah_id';
  static const String _makkahStreamIdKey = 'stream_makkah_id';

  Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 5),
        ),
      );

      // القيم الافتراضية في حال عدم وجود اتصال
      await _remoteConfig.setDefaults({
        _madinahStreamIdKey: 'BtMUUgApnPs',
        _makkahStreamIdKey: 'fZvuHkHYaXk',
      });

      await fetchAndActivate();
    } catch (e) {
      print('Error initializing Remote Config: $e');
    }
  }

  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Error fetching Remote Config: $e');
    }
  }

  String get madinahStreamId => _remoteConfig.getString(_madinahStreamIdKey);
  String get makkahStreamId => _remoteConfig.getString(_makkahStreamIdKey);
}
