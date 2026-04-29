import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';

class ShareService {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  static void showShareSheet(
    BuildContext context, {
    required String content,
    String? subtitle,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
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
              Text(
                'خيارات المشاركة',
                style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _shareOptionItem(
                    context,
                    icon: Icons.text_fields,
                    label: 'نص فقط',
                    onTap: () {
                      Navigator.pop(context);
                      shareAsText(context, content, subtitle);
                    },
                  ),
                  _shareOptionItem(
                    context,
                    icon: Icons.image_outlined,
                    label: 'صورة مميزة',
                    onTap: () {
                      Navigator.pop(context);
                      _shareAsImage(context, content, subtitle);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _shareOptionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: context.colors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
        shareText += '\n\n$subtitle';
      }

      if (includeSignature) {
        shareText += '\n\n﴿احمدوا الله دومًا﴾';
        shareText += '\n\nحمّل تطبيق "ذكر" الآن:';
        shareText += '\n${AppConstants.playStoreUrl}';
      }

      await Share.share(shareText, subject: 'ذكر من ${AppConstants.appName}');
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
            child: Container(
              padding: const EdgeInsets.all(30),
              width: 350.w, // Fixed width for consistent capture
              decoration: BoxDecoration(
                color: const Color(0xfffffbec), // Premium Light Cream
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80.w,
                    height: 80.w,
                    child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                      height: 1.8,
                      fontSize: 16.sp,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    Text(
                      subtitle,
                      textAlign: TextAlign.justify,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.primary.withValues(alpha: 0.8),
                        height: 1.6,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Divider(color: context.colors.primary.withValues(alpha: 0.2)),
                  const SizedBox(height: 10),
                  Text(
                    '(احمدوا الله دومًا)',
                    style: AppTypography.h2.copyWith(
                      color: context.colors.secondary,
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    '${AppConstants.appName} - صدقة جارية',
                    style: TextStyle(
                      color: context.colors.primary.withValues(alpha: 0.5),
                      fontSize: 10.sp,
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

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/zikr_share.png').create();
      await imagePath.writeAsBytes(uint8list);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: AppConstants.shareMessage,
      );
    } catch (e) {
      showToast(text: 'حدث خطأ أثناء المشاركة');
    }
  }
}
