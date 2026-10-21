import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:thekr_app/core/theme/tokens/app_fonts.dart';
import 'package:thekr_app/core/theme/tokens/share_card_palette.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/share_card_signature.dart';
import 'package:thekr_app/features/settings/models/share_card_style.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

/// The shareable card.
///
/// Drawn on a fixed 360-wide logical canvas (no screen scaling) so the preview,
/// the template thumbnails and the exported image are pixel-identical on every
/// device. Wrap it in a [FittedBox] to display it at any size.
class ShareCardView extends StatelessWidget {
  const ShareCardView({
    super.key,
    required this.template,
    required this.content,
    this.subtitle,
    this.style = const ShareCardStyle(),
    this.isCustomText = false,
  });

  static const double width = 360;
  static const double _radius = 24;
  static const double _textPadding = 34;

  final ShareTemplate template;
  final String content;
  final String? subtitle;
  final ShareCardStyle style;
  final bool isCustomText;

  static double heightFor(ShareCardRatio ratio) => width / ratio.aspect;

  double _baseFontSize(int length) {
    if (length < 60) return 30;
    if (length < 120) return 26;
    if (length < 220) return 21;
    if (length < 400) return 17;
    return 14;
  }

  @override
  Widget build(BuildContext context) {
    final palette = ShareCardPalette.of(template);
    final fontSize = _baseFontSize(content.length) * style.fontScale;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: width,
        height: heightFor(style.ratio),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: palette.begin,
                end: palette.end,
                colors: palette.gradient,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Corner ornaments
                Positioned(
                  left: -95,
                  bottom: -95,
                  child: Opacity(
                    opacity: palette.ornamentOpacity,
                    child: Image.asset(AppAssets.bg, width: 250),
                  ),
                ),
                Positioned(
                  right: -95,
                  top: -95,
                  child: Opacity(
                    opacity: palette.ornamentOpacity * 0.7,
                    child: Transform.rotate(
                      angle: math.pi,
                      child: Image.asset(AppAssets.bg, width: 250),
                    ),
                  ),
                ),

                // Frame
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: palette.accent.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                    ),
                    child: palette.doubleFrame
                        ? Padding(
                            padding: const EdgeInsets.all(5),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                  color: palette.accent.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _textPadding,
                    vertical: 36,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: width - _textPadding * 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    content,
                                    textAlign: TextAlign.center,
                                    style: QuranText.style(
                                      TextStyle(
                                        fontFamily: AppFonts.family,
                                        color: palette.text,
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w700,
                                        height: 1.75,
                                      ),
                                      content,
                                    ),
                                  ),
                                  if (hasSubtitle) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      '— ${subtitle!.trim()} —',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: AppFonts.family,
                                        color: palette.accent,
                                        fontSize: math.max(12, fontSize * 0.55),
                                        fontWeight: FontWeight.w500,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (style.showSignature) ...[
                        const SizedBox(height: 10),
                        ShareCardSignature(
                          color: palette.text,
                          isCustomText: isCustomText,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
