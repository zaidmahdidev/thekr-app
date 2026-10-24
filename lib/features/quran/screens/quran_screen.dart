import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_library/quran_library.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/theme/app_theme.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'dart:io';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/widgets/share_options_sheet.dart';
import 'package:thekr_app/features/quran/widgets/ayah_share_template.dart';
import 'package:thekr_app/features/quran/models/quran_reader_palette.dart';
import 'package:thekr_app/features/quran/widgets/quran_top_bar.dart';
import 'package:thekr_app/features/quran/widgets/quran_theme_bar.dart';
import '../providers/quran_provider.dart';
import 'package:thekr_app/core/utils/constants/app_icons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

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

      final double calculatedHeight = textPainter.height + 240;

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

    final palette = QuranReaderPalette.of(
      readingTheme,
      primary: context.colors.primary,
      accent: context.colors.secondary,
    );
    final appThemeType = ref.watch(settingsProvider.select((s) => s.appTheme));
    final readerTheme = isDarkMode
        ? AppTheme.dark(appThemeType)
        : AppTheme.light(appThemeType);

    return Stack(
      children: [
        Screenshot(
          controller: _screenshotController,
          // The reader has its own reading theme, separate from the app's. The
          // package draws some text (for example in the recitation results
          // sheet) in the colors of the surrounding Theme, so give it a Theme
          // of the same brightness as the reader. Otherwise a dark reader in a
          // light app shows black text on a dark sheet, and the reverse.
          child: Theme(
            data: readerTheme,
            child: Builder(
              builder: (readerContext) => QuranLibraryScreen(
                parentContext: readerContext,
                isDark: isDarkMode,
                showAyahBookmarkedIcon: true,
                useDefaultAppBar: false,
                appLanguageCode: 'ar',
                isShowTabBar: false,
                enableWordSelection: true,
                isShowAudioSlider: !isCapturing,
                onPageChanged: (page) {
                  int realPage = page + 1;
                  _lastPage = realPage;
                  if (_isInitialized) {
                    ref
                        .read(quranProvider(widget.currentPage).notifier)
                        .updatePage(realPage);
                  }
                },
                backgroundColor: palette.background,
                textColor: palette.text,
                ayahIconColor: palette.icon,
                ayahSelectedBackgroundColor: context.colors.primary.withValues(
                  alpha: 0.15,
                ),
                appIconPathForPlayAudioInBackground: AppAssets.logo,
                ayahMenuStyle:
                    AyahMenuStyle.defaults(
                      isDark: isDarkMode,
                      context: readerContext,
                    ).copyWith(
                      showPlayAllButton: false,
                      customMenuItems: [
                        GestureDetector(
                          onTap: _onShareAyah,
                          child: AppIcon(
                            AppIcons.share,
                            color: context.colors.primary,
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ),
        if (!isCapturing)
          Positioned(
            top: 0,
            left: context.insets.sm,
            right: context.insets.sm,
            child: QuranTopBar(
              providerPage: widget.currentPage,
              palette: palette,
              themesOpen: _showThemes,
              onBack: () => context.maybePop(),
              onToggleThemes: () => setState(() => _showThemes = !_showThemes),
              onSharePage: _shareCurrentPage,
            ),
          ),
        if (_showThemes && !isCapturing) ...[
          GestureDetector(
            onTap: () => setState(() => _showThemes = false),
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
          QuranThemeBar(
            currentPage: widget.currentPage,
            onThemeSelected: () => setState(() => _showThemes = false),
          ),
        ],
      ],
    );
  }
}
