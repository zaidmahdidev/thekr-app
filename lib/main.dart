import 'package:flutter/services.dart';
import 'package:thekr_app/screen/splash_screen/splash_screen.dart';
import 'package:thekr_app/shard/constant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'network/local/cache_helper.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheHelper.init();
  await NotificationService.initialize();
  await NotificationService.requestPermissions();

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
    return GetMaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: MyTheme.primaryColor,
        primarySwatch: primary,
        appBarTheme: AppBarTheme(
          toolbarHeight: 80,
          backgroundColor: MyTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        fontFamily: 'quran',
      ),
      title: 'Dhikr',
      locale: const Locale('ar'),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
