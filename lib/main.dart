import 'package:flutter/material.dart';
import 'network/local/cache_helper.dart';
import 'services/notification_service.dart';
import 'package:thekr_app/screen/home_screen/home_screen.dart';
import 'package:thekr_app/shard/constant/theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:thekr_app/shard/AppLocalizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheHelper.init();
  await NotificationService.initialize();
  await NotificationService.requestPermissions();
  await NotificationService.refreshScheduledNotifications();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: MyTheme.primaryColor,
        primarySwatch: primary,
        appBarTheme: const AppBarTheme(
          toolbarHeight: 80,
          backgroundColor: MyTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        fontFamily: 'Tajawal',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(height: 1.6),
          bodyLarge: TextStyle(height: 1.6),
          titleMedium: TextStyle(height: 1.6),
        ),
      ),
      title: 'ذِكر',
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
      home: const HomeScreen(),
    );
  }
}
