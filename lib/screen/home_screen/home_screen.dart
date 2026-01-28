import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:thekr_app/screen/hadith-_awawi/hadith_nawawi.dart';
import 'package:thekr_app/screen/notification_settings/notification_settings_screen.dart';
import 'package:thekr_app/shard/theme/myColors.dart';

import '../../network/local/cache_helper.dart';
import '../../shard/components/tools.dart';
import '../../shard/constant/theme.dart';
import '../asmaAllah_screen/asmaAllah_screen.dart';
import '../azkar_screen/azkar_screen.dart';
import '../husinAlMuslim_screen/husinAlMuslim_screen.dart';
import '../qiblah_screen/qiblah_screen.dart';
import '../sura_screen/sura_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // Start flexible update (optional)
        await InAppUpdate.startFlexibleUpdate();

        // Show snackbar when download is complete
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'تم تحميل التحديث بنجاح، يرجى الضغط للتثبيت',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: MyTheme.secondaryColor,
              duration: const Duration(seconds: 10),
              action: SnackBarAction(
                label: 'تثبيت',
                textColor: Colors.white,
                onPressed: () async {
                  await InAppUpdate.completeFlexibleUpdate();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _exitMethode(context);
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: MyTheme.primaryColor,

          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    const Image(
                      fit: BoxFit.fill,
                      width: double.infinity,
                      image: AssetImage('assets/images/hero.png'),
                    ),
                    Center(
                      child: Image(
                        width: 220,
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/quran_logo.png'),
                      ),
                    ),
                    Positioned(
                      left: 5,
                      top: 5,
                      child: CircleAvatar(
                        backgroundColor: MyColors.primaryColor,
                        radius: 27,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: MyTheme.primaryColor,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationSettingsScreen(),
                                ),
                              );
                            },
                            child: Image(
                              width: 40,
                              fit: BoxFit.cover,
                              image: AssetImage(
                                'assets/images/app_notification.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CategoryWidget(
                              title: "القران الكريم",
                              imgUrl: 'assets/images/quran.png',
                              fun: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SurahScreen(
                                      currentPage:
                                          CacheHelper.getData(
                                            key: 'pageNumber',
                                          ) ??
                                          1,
                                    ),
                                  ),
                                );
                              },
                            ),
                            CategoryWidget(
                              title: "الاذكار",
                              imgUrl: 'assets/images/praying.png',
                              fun: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AzkarScreen(),
                                  ),
                                );
                              },
                            ),
                            CategoryWidget(
                              title: "حصن المسلم",
                              imgUrl: 'assets/images/husnalmoslem.png',
                              fun: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HusinAlMuslimScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Row(
                          children: [
                            CategoryWidget(
                              title: "الاربعين النووية",
                              imgUrl: 'assets/images/hadithNawawi.webp',
                              fun: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HadithNawawiScreen(),
                                  ),
                                );
                              },
                            ),
                            CategoryWidget(
                              title: "أسماء الله",
                              imgUrl: 'assets/images/AllahNames.png',
                              fun: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AsmaAllahScreen(),
                                  ),
                                );
                              },
                            ),
                            CategoryWidget(
                              title: "إتجاة القبلة",
                              imgUrl: 'assets/images/keblah.png',
                              fun: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QiblahScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exitMethode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'تنويه',
        message: 'هل أنت متأكد أنك تريد الخروج؟',
        onYes: () => SystemNavigator.pop(),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    super.key,
    required this.imgUrl,
    required this.title,
    required this.fun,
  });

  final String imgUrl;
  final String title;
  final Function fun;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            fun();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Image(
                  height: MediaQuery.of(context).size.width / 5,
                  fit: BoxFit.fill,
                  image: AssetImage(imgUrl),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
