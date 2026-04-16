import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thekr_app/core/extensions/size_extension.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';

class CustomAzkarWidget extends StatefulWidget {
  const CustomAzkarWidget({
    Key? key,
    required this.details,
    this.repet,
    this.bless,
  }) : super(key: key);

  final String details;
  final String? bless;
  final String? repet;

  @override
  State<CustomAzkarWidget> createState() => _CustomAzkarWidgetState();
}

class _CustomAzkarWidgetState extends State<CustomAzkarWidget> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareAsImage() async {
    try {
      // Precache logo to ensure it's ready for capture
      await precacheImage(AssetImage(AppAssets.logo), context);

      final uint8list = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30),
                width: context.getWidth(90),
                decoration: BoxDecoration(
                  color: const Color(0xfffffbec), // Light Cream Background
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
                      width: context.getWidth(22),
                      height: context.getWidth(22),
                      child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.details,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(
                      color: context.colors.primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '(احمدوا الله دومًا)',
                      style: AppTypography.h2.copyWith(
                        color: context.colors.secondary,
                      ),
                    ),
                    Text(
                      'تطبيق ذكر - صدقة جارية',
                      style: TextStyle(
                        color: context.colors.primary.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
        text:
            'رابط تحميل التطبيق \n https://play.google.com/store/apps/details?id=com.zaid.thekr_app',
      );
    } catch (e) {
      showToast(text: 'حدث خطأ أثناء المشاركة');
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
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
              Text(
                'خيارات المشاركة',
                style: AppTypography.h3.copyWith(color: context.colors.primary),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _shareOptionItem(
                    icon: Icons.text_fields,
                    label: 'نص فقط',
                    onTap: () {
                      Navigator.pop(context);
                      _shareAsText();
                    },
                  ),
                  _shareOptionItem(
                    icon: Icons.image_outlined,
                    label: 'صورة مميزة',
                    onTap: () {
                      Navigator.pop(context);
                      _shareAsImage();
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

  void _shareAsText() async {
    try {
      String shareText = widget.details;
      if (widget.bless != null && widget.bless!.isNotEmpty) {
        shareText += '\n\n${widget.bless}';
      }

      shareText += '\n\n﴿احمدوا الله دومًا﴾';
      shareText += '\n\nحمل تطبيق ذكر:';
      shareText +=
          '\nhttps://play.google.com/store/apps/details?id=com.zaid.thekr_app';

      await Share.share(shareText, subject: 'ذكر من تطبيق ذكر');
    } catch (e) {
      Clipboard.setData(ClipboardData(text: widget.details));
      showToast(
        text: 'تم نسخ الحديث',
        textColor: context.colors.primary,
        bgColoe: Colors.white,
      );
    }
  }

  Widget _shareOptionItem({
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
              color: context.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.colors.primary, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.colors.primary, context.colors.primary],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  HapticFeedback.vibrate();
                  Clipboard.setData(ClipboardData(text: widget.details));
                  showToast(
                    text: 'تم النسخ',
                    textColor: context.colors.primary,
                    bgColoe: Colors.white,
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.copy, color: Colors.white, size: 18),
                ),
              ),
              InkWell(
                onTap: _showShareOptions,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          Text(
            widget.details,
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white,
              height: 1.8,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.bless != null && widget.bless!.isNotEmpty) ...[
            ReadMoreText(
              widget.bless!,
              trimLines: 2,
              textAlign: TextAlign.justify,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'قراءة المزيد',
              trimExpandedText: ' قراءة اقل',
              lessStyle: AppTypography.bodyMedium.copyWith(
                color: context.colors.secondary,
              ),
              moreStyle: AppTypography.bodyMedium.copyWith(
                color: context.colors.secondary,
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: const Color.fromARGB(255, 234, 234, 234),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
