import 'package:flutter/material.dart';
import 'package:thekr_app/core/theme/tokens/app_fonts.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';

/// App watermark shown at the bottom of every shared image (share cards and
/// Quran ayah images), so all of them carry the exact same signature.
class ShareCardSignature extends StatelessWidget {
  const ShareCardSignature({
    super.key,
    required this.color,
    this.isCustomText = false,
  });

  final Color color;

  /// True when the text was written by the user in the custom share card.
  final bool isCustomText;

  @override
  Widget build(BuildContext context) {
    final label = isCustomText
        ? 'نص مخصص بواسطة تطبيق ${AppConstants.appName}'
        : 'بواسطة تطبيق ${AppConstants.appName}';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(AppAssets.logo, width: 22, height: 22),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.family,
              color: color.withValues(alpha: 0.85),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
