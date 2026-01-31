import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(initializationSettings);
  }

  static Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation
          .requestNotificationsPermission();
      final bool? exactAlarmGranted = await androidImplementation
          .requestExactAlarmsPermission();

      await _createNotificationChannel();

      return (granted ?? false) && (exactAlarmGranted ?? false);
    }
    return true;
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'azkar_channel',
      'تذكير الأذكار',
      description: 'إشعارات تذكير أذكار الصباح والمساء',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.createNotificationChannel(channel);
  }

  static Future<void> scheduleMorningAzkar(TimeOfDay time) async {
    await _notifications.zonedSchedule(
      1,
      '🌅 أذكار الصباح',
      'حان وقت أذكار الصباح، ابدأ يومك بذكر الله',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'azkar_channel',
          'تذكير الأذكار',
          channelDescription: 'إشعارات تذكير أذكار الصباح والمساء',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleEveningAzkar(TimeOfDay time) async {
    await _notifications.zonedSchedule(
      2,
      '🌙 أذكار المساء',
      'حان وقت أذكار المساء، اختتم يومك بذكر الله',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'azkar_channel',
          'تذكير الأذكار',
          channelDescription: 'إشعارات تذكير أذكار الصباح والمساء',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static Future<void> cancelMorningNotification() async {
    await _notifications.cancel(1);
  }

  static Future<void> cancelEveningNotification() async {
    await _notifications.cancel(2);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> refreshScheduledNotifications() async {
    final morningEnabled =
        await NotificationSettingsService.isMorningNotificationEnabled();
    final eveningEnabled =
        await NotificationSettingsService.isEveningNotificationEnabled();

    if (morningEnabled) {
      final morningTime = await NotificationSettingsService.getMorningTime();
      await scheduleMorningAzkar(morningTime);
    }

    if (eveningEnabled) {
      final eveningTime = await NotificationSettingsService.getEveningTime();
      await scheduleEveningAzkar(eveningTime);
    }
  }
}

class NotificationSettingsService {
  static const String _morningEnabledKey = 'morning_notification_enabled';
  static const String _eveningEnabledKey = 'evening_notification_enabled';
  static const String _morningTimeKey = 'morning_notification_time';
  static const String _eveningTimeKey = 'evening_notification_time';

  static Future<void> setMorningNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_morningEnabledKey, enabled);
  }

  static Future<void> setEveningNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eveningEnabledKey, enabled);
  }

  static Future<void> setMorningTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_morningTimeKey, '${time.hour}:${time.minute}');
  }

  static Future<void> setEveningTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_eveningTimeKey, '${time.hour}:${time.minute}');
  }

  static Future<bool> isMorningNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_morningEnabledKey) ?? true;
  }

  static Future<bool> isEveningNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_eveningEnabledKey) ?? true;
  }

  static Future<TimeOfDay> getMorningTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_morningTimeKey) ?? '6:0';
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static Future<TimeOfDay> getEveningTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_eveningTimeKey) ?? '18:0';
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
