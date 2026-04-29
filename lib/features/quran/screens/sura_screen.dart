import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_library/quran_library.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';
import 'dart:io';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class SurahScreen extends StatefulWidget {
  final int currentPage;
  const SurahScreen({super.key, required this.currentPage});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> with WidgetsBindingObserver {
  late int lastPage;
  bool isDarkMode = false;
  bool _isCapturing = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    lastPage = widget.currentPage;
    isDarkMode = CacheHelper.getData(key: 'isDarkMode') ?? false;

    // Jump to the saved page after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      QuranLibrary().jumpToPage(lastPage);
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    CacheHelper.saveData(key: 'isDarkMode', value: isDarkMode);
  }

  Future<void> _shareCurrentPage() async {
    try {
      setState(() => _isCapturing = true);

      final uint8list = await _screenshotController.capture(
        pixelRatio: 2.0,
        delay: const Duration(milliseconds: 100),
      );

      setState(() => _isCapturing = false);

      if (uint8list != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File(
          '${directory.path}/quran_page_$lastPage.png',
        ).create();
        await imagePath.writeAsBytes(uint8list);

        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: AppConstants.shareMessage,
        );
      }
    } catch (e) {
      showToast(text: 'حدث خطأ أثناء المشاركة');
      setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.removeObserver(this);
    CacheHelper.saveData(key: 'pageNumber', value: lastPage);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      CacheHelper.saveData(key: 'pageNumber', value: lastPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: QuranLibraryScreen(
        parentContext: context,
        isDark: isDarkMode,
        showAyahBookmarkedIcon: true,
        useDefaultAppBar: !_isCapturing,
        appLanguageCode: 'ar',
        isShowTabBar: !_isCapturing,
        enableWordSelection: true,
        isShowAudioSlider: !_isCapturing,
        topBarStyle:
            QuranTopBarStyle.defaults(
              isDark: isDarkMode,
              context: context,
            ).copyWith(
              backgroundColor: context.colors.primary,
              customTopBarWidgets: [
                IconButton(
                  onPressed: toggleTheme,
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: context.colors.primary,
                  ),
                  tooltip: 'تبديل المظهر',
                ),
                IconButton(
                  onPressed: _shareCurrentPage,
                  icon: Icon(Icons.share, color: context.colors.primary),
                  tooltip: 'مشاركة الصفحة',
                ),
              ],
            ),
        onPageChanged: (page) {
          int realPage = page + 1;
          lastPage = realPage;
          CacheHelper.saveData(key: 'pageNumber', value: realPage);
        },
        backgroundColor: isDarkMode
            ? const Color(0xff181818)
            : const Color(0xfffffbec),
        textColor: isDarkMode ? Colors.white : Colors.black,
        ayahIconColor: isDarkMode ? Colors.white : context.colors.primary,
        ayahSelectedBackgroundColor: context.colors.primary.withValues(
          alpha: 0.15,
        ),
      ),
    );
  }
}
