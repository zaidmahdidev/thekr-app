import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_library/quran_library.dart';
import 'package:thekr_app/shard/constant/theme.dart';
import 'package:screenshot/screenshot.dart';
import '../../network/local/cache_helper.dart';
import '../../shard/utils/share_helper.dart';

class QuranView extends StatefulWidget {
  final int currentPage;
  const QuranView({super.key, required this.currentPage});

  @override
  State<QuranView> createState() => _QuranViewState();
}

class _QuranViewState extends State<QuranView> with WidgetsBindingObserver {
  late int lastPage;
  bool isDarkMode = false;
  bool _isCapturing = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Use the passed current page
    lastPage = widget.currentPage;
    isDarkMode = CacheHelper.getData(key: 'isDarkMode') ?? false;

    // Programmatically jump to the saved page after the screen is ready
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
    setState(() => _isCapturing = true);
    await Future.delayed(const Duration(milliseconds: 100));

    final bytes = await _screenshotController.capture(pixelRatio: 2.5);

    setState(() => _isCapturing = false);

    if (!mounted || bytes == null) return;

    ShareHelper.showQuranShareOptions(
      context,
      pageScreenshot: bytes,
      isDark: isDarkMode,
      pageNumber: lastPage,
    );
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
        appIconPathForPlayAudioInBackground: 'assets/images/thekr.png',
        parentContext: context,
        isDark: isDarkMode,
        showAyahBookmarkedIcon: true,
        useDefaultAppBar: !_isCapturing,
        appLanguageCode: 'ar',
        isShowTabBar: !_isCapturing,
        isFontsLocal: false,
        enableWordSelection: true,
        isShowAudioSlider: !_isCapturing,
        topBarStyle:
            QuranTopBarStyle.defaults(
              isDark: isDarkMode,
              context: context,
            ).copyWith(
              backgroundColor: MyTheme.primaryColor,
              customTopBarWidgets: [
                IconButton(
                  onPressed: toggleTheme,
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: MyTheme.primaryColor,
                  ),
                  tooltip: 'تبديل المظهر',
                ),
                IconButton(
                  onPressed: _shareCurrentPage,
                  icon: const Icon(Icons.share, color: MyTheme.primaryColor),
                  tooltip: 'مشاركة الصفحة',
                ),
              ],
            ),
        onPageChanged: (page) {
          int realPage = page + 1;
          lastPage = realPage;
          CacheHelper.saveData(key: 'pageNumber', value: realPage);
        },
        ayahMenuStyle:
            AyahMenuStyle.defaults(
              isDark: isDarkMode,
              context: context,
            ).copyWith(
              customMenuItems: [
                Builder(
                  builder: (ctx) => GestureDetector(
                    onTap: () {
                      final selectedUQs =
                          QuranCtrl.instance.selectedAyahsByUnequeNumber;
                      if (selectedUQs.isEmpty) return;
                      final ayah = QuranCtrl.instance.getAyahByUq(
                        selectedUQs.first,
                      );
                      ShareHelper.showQuranShareOptions(
                        ctx,
                        ayah: ayah,
                        isDark: isDarkMode,
                      );
                    },
                    child: const Icon(Icons.share, color: MyTheme.primaryColor),
                  ),
                ),
              ],
            ),
        backgroundColor: isDarkMode
            ? const Color(0xff181818)
            : const Color(0xfffffbec),
        textColor: isDarkMode ? Colors.white : Colors.black,
        ayahIconColor: isDarkMode ? Colors.white : MyTheme.primaryColor,
        ayahSelectedBackgroundColor: MyTheme.primaryColor.withValues(
          alpha: 0.15,
        ),

        tafsirStyle: TafsirStyle.defaults(isDark: isDarkMode, context: context)
            .copyWith(
              widthOfBottomSheet: 500,
              heightOfBottomSheet: MediaQuery.sizeOf(context).height * 0.9,
              changeTafsirDialogHeight: MediaQuery.sizeOf(context).height * 0.9,
              changeTafsirDialogWidth: 400,
            ),
      ),
    );
  }
}
