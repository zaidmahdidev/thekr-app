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
  static const double _textPadding = 24;
  static const double _verticalPadding = 30;
  static const double _signatureHeight = 48;
  static const double _subtitleGap = 14;
  static const double _minFontSize = 11;
  static const double _maxFontSize = 44;
  static const double _defaultMaxFontSize = 32;

  final ShareTemplate template;
  final String content;
  final String? subtitle;
  final ShareCardStyle style;
  final bool isCustomText;

  static double heightFor(ShareCardRatio ratio) => width / ratio.aspect;

  double _lineHeight() => content.length < 120 ? 1.75 : 1.6;

  TextStyle _contentStyle(double size, Color color) => QuranText.style(
    TextStyle(
      fontFamily: AppFonts.family,
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: _lineHeight(),
    ),
    content,
  );

  TextStyle _subtitleStyle(double size, Color color) => TextStyle(
    fontFamily: AppFonts.family,
    color: color,
    fontSize: math.max(12, size * 0.55),
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  /// Height the text block takes at [size] inside [maxWidth].
  double _measure(double size, double maxWidth, String? subtitleText) {
    double layout(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      )..layout(maxWidth: maxWidth);
      final height = painter.height;
      painter.dispose();
      return height;
    }

    var total = layout(content, _contentStyle(size, Colors.black));
    if (subtitleText != null) {
      total +=
          _subtitleGap +
          layout('— $subtitleText —', _subtitleStyle(size, Colors.black));
    }
    return total;
  }

  /// Largest font size whose text block fits the card, found by measuring the
  /// real layout (so it works for any length, ratio and font).
  double _fitFontSize(double maxWidth, double maxHeight, String? subtitleText) {
    var low = _minFontSize;
    var high = _maxFontSize;
    if (_measure(high, maxWidth, subtitleText) <= maxHeight) return high;
    for (var i = 0; i < 9; i++) {
      final mid = (low + high) / 2;
      if (_measure(mid, maxWidth, subtitleText) <= maxHeight) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return low;
  }

  @override
  Widget build(BuildContext context) {
    final palette = ShareCardPalette.of(template);
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final subtitleText = hasSubtitle ? subtitle!.trim() : null;
    final textWidth = width - _textPadding * 2;
    final textHeight =
        heightFor(style.ratio) -
        _verticalPadding * 2 -
        (style.showSignature ? _signatureHeight : 0);
    // [fit] is the biggest size that fills the card; the slider scales the
    // default size but can never push the text past the card.
    final fit = _fitFontSize(textWidth, textHeight, subtitleText);
    final fontSize = math.min(
      fit,
      math.min(fit, _defaultMaxFontSize) * style.fontScale,
    );

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
                    vertical: _verticalPadding,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: textWidth,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    content,
                                    textAlign: TextAlign.center,
                                    textScaler: TextScaler.noScaling,
                                    style: _contentStyle(
                                      fontSize,
                                      palette.text,
                                    ),
                                  ),
                                  if (subtitleText != null) ...[
                                    const SizedBox(height: _subtitleGap),
                                    Text(
                                      '— $subtitleText —',
                                      textAlign: TextAlign.center,
                                      textScaler: TextScaler.noScaling,
                                      style: _subtitleStyle(
                                        fontSize,
                                        palette.accent,
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
