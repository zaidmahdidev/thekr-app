import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

/// Opens links in other apps. Never throws: when no app can open the link
/// (for example no email app installed), it returns false.
class UrlHelper {
  static Future<bool> _open(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    try {
      return await launchUrl(uri, mode: mode);
    } catch (e) {
      debugPrint('Could not launch $uri: $e');
      return false;
    }
  }

  /// فتح أي رابط خارجي (موقع ويب)
  static Future<bool> launchURL(String url) =>
      _open(Uri.parse(url), mode: LaunchMode.externalApplication);

  /// فتح الواتساب برقم محدد ورسالة اختيارية
  static Future<bool> launchWhatsApp({
    required String phone,
    String message = '',
  }) async {
    // إزالة أي رموز غير أرقام من الرقم
    final String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final String webUrl =
        "https://wa.me/$cleanPhone/?text=${Uri.encodeComponent(message)}";

    final String url = Platform.isAndroid
        ? webUrl
        : "whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}";

    if (await _open(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      return true;
    }
    // إذا فشل فتح التطبيق، نحاول فتح المتصفح
    return launchURL(webUrl);
  }

  /// فتح تطبيق البريد الإلكتروني
  static Future<bool> launchEmail({
    required String email,
    String subject = '',
    String body = '',
  }) {
    return _open(
      Uri.parse(
        'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
      ),
    );
  }

  /// الاتصال برقم هاتف
  static Future<bool> launchPhone(String phone) =>
      _open(Uri.parse('tel:$phone'));

  /// فتح خرائط جوجل
  static Future<bool> launchMaps(double lat, double lng) => launchURL(
    "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
  );
}
