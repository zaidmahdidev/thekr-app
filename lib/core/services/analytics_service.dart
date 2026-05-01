import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // تسجيل فتح شاشة معينة
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // تسجيل قراءة ذكر معين
  static Future<void> logZekrSelected(String category, String zekrTitle) async {
    await _analytics.logEvent(
      name: 'zekr_selected',
      parameters: {
        'category': category,
        'title': zekrTitle,
      },
    );
  }

  // تسجيل تغيير في الإعدادات
  static Future<void> logSettingChanged(String settingName, String value) async {
    await _analytics.logEvent(
      name: 'setting_changed',
      parameters: {
        'setting': settingName,
        'value': value,
      },
    );
  }
}
