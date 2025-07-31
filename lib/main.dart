import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:thekr_app/screen/splash_screen/splash_screen.dart';
import 'package:thekr_app/shard/constant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'network/local/cache_helper.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheHelper.init();

  SystemChrome.setPreferredOrientations(
    [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late InAppUpdate inAppUpdate;

  @override
  void initState() {
    super.initState();
    inAppUpdate = InAppUpdate();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    await InAppUpdate.checkForUpdate().then((info) {
      if (info.updateAvailability == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('تحديث جديد متوفر'),
              content: const Text('تحديث جديد للتطبيق متاح في Google Play. يرجى تحديث التطبيق للاستمرار.'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('تحديث'),
                  onPressed: () {
                    InAppUpdate.startFlexibleUpdate().whenComplete(() {
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: MyTheme.primaryColor,
        primarySwatch: primary,
        appBarTheme:  AppBarTheme(
          toolbarHeight: 80,
          backgroundColor: MyTheme.primaryColor,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(15), bottomLeft: Radius.circular(15)),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            // color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,

          ),
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
