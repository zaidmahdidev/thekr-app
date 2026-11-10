import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/design_tokens.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';

/// Store-link QR code drawn at runtime, with the current app logo in the
/// middle — no static image to regenerate when the icon changes.
class AppQrCode extends StatelessWidget {
  const AppQrCode({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;

    return QrImageView(
      data: AppConstants.playStoreUrl,
      size: size,
      padding: EdgeInsets.all(context.insets.sm),
      // Scanners need dark modules on a light ground, so keep it light in
      // dark mode too.
      backgroundColor: AppColors.light.surface,
      // High correction keeps the code readable under the embedded logo.
      errorCorrectionLevel: QrErrorCorrectLevel.H,
      eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: color),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.circle,
        color: color,
      ),
      embeddedImage: const AssetImage(AppAssets.logo),
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: Size.square(size * 0.22),
      ),
    );
  }
}
