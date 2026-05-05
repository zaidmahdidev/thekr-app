import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here if needed
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Function(String?)? onNotificationClick;

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Initialize FCM
    await _initializeFCM();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationClick?.call(response.payload);
      },
    );
  }

  static Future<void> _initializeFCM() async {
    // Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get FCM Token
    try {
      String? token = await _messaging.getToken();
      debugPrint("FCM Token: $token");
      // You can save this token to your server here
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _notifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
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
        );
      }
    });
  }

  static Future<void> checkLaunchNotification() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await _notifications.getNotificationAppLaunchDetails();
    
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload = notificationAppLaunchDetails?.notificationResponse?.payload;
      if (payload != null) {
        Future.delayed(const Duration(seconds: 1), () {
          onNotificationClick?.call(payload);
        });
      }
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      // FCM Permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final bool fcmGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      // Local Notifications Permissions
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation
            .requestNotificationsPermission();
        final bool? exactAlarmGranted = await androidImplementation
            .requestExactAlarmsPermission();

        await _createNotificationChannel();

        return (granted ?? false) && (exactAlarmGranted ?? false) && fcmGranted;
      }
      return fcmGranted;
    } catch (e) {
      debugPrint("Error requesting notification permissions: $e");
      return false;
    }
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
      payload: 'morning', 
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
      payload: 'evening',
    );
  }

  static Future<void> scheduleFridayKahf(TimeOfDay time) async {
    await _notifications.zonedSchedule(
      3,
      '📖 سورة الكهف',
      'يوم الجمعة، لا تنسَ قراءة سورة الكهف، نورٌ ما بين الجمعتين',
      _nextInstanceOfFriday(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'azkar_channel',
          'تذكير الأذكار',
          channelDescription: 'إشعارات تذكير أذكار الصباح والمساء والكهف',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'surah_kahf',
    );
  }

  static Future<void> scheduleWirdNotification(TimeOfDay time) async {
    await _notifications.zonedSchedule(
      4,
      '📖 الورد اليومي',
      'تذكير بقراءة الورد اليومي من القرآن الكريم، اجعل لك نصيباً من كتاب الله',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'azkar_channel',
          'تذكير الأذكار',
          channelDescription: 'إشعارات تذكير الورد اليومي والأذكار',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'quran_wird',
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

  static tz.TZDateTime _nextInstanceOfFriday(TimeOfDay time) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);
    while (scheduledDate.weekday != DateTime.friday) {
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

  static Future<void> cancelFridayNotification() async {
    await _notifications.cancel(3);
  }

  static Future<void> cancelWirdNotification() async {
    await _notifications.cancel(4);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> refreshScheduledNotifications() async {
    final morningEnabled = await SettingsService.isMorningNotificationEnabled();
    final eveningEnabled = await SettingsService.isEveningNotificationEnabled();
    final fridayEnabled = await SettingsService.isFridayNotificationEnabled();
    final wirdEnabled = await SettingsService.isWirdNotificationEnabled();

    if (morningEnabled) {
      final morningTime = await SettingsService.getMorningTime();
      await scheduleMorningAzkar(morningTime);
    }

    if (eveningEnabled) {
      final eveningTime = await SettingsService.getEveningTime();
      await scheduleEveningAzkar(eveningTime);
    }

    if (fridayEnabled) {
      await scheduleFridayKahf(const TimeOfDay(hour: 8, minute: 0));
    }

    if (wirdEnabled) {
      final wirdTime = await SettingsService.getWirdTime();
      await scheduleWirdNotification(wirdTime);
    }
  }
}

class SettingsService {
  static const String _morningEnabledKey = 'morning_notification_enabled';
  static const String _eveningEnabledKey = 'evening_notification_enabled';
  static const String _fridayEnabledKey = 'friday_notification_enabled';
  static const String _wirdEnabledKey = 'wird_notification_enabled';
  static const String _morningTimeKey = 'morning_notification_time';
  static const String _eveningTimeKey = 'evening_notification_time';
  static const String _wirdTimeKey = 'wird_notification_time';

  static Future<void> setMorningNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_morningEnabledKey, enabled);
  }

  static Future<void> setEveningNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eveningEnabledKey, enabled);
  }

  static Future<void> setFridayNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fridayEnabledKey, enabled);
  }

  static Future<void> setWirdNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_wirdEnabledKey, enabled);
  }

  static Future<void> setMorningTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_morningTimeKey, '${time.hour}:${time.minute}');
  }

  static Future<void> setEveningTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_eveningTimeKey, '${time.hour}:${time.minute}');
  }

  static Future<void> setWirdTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wirdTimeKey, '${time.hour}:${time.minute}');
  }

  static Future<bool> isMorningNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_morningEnabledKey) ?? true;
  }

  static Future<bool> isEveningNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_eveningEnabledKey) ?? true;
  }

  static Future<bool> isFridayNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_fridayEnabledKey) ?? true;
  }

  static Future<bool> isWirdNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_wirdEnabledKey) ?? false;
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

  static Future<TimeOfDay> getWirdTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_wirdTimeKey) ?? '21:0';
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
