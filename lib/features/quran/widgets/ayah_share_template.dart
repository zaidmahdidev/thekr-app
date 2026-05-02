import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quran_library/quran_library.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';

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
