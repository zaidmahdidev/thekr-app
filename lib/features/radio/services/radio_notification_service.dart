import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thekr_app/core/services/notification_service.dart';

/// What the radio notification shows next to the station name.
enum RadioNotificationState { playing, loading, paused }

/// A button of the notification.
enum RadioCommand { play, pause, next, previous, stop }

/// The notification of the radio.
///
/// On Android it is a media session of its own (cover, previous / play-pause /
/// next, lock screen) kept alive by a foreground service, so the stream is not
/// stopped when the app is left. It is separate from the Quran player's
/// notification and never touches the Quran library.
///
/// If that cannot start for any reason, a plain notification with a foreground
/// service is used, and if even that fails the radio simply plays without one.
class RadioNotificationService {
  RadioNotificationService._();

  /// Called when a button of the notification is pressed.
  static void Function(RadioCommand command)? onCommand;

  static const MethodChannel _channel = MethodChannel(
    'com.zaid.thekr_app/radio',
  );

  static const int _fallbackId = 7301;
  static const String _fallbackStopAction = 'radio_stop';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _listening = false;
  static bool _visible = false;
  static bool _usingFallback = false;

  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// Shows or updates the notification for a station.
  static Future<void> show({
    required String title,
    required String subtitle,
    required RadioNotificationState state,
  }) async {
    if (!_isAndroid) return;
    _listen();

    if (!_usingFallback) {
      try {
        await _channel.invokeMethod<void>('show', <String, String>{
          'title': title,
          'subtitle': subtitle,
          'state': state.name,
        });
        _visible = true;
        return;
      } catch (e) {
        debugPrint('Radio: media session unavailable, using fallback: $e');
        _usingFallback = true;
      }
    }
    await _showFallback(title, state);
  }

  /// Removes the notification and stops the service.
  static Future<void> hide() async {
    if (!_isAndroid || !_visible) return;
    _visible = false;
    try {
      if (_usingFallback) {
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.stopForegroundService();
      } else {
        await _channel.invokeMethod<void>('hide');
      }
    } catch (e) {
      debugPrint('Radio: could not remove the notification: $e');
    }
  }

  // --------------------------------------------------------------- commands

  /// Buttons arrive from Kotlin as a `command` call, and from the fallback
  /// notification as an action id.
  static void _listen() {
    if (_listening) return;
    _listening = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'command') return;
      final command = RadioCommand.values.where((c) => c.name == call.arguments);
      if (command.isNotEmpty) onCommand?.call(command.first);
    });
    NotificationService.onNotificationAction = (id) {
      if (id == _fallbackStopAction) onCommand?.call(RadioCommand.stop);
    };
  }

  // --------------------------------------------------------------- fallback

  static Future<void> _showFallback(
    String title,
    RadioNotificationState state,
  ) async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.startForegroundService(
            id: _fallbackId,
            title: title,
            body: state == RadioNotificationState.playing
                ? 'جارٍ التشغيل'
                : 'جارٍ الاتصال…',
            payload: 'radio',
            startType: AndroidServiceStartType.startNotSticky,
            foregroundServiceTypes: {
              AndroidServiceForegroundType.foregroundServiceTypeMediaPlayback,
            },
            notificationDetails: const AndroidNotificationDetails(
              'radio_playback',
              'تشغيل الإذاعة',
              channelDescription: 'إشعار يظهر أثناء تشغيل الإذاعة',
              importance: Importance.low,
              priority: Priority.low,
              ongoing: true,
              playSound: false,
              enableVibration: false,
              showWhen: false,
              styleInformation: MediaStyleInformation(),
              actions: <AndroidNotificationAction>[
                AndroidNotificationAction(
                  _fallbackStopAction,
                  'إيقاف',
                  cancelNotification: false,
                ),
              ],
            ),
          );
      _visible = true;
    } catch (e) {
      // The radio keeps playing without a notification, as it always did.
      debugPrint('Radio: notification unavailable: $e');
    }
  }
}
