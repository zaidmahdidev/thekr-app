import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quran_library/quran_library.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';
import 'dart:io';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/widgets/share_options_sheet.dart';
import 'package:thekr_app/features/quran/widgets/ayah_share_template.dart';
import 'package:thekr_app/features/quran/widgets/quran_theme_bar.dart';
import '../providers/quran_provider.dart';

@RoutePage()
class QuranScreen extends ConsumerStatefulWidget {
  final int currentPage;
  const QuranScreen({super.key, required this.currentPage});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen>
    with WidgetsBindingObserver {
  final ScreenshotController _screenshotController = ScreenshotController();
  final ScreenshotController _ayahScreenshotController = ScreenshotController();
  bool _isInitialized = false;
  late int _lastPage;
  bool _showThemes = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastPage = widget.currentPage;

    _setFullOrientations();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        QuranLibrary().jumpToPage(_lastPage);
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  void _setFullOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _resetOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _shareCurrentPage() async {
    final notifier = ref.read(quranProvider(widget.currentPage).notifier);
    final state = ref.read(quranProvider(widget.currentPage));

    try {
      notifier.setCapturing(true);
      await Future.delayed(const Duration(milliseconds: 150));
      final uint8list = await _screenshotController.capture(pixelRatio: 3.0);
      notifier.setCapturing(false);

      if (uint8list != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = File('${directory.path}/quran_page_$_lastPage.png');
        await imagePath.writeAsBytes(uint8list);
        await Share.shareXFiles([XFile(imagePath.path)]);
      }
    } catch (e) {
      notifier.setCapturing(false);
      if (mounted)
        showToast(text: 'حدث خطأ أثناء المشاركة', state: ToastStates.ERROR);
    }
  }

  void _onShareAyah() {
    if (QuranCtrl.instance.selectedAyahsByUnequeNumber.isEmpty) return;

    final selectedAyahUQ = QuranCtrl.instance.selectedAyahsByUnequeNumber.first;
    final selectedAyah = QuranCtrl.instance.getAyahByUq(selectedAyahUQ);

    if (selectedAyah.ayahUQNumber == 0) return;

    ShareOptionsSheet.show(
      context: context,
      options: [
        ShareOption.text(onTap: () => _shareAyahAsText(selectedAyah)),
        ShareOption.image(onTap: () => _shareAyahAsImage(selectedAyah)),
      ],
    );
  }

  void _shareAyahAsText(AyahModel ayah) {
    final surahName = ayah.arabicName ?? "غير معروف";
    final content = '﴿${ayah.text}﴾';
    final subtitle = '[$surahName - آية ${ayah.ayahNumber}]';

    ShareService.shareAsText(context, content, subtitle);
  }

  Future<void> _shareAyahAsImage(AyahModel ayah) async {
    final isDarkMode = ref.read(quranProvider(widget.currentPage)).isDarkMode;
    final surahName = ayah.arabicName ?? "غير معروف";

    try {
      final quranCtrl = QuranCtrl.instance;
      final pageNumber = ayah.page;

      // Ensure the font for this page is loaded before capturing
      await QuranFontsService.ensurePagesLoaded(pageNumber, radius: 0);

      final blocks = quranCtrl.getQpcLayoutBlocksForPageSync(pageNumber);

      String glyphs = "";
      for (final block in blocks) {
        if (block is QpcV4AyahLineBlock) {
          for (final seg in block.segments) {
            if (seg.surahNumber == ayah.surahNumber &&
                seg.ayahNumber == ayah.ayahNumber) {
              glyphs += seg.glyphs;
            }
          }
        }
      }

      final displayText = glyphs.isNotEmpty ? glyphs : ayah.text;
      final isCustomFont = glyphs.isNotEmpty;
      final fontFamily = glyphs.isNotEmpty
          ? quranCtrl.getFontPath(pageNumber - 1, isDark: isDarkMode)
          : 'hafs';

      final primaryColor = context.colors.primary;
      final textColor = isDarkMode ? Colors.white : const Color(0xFF2C3E50);

      // Calculate dynamic height
      final textPainter = TextPainter(
        text: TextSpan(
          text: displayText,
          style: TextStyle(fontFamily: fontFamily, fontSize: 24, height: 2.0),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 400);

      final double calculatedHeight = textPainter.height + 250;

      final uint8list = await _ayahScreenshotController.captureFromWidget(
        AyahShareTemplate(
          ayah: ayah,
          surahName: surahName,
          isDark: isDarkMode,
          primaryColor: primaryColor,
          textColor: textColor,
          displayText: displayText,
          fontFamily: fontFamily,
          isCustomFont: isCustomFont,
        ),
        targetSize: Size(450, calculatedHeight),
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 500),
      );

      final directory = await getTemporaryDirectory();
      final imagePath = File(
        '${directory.path}/ayah_${ayah.surahNumber}_${ayah.ayahNumber}.png',
      );
      await imagePath.writeAsBytes(uint8list);

      await Share.shareXFiles([XFile(imagePath.path)]);
    } catch (e) {
      if (mounted)
        showToast(text: 'حدث خطأ أثناء إنشاء الصورة', state: ToastStates.ERROR);
    }
  }

  @override
  void dispose() {
    _resetOrientations();
    WidgetsBinding.instance.removeObserver(this);
    // Direct save to cache on dispose (consistent with old version)
    CacheHelper.saveData(key: 'pageNumber', value: _lastPage);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive) &&
        mounted) {
      // Save directly to cache when app is backgrounded
      CacheHelper.saveData(key: 'pageNumber', value: _lastPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranProvider(widget.currentPage));
    final readingTheme = quranState.readingTheme;
    final isDarkMode = quranState.isDarkMode;
    final isCapturing = quranState.isCapturing;

    Color backgroundColor;
    Color textColor;
    Color ayahIconColor;

    switch (readingTheme) {
      case QuranTheme.light:
        backgroundColor = const Color(0xFFFFFDF5);
        textColor = Colors.black87;
        ayahIconColor = context.colors.primary;
        break;
      case QuranTheme.dark:
        backgroundColor = const Color(0xFF1F2125);
        textColor = Colors.white.withValues(alpha: 0.9);
        ayahIconColor = Colors.white;
        break;
      case QuranTheme.sepia:
        backgroundColor = const Color(0xFFF4ECD8);
        textColor = const Color(0xFF5B4636);
        ayahIconColor = const Color(0xFF8D6E63);
        break;
      case QuranTheme.green:
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF1B5E20);
        ayahIconColor = const Color(0xFF2E7D32);
        break;
      case QuranTheme.blueGrey:
        backgroundColor = const Color(0xFF343A41);
        textColor = const Color(0xFFECEFF1);
        ayahIconColor = const Color(0xFFB0BEC5);
        break;
    }

    return Stack(
      children: [
        Screenshot(
          controller: _screenshotController,
          child: QuranLibraryScreen(
            parentContext: context,
            isDark: isDarkMode,
            showAyahBookmarkedIcon: true,
            useDefaultAppBar: !isCapturing,
            appLanguageCode: 'ar',
            isShowTabBar: !isCapturing,
            enableWordSelection: true,
            isShowAudioSlider: !isCapturing,
            topBarStyle:
                QuranTopBarStyle.defaults(
                  isDark: isDarkMode,
                  context: context,
                ).copyWith(
                  backgroundColor: context.colors.surface,
                  customTopBarWidgets: [
                    IconButton(
                      onPressed: () =>
                          setState(() => _showThemes = !_showThemes),
                      icon: Icon(
                        Icons.palette_rounded,
                        color: _showThemes
                            ? context.colors.secondary
                            : context.colors.primary,
                      ),
                      tooltip: 'تغيير نمط القراءة',
                    ),
                    IconButton(
                      onPressed: _shareCurrentPage,
                      icon: Icon(
                        Icons.share_rounded,
                        color: context.colors.primary,
                      ),
                      tooltip: 'مشاركة الصفحة',
                    ),
                  ],
                ),
            onPageChanged: (page) {
              int realPage = page + 1;
              _lastPage = realPage;
              if (_isInitialized) {
                ref
                    .read(quranProvider(widget.currentPage).notifier)
                    .updatePage(realPage);
              }
            },
            backgroundColor: backgroundColor,
            textColor: textColor,
            ayahIconColor: ayahIconColor,
            ayahSelectedBackgroundColor: context.colors.primary.withValues(
              alpha: 0.15,
            ),
            appIconPathForPlayAudioInBackground: AppAssets.logo,
            ayahMenuStyle:
                AyahMenuStyle.defaults(
                  isDark: isDarkMode,
                  context: context,
                ).copyWith(
                  showPlayAllButton: false,
                  customMenuItems: [
                    GestureDetector(
                      onTap: _onShareAyah,
                      child: Icon(Icons.share, color: context.colors.primary),
                    ),
                  ],
                ),
          ),
        ),
        if (_showThemes && !isCapturing)
          QuranThemeBar(
            currentPage: widget.currentPage,
            onThemeSelected: () => setState(() => _showThemes = false),
          ),
      ],
    );
  }
}
