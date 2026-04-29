import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static final InAppReview _inAppReview = InAppReview.instance;
  static const String _lastReviewDateKey = 'last_review_date';
  static const String _appOpenCountKey = 'app_open_count';

  /// إظهار صفحة التقييم يدوياً (دائماً تفتح المتجر لضمان الاستجابة)
  static Future<void> requestManualReview() async {
    // نفتح صفحة المتجر مباشرة لأن المستخدم هو من طلب التقييم
    await _inAppReview.openStoreListing(
      appStoreId: 'com.zaid.thekr_app',
    );
  }

  /// منطق ذكي لإظهار التقييم تلقائياً (مثلاً بعد 5 مرات فتح للتطبيق)
  static Future<void> requestAutoReview() async {
    final prefs = await SharedPreferences.getInstance();
    int openCount = prefs.getInt(_appOpenCountKey) ?? 0;
    openCount++;
    await prefs.setInt(_appOpenCountKey, openCount);

    // نطلب التقييم تلقائياً فقط إذا فتح التطبيق 5 مرات أو 15 مرة أو 30 مرة
    if (openCount == 5 || openCount == 15 || openCount == 30) {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
    }
  }
}
