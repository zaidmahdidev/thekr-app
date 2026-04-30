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
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';
import 'dart:io';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/widgets/share_options_sheet.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Set orientations for Quran reading experience
    _setFullOrientations();

    // Jump to the saved page after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      QuranLibrary().jumpToPage(widget.currentPage);
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
      final uint8list = await _screenshotController.capture(pixelRatio: 2.0);
      notifier.setCapturing(false);

      if (uint8list != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = File(
          '${directory.path}/quran_page_${state.currentPage}.png',
        );
        await imagePath.writeAsBytes(uint8list);
        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text:
              'من تطبيق ${AppConstants.appName}\n${AppConstants.playStoreUrl}',
        );
      }
    } catch (e) {
      notifier.setCapturing(false);
      if (mounted) showToast(text: 'حدث خطأ أثناء المشاركة');
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
    final text = '﴿${ayah.text}﴾\n[$surahName - آية ${ayah.ayahNumber}]';
    Share.share(text);
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
        delay: const Duration(milliseconds: 500),
      );

      final directory = await getTemporaryDirectory();
      final imagePath = File(
        '${directory.path}/ayah_${ayah.surahNumber}_${ayah.ayahNumber}.png',
      );
      await imagePath.writeAsBytes(uint8list);

      await Share.shareXFiles([XFile(imagePath.path)]);
    } catch (e) {
      if (mounted) showToast(text: 'حدث خطأ أثناء إنشاء الصورة');
    }
  }

  @override
  void dispose() {
    _resetOrientations();
    WidgetsBinding.instance.removeObserver(this);
    ref.read(quranProvider(widget.currentPage).notifier).saveCurrentProgress();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref
          .read(quranProvider(widget.currentPage).notifier)
          .saveCurrentProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final quranState = ref.watch(quranProvider(widget.currentPage));
    final isDarkMode = quranState.isDarkMode;

    return Screenshot(
      controller: _screenshotController,
      child: QuranLibraryScreen(
        parentContext: context,
        isDark: isDarkMode,
        showAyahBookmarkedIcon: true,
        useDefaultAppBar: !quranState.isCapturing,
        appLanguageCode: 'ar',
        isShowTabBar: !quranState.isCapturing,
        enableWordSelection: true,
        isShowAudioSlider: !quranState.isCapturing,
        topBarStyle:
            QuranTopBarStyle.defaults(
              isDark: isDarkMode,
              context: context,
            ).copyWith(
              backgroundColor: context.colors.surface,
              customTopBarWidgets: [
                IconButton(
                  onPressed: () => ref
                      .read(quranProvider(widget.currentPage).notifier)
                      .toggleDarkMode(),
                  icon: Icon(
                    isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: context.colors.primary,
                  ),
                  tooltip: 'تبديل مظهر المصحف',
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
        onPageChanged: (page) => ref
            .read(quranProvider(widget.currentPage).notifier)
            .updatePage(page + 1),
        backgroundColor: isDarkMode
            ? const Color(0xFF121212)
            : const Color(0xFFFFFDF5),
        textColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.9)
            : Colors.black87,
        ayahIconColor: context.colors.primary,
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
    );
  }
}

class AyahShareTemplate extends StatelessWidget {
  final AyahModel ayah;
  final String surahName;
  final bool isDark;
  final Color primaryColor;
  final Color textColor;
  final String displayText;
  final String fontFamily;
  final bool isCustomFont;

  const AyahShareTemplate({
    super.key,
    required this.ayah,
    required this.surahName,
    required this.isDark,
    required this.primaryColor,
    required this.textColor,
    required this.displayText,
    required this.fontFamily,
    required this.isCustomFont,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFDF5);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 450,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Surah Name Banner
              Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    AssetsPath.assets.surahSvgBanner,
                    width: 320,
                    colorFilter: ColorFilter.mode(
                      primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text(
                      'surah${ayah.surahNumber.toString().padLeft(3, '0')}surah-icon',
                      style: TextStyle(
                        fontFamily: 'surah-name-v4',
                        package: 'quran_library',
                        fontSize: 32,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: displayText,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        package: isCustomFont ? null : 'quran_library',
                        fontSize: 24,
                        height: 2.0,
                        color: textColor,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' \u202F${_toArabicDigits(ayah.ayahNumber)}\u202F\u202F',
                      style: TextStyle(
                        fontFamily: 'ayahNumber',
                        package: 'quran_library',
                        fontSize: 28,
                        height: 1.5,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 15),
              // Footer (App Info)
              Image.asset(AppAssets.logo, width: 35, height: 35),
              const SizedBox(height: 4),
              Text(
                'بواسطة تطبيق ${AppConstants.appName}',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _toArabicDigits(int number) {
    final english = number.toString();
    final Map<String, String> arabic = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    return english.split('').map((char) => arabic[char] ?? char).join();
  }
}
