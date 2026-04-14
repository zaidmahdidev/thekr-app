import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:thekr_app/core/widgets/custom_dialog.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/extensions/size_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/router/app_router.dart';

@RoutePage()
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
        final result = await InAppUpdate.startFlexibleUpdate();

        // Show snackbar for 3 seconds then install automatically
        if (result == AppUpdateResult.success && mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: Text(
                    'تم تحميل التحديث بنجاح، جاري التثبيت...',
                    style: AppTypography.bodyMedium,
                  ),
                  backgroundColor: context.colors.secondary,
                  duration: const Duration(seconds: 3),
                ),
              )
              .closed
              .then((reason) {
                if (mounted) {
                  InAppUpdate.completeFlexibleUpdate();
                }
              });
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
          backgroundColor: context.colors.primary,

          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    const Image(
                      fit: BoxFit.fill,
                      width: double.infinity,
                      image: AssetImage(AppAssets.hero),
                    ),
                    Center(
                      child: Image(
                        width: context.getWidth(55),
                        fit: BoxFit.fill,
                        image: AssetImage(AppAssets.quranLogo),
                      ),
                    ),
                    Positioned(
                      left: 5,
                      top: 5,
                      child: CircleAvatar(
                        backgroundColor: context.colors.secondary,
                        radius: 27,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: context.colors.primary,
                          child: GestureDetector(
                            onTap: () {
                              context.router.push(
                                const NotificationSettingsRoute(),
                              );
                            },
                            child: Image(
                              width: context.getWidth(10),
                              fit: BoxFit.cover,
                              image: AssetImage(AppAssets.notification),
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(context.corners.xl * 3),
                      topRight: Radius.circular(context.corners.xl * 3),
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
                              imgUrl: AppAssets.quran,
                              fun: () {
                                context.router.push(
                                  SurahRoute(
                                    currentPage:
                                        CacheHelper.getData(
                                          key: 'pageNumber',
                                        ) ??
                                        1,
                                  ),
                                );
                              },
                            ),
                            CategoryWidget(
                              title: "الاذكار",
                              imgUrl: AppAssets.azkar,
                              fun: () {
                                context.router.push(const AzkarRoute());
                              },
                            ),
                            CategoryWidget(
                              title: "حصن المسلم",
                              imgUrl: AppAssets.husnAlMuslim,
                              fun: () {
                                context.router.push(const HusinAlMuslimRoute());
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
                              imgUrl: AppAssets.hadith,
                              fun: () {
                                context.router.push(const HadithNawawiRoute());
                              },
                            ),
                            CategoryWidget(
                              title: "أسماء الله",
                              imgUrl: AppAssets.asmaAllah,
                              fun: () {
                                context.router.push(AsmaAllahRoute());
                              },
                            ),
                            CategoryWidget(
                              title: "إتجاة القبلة",
                              imgUrl: AppAssets.qiblah,
                              fun: () {
                                context.router.push(const QiblahRoute());
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
          color: context.colors.surface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(context.corners.md),
        ),
        margin: EdgeInsets.all(context.insets.sm / 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.md),
          onTap: () {
            fun();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Image(
                  height: context.getWidth(20),
                  fit: BoxFit.fill,
                  image: AssetImage(imgUrl),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  color: context.colors.surface,
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
