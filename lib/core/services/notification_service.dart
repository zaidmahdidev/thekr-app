import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:thekr_app/core/services/prayer_service.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';

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
    // Initialize timezone data
    tz_data.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timezoneName = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (e) {
      debugPrint("Could not set local location, falling back to UTC: $e");
      try {
        // Try UTC as fallback
        tz.setLocalLocation(tz.UTC);
      } catch (e2) {
        debugPrint("Critical: UTC location not found: $e2");
      }
    }

    // Initialize FCM
    await _initializeFCM();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(
      settings: initializationSettings,
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
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: const NotificationDetails(
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
      final payload =
          notificationAppLaunchDetails?.notificationResponse?.payload;
      if (payload != null) {
        Future.delayed(const Duration(seconds: 1), () {
          onNotificationClick?.call(payload);
        });
      }
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      // FCM Permissions - Wrap in extra try/catch for Android context issues
      NotificationSettings? settings;
      try {
        settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
      } catch (fcmError) {
        debugPrint("FCM Permission request failed: $fcmError");
      }

      final bool fcmGranted =
          settings?.authorizationStatus == AuthorizationStatus.authorized;

      // Local Notifications Permissions
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        bool granted = false;
        bool exactAlarmGranted = false;

        try {
          granted = await androidImplementation.requestNotificationsPermission() ?? false;
          exactAlarmGranted = await androidImplementation.requestExactAlarmsPermission() ?? false;
        } catch (localError) {
          debugPrint("Local Notification Permission request failed: $localError");
        }

        await _createNotificationChannel();

        return (granted) && (exactAlarmGranted) && fcmGranted;
      }
      return fcmGranted;
    } catch (e) {
      debugPrint("General error requesting notification permissions: $e");
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

  static Future<void> _createAthanChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'athan_channel',
      'أذان الصلوات',
      description: 'إشعارات الأذان للصلوات الخمس',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('athan'),
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.createNotificationChannel(channel);
  }

  static Future<void> _createDuroodChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'durood_channel',
      'الصلاة على النبي',
      description: 'تذكير دوري بالصلاة على النبي',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('durood'),
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
      id: 1,
      title: '🌅 أذكار الصباح',
      body: 'حان وقت أذكار الصباح، ابدأ يومك بذكر الله',
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: const NotificationDetails(
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
      id: 2,
      title: '🌙 أذكار المساء',
      body: 'حان وقت أذكار المساء، اختتم يومك بذكر الله',
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: const NotificationDetails(
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
      id: 3,
      title: '📖 سورة الكهف',
      body: 'يوم الجمعة، لا تنسَ قراءة سورة الكهف، نورٌ ما بين الجمعتين',
      scheduledDate: _nextInstanceOfFriday(time),
      notificationDetails: const NotificationDetails(
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
      id: 4,
      title: '📖 الورد اليومي',
      body: 'تذكير بقراءة الورد اليومي من القرآن الكريم، اجعل لك نصيباً من كتاب الله',
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: const NotificationDetails(
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

  static Future<void> scheduleAthan(int id, String title, String body, DateTime time) async {
    await _createAthanChannel();
    
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(time, tz.local);
    
    // If the time is in the past, schedule it for tomorrow to avoid crashes
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: const AndroidNotificationDetails(
          'athan_channel',
          'أذان الصلوات',
          channelDescription: 'إشعارات الأذان للصلوات الخمس',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('athan'),
          enableVibration: true,
          fullScreenIntent: true,
        ),
        iOS: const DarwinNotificationDetails(
          sound: 'makkah.aiff', // We will need to map this in iOS later if provided
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'athan_$id',
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
    await _notifications.cancel(id: 1);
  }

  static Future<void> cancelEveningNotification() async {
    await _notifications.cancel(id: 2);
  }

  static Future<void> cancelFridayNotification() async {
    await _notifications.cancel(id: 3);
  }

  static Future<void> cancelWirdNotification() async {
    await _notifications.cancel(id: 4);
  }

  static Future<void> cancelDuroodNotifications() async {
    for (int i = 20; i <= 100; i++) {
      await _notifications.cancel(id: i);
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> cancelAthanNotifications() async {
    for (int i = 10; i <= 15; i++) {
      await _notifications.cancel(id: i);
    }
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

    final duroodInterval = await SettingsService.getDuroodInterval();
    await scheduleDuroodReminders(duroodInterval);

    await cancelAthanNotifications();
    
    final times = await PrayerService.getCurrentPrayerTimes();
    
    if (times != null) {
      if (await SettingsService.isFajrAthanEnabled()) {
        await scheduleAthan(10, 'صلاة ${AppPrayer.fajr.nameArabic}', 'حان الآن موعد صلاة ${AppPrayer.fajr.nameArabic}', times.fajr);
      }
      if (await SettingsService.isDhuhrAthanEnabled()) {
        await scheduleAthan(11, 'صلاة ${AppPrayer.dhuhr.nameArabic}', 'حان الآن موعد صلاة ${AppPrayer.dhuhr.nameArabic}', times.dhuhr);
      }
      if (await SettingsService.isAsrAthanEnabled()) {
        await scheduleAthan(12, 'صلاة ${AppPrayer.asr.nameArabic}', 'حان الآن موعد صلاة ${AppPrayer.asr.nameArabic}', times.asr);
      }
      if (await SettingsService.isMaghribAthanEnabled()) {
        await scheduleAthan(13, 'صلاة ${AppPrayer.maghrib.nameArabic}', 'حان الآن موعد موعد صلاة ${AppPrayer.maghrib.nameArabic}', times.maghrib);
      }
      if (await SettingsService.isIshaAthanEnabled()) {
        await scheduleAthan(14, 'صلاة ${AppPrayer.isha.nameArabic}', 'حان الآن موعد صلاة ${AppPrayer.isha.nameArabic}', times.isha);
      }
    }
  }

  static Future<void> scheduleDuroodReminders(int intervalMinutes) async {
    await cancelDuroodNotifications();
    
    if (intervalMinutes <= 0) return; // Disabled

    await _createDuroodChannel();

    if (intervalMinutes == 10080) { // 168 hours * 60
      // Friday only specific times
      final fridayTimes = [
        const TimeOfDay(hour: 8, minute: 0),
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 10, minute: 0),
        const TimeOfDay(hour: 11, minute: 0),
        const TimeOfDay(hour: 14, minute: 0),
        const TimeOfDay(hour: 15, minute: 0),
        const TimeOfDay(hour: 16, minute: 0),
        const TimeOfDay(hour: 17, minute: 0),
        const TimeOfDay(hour: 18, minute: 0),
      ];
      for (int i = 0; i < fridayTimes.length; i++) {
        await _scheduleDuroodAt(20 + i, fridayTimes[i], isFriday: true);
      }
      return;
    }

    // Daily intervals
    final int count = (24 * 60) ~/ intervalMinutes;
    int scheduledId = 20;
    for (int i = 0; i < count; i++) {
      // Start the cycle at 8:00 AM instead of midnight
      final int totalMinutes = (8 * 60) + (i * intervalMinutes);
      final int hour = (totalMinutes ~/ 60) % 24;
      final int minute = totalMinutes % 60;
      
      // Skip sleeping hours (from 11:00 PM (23) to 7:59 AM (7))
      if (hour >= 23 || hour <= 7) {
        continue;
      }
      
      await _scheduleDuroodAt(scheduledId++, TimeOfDay(hour: hour, minute: minute));
    }
  }

  static Future<void> _scheduleDuroodAt(int id, TimeOfDay time, {bool isFriday = false}) async {
    final scheduledDate = isFriday ? _nextInstanceOfFriday(time) : _nextInstanceOfTime(time);
    
    await _notifications.zonedSchedule(
      id: id,
      title: 'ﷺ',
      body: 'صلِّ على من بكى شوقاً لرؤيتك',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'durood_channel',
          'الصلاة على النبي',
          channelDescription: 'تذكير دوري بالصلاة على النبي',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('durood'),
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'durood.aiff',
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: isFriday ? DateTimeComponents.dayOfWeekAndTime : DateTimeComponents.time,
      payload: 'durood',
    );
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
  static const String _athanEnabledKey = 'athan_enabled';
  static const String _duroodIntervalKey = 'durood_interval_minutes';

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

  static Future<void> setFajrAthanEnabled(bool enabled) async => (await SharedPreferences.getInstance()).setBool('fajr_athan_enabled', enabled);
  static Future<bool> isFajrAthanEnabled() async => (await SharedPreferences.getInstance()).getBool('fajr_athan_enabled') ?? true;

  static Future<void> setDhuhrAthanEnabled(bool enabled) async => (await SharedPreferences.getInstance()).setBool('dhuhr_athan_enabled', enabled);
  static Future<bool> isDhuhrAthanEnabled() async => (await SharedPreferences.getInstance()).getBool('dhuhr_athan_enabled') ?? true;

  static Future<void> setAsrAthanEnabled(bool enabled) async => (await SharedPreferences.getInstance()).setBool('asr_athan_enabled', enabled);
  static Future<bool> isAsrAthanEnabled() async => (await SharedPreferences.getInstance()).getBool('asr_athan_enabled') ?? true;

  static Future<void> setMaghribAthanEnabled(bool enabled) async => (await SharedPreferences.getInstance()).setBool('maghrib_athan_enabled', enabled);
  static Future<bool> isMaghribAthanEnabled() async => (await SharedPreferences.getInstance()).getBool('maghrib_athan_enabled') ?? true;

  static Future<void> setIshaAthanEnabled(bool enabled) async => (await SharedPreferences.getInstance()).setBool('isha_athan_enabled', enabled);
  static Future<bool> isIshaAthanEnabled() async => (await SharedPreferences.getInstance()).getBool('isha_athan_enabled') ?? true;

  // 0 means disabled, 30 = half hour, 60 = hour, 180 = 3 hours, 360 = 6 hours, 1440 = once a day, 10080 = friday only
  static Future<void> setDuroodInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_duroodIntervalKey, minutes);
    await NotificationService.scheduleDuroodReminders(minutes);
  }

  static Future<int> getDuroodInterval() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to 0 (disabled)
    return prefs.getInt(_duroodIntervalKey) ?? 0;
  }
}
