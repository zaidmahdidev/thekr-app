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
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(AppAssets.logo, width: 22, height: 22),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تطبيق ${AppConstants.appName}',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: color.withValues(alpha: 0.85),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              Text(
                tagline,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: accent,
                  fontSize: 7.5,
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
