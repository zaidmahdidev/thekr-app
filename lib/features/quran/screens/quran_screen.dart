import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

      // Brief delay to ensure UI reflects the capturing state
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
                  onPressed: () {
                    ref
                        .read(quranProvider(widget.currentPage).notifier)
                        .toggleDarkMode();
                  },
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
        onPageChanged: (page) {
          ref
              .read(quranProvider(widget.currentPage).notifier)
              .updatePage(page + 1);
        },
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
      ),
    );
  }
}
