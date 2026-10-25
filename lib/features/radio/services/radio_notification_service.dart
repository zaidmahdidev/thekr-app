import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thekr_app/core/services/notification_service.dart';

/// The notification of a playing radio station, kept by an Android foreground
/// service so the system does not stop the stream when the app is left.
///
/// It is separate from the Quran player's own notification and does not touch
/// the Quran library: both can exist without knowing about each other.
class RadioNotificationService {
  RadioNotificationService._();

  /// Called when the "stop" button of the notification is pressed.
  static Future<void> Function()? onStop;

  static const int _id = 7301;
  static const String _channelId = 'radio_playback';
  static const String _stopAction = 'radio_stop';

  /// Payload of a tap on the notification; the app opens the radio screen.
  static const String payload = 'radio';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _shown = false;

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  /// Shows (or updates) the notification for [stationName].
  static Future<void> show(String stationName, {required bool playing}) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      NotificationService.onNotificationAction = _onAction;
      await _android?.startForegroundService(
        id: _id,
        title: stationName,
        body: playing ? 'جارٍ التشغيل' : 'جارٍ الاتصال…',
        payload: payload,
        startType: AndroidServiceStartType.startNotSticky,
        foregroundServiceTypes: {
          AndroidServiceForegroundType.foregroundServiceTypeMediaPlayback,
        },
        notificationDetails: const AndroidNotificationDetails(
          _channelId,
          'تشغيل الإذاعة',
          channelDescription: 'إشعار يظهر أثناء تشغيل الإذاعة',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          playSound: false,
          enableVibration: false,
          showWhen: false,
          category: AndroidNotificationCategory.transport,
          visibility: NotificationVisibility.public,
          styleInformation: MediaStyleInformation(),
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              _stopAction,
              'إيقاف',
              cancelNotification: false,
            ),
          ],
        ),
      );
      _shown = true;
    } catch (e) {
      // The radio keeps playing without the notification, as before.
      debugPrint('Radio: notification unavailable: $e');
    }
  }

  /// Removes the notification and stops the foreground service.
  static Future<void> hide() async {
    if (!_shown) return;
    _shown = false;
    try {
      await _android?.stopForegroundService();
    } catch (e) {
      debugPrint('Radio: could not stop the foreground service: $e');
    }
  }

  static void _onAction(String actionId) {
    if (actionId == _stopAction) onStop?.call();
  }
}
