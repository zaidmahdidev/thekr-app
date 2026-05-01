import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_library/quran.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/notification_service.dart';
import 'package:thekr_app/my_app.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:thekr_app/core/utils/constants/app_constants.dart';
import 'package:thekr_app/firebase_options.dart';
import 'package:thekr_app/core/services/remote_config_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await RemoteConfigService().init();
  await AppConstants.init();
  await initializeDateFormatting('ar', null);

  await CacheHelper.init();
  await NotificationService.initialize();
  await NotificationService.requestPermissions();
  await NotificationService.refreshScheduledNotifications();

  await QuranLibrary.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}
