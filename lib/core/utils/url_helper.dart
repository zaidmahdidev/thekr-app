import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class UrlHelper {
  /// فتح أي رابط خارجي (موقع ويب)
  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  /// فتح الواتساب برقم محدد ورسالة اختيارية
  static Future<void> launchWhatsApp({
    required String phone,
    String message = '',
  }) async {
    // إزالة أي رموز غير أرقام من الرقم
    final String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    
    String url = '';
    if (Platform.isAndroid) {
      url = "https://wa.me/$cleanPhone/?text=${Uri.encodeComponent(message)}";
    } else {
      url = "whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}";
    }

    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // إذا فشل فتح التطبيق، نحاول فتح المتصفح
      await launchURL("https://wa.me/$cleanPhone/?text=${Uri.encodeComponent(message)}");
    }
  }

  /// فتح تطبيق البريد الإلكتروني
  static Future<void> launchEmail({
    required String email,
    String subject = '',
    String body = '',
  }) async {
    final Uri uri = Uri.parse(
      'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch email to $email');
    }
  }

  /// الاتصال برقم هاتف
  static Future<void> launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch phone call to $phone');
    }
  }

  /// فتح خرائط جوجل
  static Future<void> launchMaps(double lat, double lng) async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    final Uri uri = Uri.parse(googleMapsUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch maps');
    }
  }
}
