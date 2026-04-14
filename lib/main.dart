import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_library/quran.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/notification_service.dart';
import 'package:thekr_app/my_app.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheHelper.init();
  await NotificationService.initialize();
  await NotificationService.requestPermissions();
  await NotificationService.refreshScheduledNotifications();

  await QuranLibrary.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}
