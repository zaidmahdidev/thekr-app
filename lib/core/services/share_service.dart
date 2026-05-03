import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/widgets/share_options_sheet.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

class ShareService {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  static void showShareSheet(
    BuildContext context,
    WidgetRef ref, {
    required String content,
    String? subtitle,
    bool showSubtitleInImage = false,
  }) {
    final settings = ref.watch(settingsProvider);
    ShareOptionsSheet.show(
      context: context,
      options: [
        ShareOption.text(onTap: () => shareAsText(context, content, subtitle)),
        if (content.length <= 800)
          ShareOption.image(
            onTap: () {
              _shareAsImage(
                context,
                settings.shareTemplate,
                content,
                showSubtitleInImage ? subtitle : null,
              );
            },
          ),
      ],
    );
  }

  static void shareAsText(
    BuildContext context,
    String content,
    String? subtitle, {
    bool includeSignature = true,
  }) async {
    try {
      String shareText = content;
      if (subtitle != null && subtitle.isNotEmpty) {
        if (shareText.isEmpty) {
          shareText = subtitle;
        } else {
          shareText += '\n\n$subtitle';
        }
      }

      if (includeSignature && !shareText.contains(AppConstants.playStoreUrl)) {
        shareText += '\n\nتمت المشاركة بواسطة تطبيق "${AppConstants.appName}":';
        shareText += '\n${AppConstants.playStoreUrl}';
      }

      await Share.share(
        shareText,
        subject: 'مشاركة من ${AppConstants.appName}',
      );
    } catch (e) {
      Clipboard.setData(ClipboardData(text: content));
      showToast(
        text: 'تم نسخ النص',
        textColor: context.colors.primary,
        backgroundColor: Colors.white,
      );
    }
  }

  static Future<void> _shareAsImage(
    BuildContext context,
    ShareTemplate template,
    String content,
    String? subtitle,
  ) async {
    try {
      // Precache logo
      final ImageProvider logo = AssetImage(AppAssets.logo);
      await precacheImage(logo, context);

      final uint8list = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: buildShareCard(context, template, content, subtitle),
          ),
        ),
        context: context,
        delay: const Duration(milliseconds: 500),
        pixelRatio: 3.0, // Higher resolution for premium feel
      );

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/zikr_share.png').create();
      await imagePath.writeAsBytes(uint8list);

      await Share.shareXFiles([XFile(imagePath.path)]);
    } catch (e) {
      showToast(text: 'حدث خطأ أثناء المشاركة');
    }
  }

  static Widget buildShareCard(
    BuildContext context,
    ShareTemplate template,
    String content,
    String? subtitle,
  ) {
    Color bgColor;
    Color textColor;
    Color accentColor;
    Gradient? gradient;
    BoxBorder? border;

    switch (template) {
      case ShareTemplate.classic:
        bgColor = const Color(0xfffffbec);
        textColor = const Color(0xFF2D5A5A);
        accentColor = const Color(0xFFC4A484);
        border = Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 2,
        );
        break;
      case ShareTemplate.luxury:
        bgColor = const Color(0xFF1A1A1A);
        textColor = const Color(0xFFD4AF37); // Gold
        accentColor = const Color(0xFFD4AF37);
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C2C2C), Color(0xFF000000)],
        );
        border = Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        );
        break;
      case ShareTemplate.spiritual:
        bgColor = const Color(0xFFF0F9FF);
        textColor = const Color(0xFF0C4A6E);
        accentColor = const Color(0xFF0EA5E9);
        gradient = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
        );
        border = Border.all(
          color: accentColor.withValues(alpha: 0.1),
          width: 1,
        );
        break;
    }

    // Determine font size based on text length
    double fontSize;
    if (content.length < 150) {
      fontSize = 24.sp;
    } else if (content.length < 400) {
      fontSize = 18.sp;
    } else {
      fontSize = 14.sp;
    }

    return Container(
      width: 400.w,
      constraints: BoxConstraints(minHeight: 200.h, maxHeight: 800.h),
      clipBehavior: Clip.antiAlias, // To clip the corner ornament
      padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 40.h),
      decoration: BoxDecoration(
        color: bgColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(24.r),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Ornament
          Positioned(
            bottom: -80.h,
            left: -80.w,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                AppAssets.bg,
                width: 220.w,
                height: 220.w,
                // color: textColor,
              ),
            ),
          ),
          Positioned(
            bottom: -30.h,
            right: 0,
            left: 0,

            child: Column(
              children: [
                Image.asset(AppAssets.logo, width: 35.w, height: 35.w),
                Text(
                  'بواسطة تطبيق ' + AppConstants.appName,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 7.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                content,
                textAlign: TextAlign.center,
                style: context.textStyles.bodySmall!.copyWith(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  height: 1.6,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: (fontSize * 0.7).sp,
                    height: 1.4,
                  ),
                ),
              ],
              SizedBox(height: 30.h),
            ],
          ),
        ],
      ),
    );
  }
}
