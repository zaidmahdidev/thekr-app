import 'package:package_info_plus/package_info_plus.dart';

class AppConstants {
  static const String appName = 'ذكر';
  static String appVersion = '1.2.0';

  // Initialize app constants (to be called in main)
  static Future<void> init() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
    } catch (e) {
      // Keep default if it fails
    }
  }

  // Package Name (تأكد من مطابقتها لما هو موجود في الـ AndroidManifest)
  static const String packageName = 'com.zaid.thekr_app';

  // App Links
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$packageName';
  static const String appStoreUrl =
      'https://apps.apple.com/app/idYOUR_APP_ID'; // for ios

  // Social Media & Support
  static const String supportEmail = 'zaidmhdi33@gmail.com';
  static const String whatsappNumber = '+967774814210';
  static const String developerNumber = '+966559291894';

  // Sharing Text
  static const String shareMessage =
      'حمّل تطبيق "ذكر" الآن، رفيقك في الأذكار والعبادات:\n$playStoreUrl';

  // Social Links
  static const String websiteUrl = 'https://zaidmahdi.vercel.app';
  static const String developerName = 'م.زيد مهدي';
  static const String privacyPolicyUrl =
      'https://zaidmahdidev.github.io/privacy-policy-thekr/';
}
