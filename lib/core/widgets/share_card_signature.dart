import 'package:flutter/material.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';

/// App watermark shown at the bottom of every shared image (share cards and
/// Quran ayah images), so all of them carry the exact same signature.
class ShareCardSignature extends StatelessWidget {
  const ShareCardSignature({
    super.key,
    required this.color,
    required this.accent,
    this.tagline = 'الأذكار والقرآن',
  });

  final Color color;
  final Color accent;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(AppAssets.logo, width: 22, height: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تطبيق ${AppConstants.appName}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: color.withValues(alpha: 0.85),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              Text(
                tagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: accent,
                  fontSize: 5.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
