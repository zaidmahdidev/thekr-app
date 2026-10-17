import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/widgets/share_card_view.dart';
import 'package:thekr_app/core/widgets/share_options_sheet.dart';
import 'package:thekr_app/features/settings/models/share_card_style.dart';
import 'package:thekr_app/features/settings/providers/share_card_style_provider.dart';
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
    bool isCustomText = false,
  }) {
    final settings = ref.watch(settingsProvider);
    final style = ref.read(shareCardStyleProvider);
    ShareOptionsSheet.show(
      context: context,
      options: [
        ShareOption.text(
          onTap: () => shareAsText(
            context,
            content,
            subtitle,
            isCustomText: isCustomText,
          ),
        ),
        if (content.length <= 800)
          ShareOption.image(
            onTap: () {
              shareAsImage(
                context,
                settings.shareTemplate,
                content,
                showSubtitleInImage ? subtitle : null,
                isCustomText: isCustomText,
                style: style,
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
    bool isCustomText = false,
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
        final signature = isCustomText
            ? 'ذكر مخصص عبر تطبيق ${AppConstants.appName}'
            : 'تمت المشاركة بواسطة تطبيق "${AppConstants.appName}"';
        shareText += '\n\n$signature:';
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

  static Future<void> shareAsImage(
    BuildContext context,
    ShareTemplate template,
    String content,
    String? subtitle, {
    bool isCustomText = false,
    ShareCardStyle style = const ShareCardStyle(),
  }) async {
    try {
      // Precache card images so they are present in the offscreen capture
      await precacheImage(AssetImage(AppAssets.logo), context);
      await precacheImage(AssetImage(AppAssets.bg), context);

      final uint8list = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: buildShareCard(
              context,
              template,
              content,
              subtitle,
              isCustomText: isCustomText,
              style: style,
            ),
          ),
        ),
        context: context,
        targetSize: Size(
          ShareCardView.width,
          ShareCardView.heightFor(style.ratio),
        ),
        delay: const Duration(milliseconds: 500),
        pixelRatio: 3.0, // 1080px wide, crisp on every platform
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
    String? subtitle, {
    bool isCustomText = false,
    ShareCardStyle style = const ShareCardStyle(),
  }) {
    return ShareCardView(
      template: template,
      content: content,
      subtitle: subtitle,
      style: style,
      isCustomText: isCustomText,
    );
  }
}
