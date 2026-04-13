import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_library/quran_library.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thekr_app/shard/components/tools.dart';
import 'package:thekr_app/shard/constant/theme.dart';

class ShareHelper {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  // ─── مشاركة عامة (أذكار / حصن المسلم) ───────────────────────────────────

  static void showShareOptions(
    BuildContext context, {
    required String text,
    String? extraText,
    String? fileName,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BottomSheetContent(
        options: [
          _ShareOption(
            icon: Icons.text_fields,
            label: 'مشاركة كنص',
            onTap: () {
              Navigator.pop(ctx);
              _shareAsText(context, text: text, extraText: extraText);
            },
          ),
          _ShareOption(
            icon: Icons.image_outlined,
            label: 'مشاركة كصورة',
            onTap: () {
              Navigator.pop(ctx);
              _shareZikrAsImage(
                context,
                text: text,
                fileName: fileName ?? 'zikr_share',
              );
            },
          ),
        ],
      ),
    );
  }

  static void showQuranShareOptions(
    BuildContext context, {
    AyahModel? ayah,
    List<int>? pageScreenshot,
    required bool isDark,
    int? pageNumber,
  }) {
    final isPage = ayah == null;
    final pageAyahs = isPage && pageNumber != null
        ? QuranCtrl.instance.getAyahsByPage(pageNumber)
        : <AyahModel>[];
    final plainText = isPage
        ? pageAyahs.map((a) => a.ayaTextEmlaey).join(' ')
        : ayah.ayaTextEmlaey;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BottomSheetContent(
        options: [
          _ShareOption(
            icon: Icons.text_fields,
            label: 'مشاركة كنص',
            onTap: () {
              Navigator.pop(ctx);
              _shareAsText(context, text: plainText);
            },
          ),
          _ShareOption(
            icon: Icons.image_outlined,
            label: 'مشاركة كصورة',
            onTap: () {
              Navigator.pop(ctx);
              if (isPage && pageScreenshot != null) {
                _addFooterAndShare(
                  context,
                  pageBytes: pageScreenshot,
                  isDark: isDark,
                  pageNumber: pageNumber,
                );
              } else if (ayah != null) {
                _shareAyahAsImage(context, ayah: ayah, isDark: isDark);
              }
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _shareAsText(
    BuildContext context, {
    required String text,
    String? extraText,
  }) async {
    try {
      String shareText = text;
      if (extraText != null && extraText.isNotEmpty) {
        shareText += '\n\n$extraText';
      }
      await Share.share(shareText);
    } catch (e) {
      Clipboard.setData(ClipboardData(text: text));
      showToast(
        text: 'تم نسخ الذكر',
        textColor: MyTheme.primaryColor,
        bgColoe: Colors.white,
      );
    }
  }

  static Future<void> _shareZikrAsImage(
    BuildContext context, {
    required String text,
    String fileName = 'zikr_share',
  }) async {
    try {
      await precacheImage(const AssetImage('assets/images/thekr.png'), context);
      final uint8list = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: const EdgeInsets.all(30),
              width: 400,
              decoration: BoxDecoration(
                color: const Color(0xfffffbec),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: MyTheme.primaryColor.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 37,
                    height: 37,
                    child: Image.asset(
                      'assets/images/thekr.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'بواسطة تطبيق ذكر',
                    style: TextStyle(
                      color: MyTheme.primaryColor.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        context: context,
        delay: const Duration(milliseconds: 500),
        pixelRatio: 2.0,
      );
      await _saveAndShare(uint8list, fileName);
    } catch (e) {
      showToast(text: 'حدث خطأ أثناء المشاركة');
    }
  }

  static Future<void> _addFooterAndShare(
    BuildContext context, {
    required List<int> pageBytes,
    required bool isDark,
    int? pageNumber,
  }) async {
    try {
      await _saveAndShare(pageBytes, 'quran_page_$pageNumber');
    } catch (e) {
      showToast(text: 'حدث خطأ أثناء المشاركة');
    }
  }

  static Future<void> _shareAyahAsImage(
    BuildContext context, {
    required AyahModel ayah,
    required bool isDark,
  }) async {
    try {
      await precacheImage(const AssetImage('assets/images/thekr.png'), context);
      final bgColor = isDark
          ? const Color(0xff121212)
          : const Color(0xfffffbec);
      final textColor = isDark ? Colors.white : Colors.black;
      final primaryColor = isDark ? Colors.white : MyTheme.primaryColor;
      final pageFont = 'page${ayah.page}';

      final uint8list = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              width: 420,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'packages/quran_library/assets/svg/surahSvgBanner.svg',
                        width: 280,
                        height: 50,
                        colorFilter: ColorFilter.mode(
                          primaryColor,
                          BlendMode.modulate,
                        ),
                      ),
                      Text(
                        (ayah.surahNumber ?? 1).toString(),
                        style: TextStyle(
                          color: textColor,
                          fontFamily: 'surahName',
                          fontSize: 28,
                          fontFamilyFallback: const ['surahName'],
                          inherit: false,
                          package: 'quran_library',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ayah.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontFamily: pageFont,
                      fontSize: 18,
                      // height: 2.2,
                      fontFamilyFallback: const ['me_quran'],
                      package: 'quran_library',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/images/thekr.png',
                    width: 37,
                    height: 37,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'بواسطة تطبيق ذكر',
                    style: TextStyle(
                      color: primaryColor.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        context: context,
        delay: const Duration(milliseconds: 500),
        pixelRatio: 2.5,
      );
      await _saveAndShare(
        uint8list,
        'quran_ayah_${ayah.surahNumber}_${ayah.ayahNumber}',
      );
    } catch (e) {
      showToast(text: 'حدث خطأ أثناء المشاركة');
    }
  }

  static Future<void> _saveAndShare(List<int> bytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final imagePath = await File('${directory.path}/$fileName.png').create();
    await imagePath.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(imagePath.path)]);
  }
}

class _ShareOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _BottomSheetContent extends StatelessWidget {
  final List<_ShareOption> options;
  const _BottomSheetContent({required this.options});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'خيارات المشاركة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MyTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: options
                  .map(
                    (o) => InkWell(
                      onTap: o.onTap,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: MyTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              o.icon,
                              color: MyTheme.primaryColor,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            o.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF424242),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
