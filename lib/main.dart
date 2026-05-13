import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_library/quran.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/notification_service.dart';
import 'package:thekr_app/my_app.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:thekr_app/core/utils/constants/app_constants.dart';
import 'package:thekr_app/firebase_options.dart';
import 'package:thekr_app/core/services/remote_config_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:timezone/data/latest_all.dart' as tz;

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

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
  } catch (e, stack) {
    debugPrint("Error during initialization: $e");
    // Ensure we record the error even if Firebase hasn't finished initializing perfectly
    try {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
    } catch (_) {}
  } finally {
    runApp(
      ProviderScope(
        child: DevicePreview(
          enabled: !kReleaseMode,
          builder: (context) => const MyApp(),
        ),
      ),
    );

    // Always remove splash screen after the app is ready or even if it fails
    FlutterNativeSplash.remove();
  }
}
