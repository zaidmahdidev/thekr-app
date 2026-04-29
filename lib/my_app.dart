import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:thekr_app/core/localization/app_localizations.dart';
import 'package:thekr_app/main.dart';

import 'package:thekr_app/core/router/app_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

import 'package:thekr_app/core/services/notification_service.dart';
import 'package:thekr_app/core/services/review_service.dart';
import 'package:thekr_app/features/azkar/data/azkar_model.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _appRouter = AppRouter();

  @override
  void initState() {
    super.initState();
    _setupNotificationHandling();
    ReviewService.requestAutoReview();
  }

  void _setupNotificationHandling() {
    NotificationService.onNotificationClick = (payload) {
      if (payload == null) return;

      if (payload == 'morning') {
        _appRouter.push(
          AzkarListRoute(
            azkarList: List<Map<String, String>>.from(azkarList['أذكار الصباح']),
            type: 'أذكار الصباح',
          ),
        );
      } else if (payload == 'evening') {
        _appRouter.push(
          AzkarListRoute(
            azkarList: List<Map<String, String>>.from(azkarList['أذكار المساء']),
            type: 'أذكار المساء',
          ),
        );
      } else if (payload == 'surah_kahf') {
        _appRouter.push(SurahRoute(currentPage: 293));
      }
    };

    // التحقق من وجود إشعار تسبب في فتح التطبيق
    NotificationService.checkLaunchNotification();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final themeMode = settings.themeMode;

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'ذِكر',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            for (var locale in supportedLocales) {
              if (deviceLocale != null &&
                  deviceLocale.languageCode == locale.languageCode) {
                return deviceLocale;
              }
            }
            return supportedLocales.first;
          },
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: scaffoldMessengerKey,
          routerConfig: _appRouter.config(),
        );
      },
    );
  }
}
