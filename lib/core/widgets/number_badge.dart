import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

/// A number inside an eight-pointed Islamic star drawn as an SVG.
///
/// The SVG is generated from the theme colors, so the badge follows the active
/// theme and dark mode without any asset to maintain.
class NumberBadge extends StatelessWidget {
  const NumberBadge({super.key, required this.number, required this.size});

  final String number;
  final double size;

  static String _hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  /// Two squares, one turned by 45 degrees, make the eight-pointed star.
  static String _svg({
    required Color gold,
    required Color primary,
    required Color surface,
  }) {
    final g = _hex(gold);
    final p = _hex(primary);
    final s = _hex(surface);

    // Dots on the eight corners of the star.
    final dots = StringBuffer();
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + math.pi / 8;
      final x = 50 + 44 * math.cos(angle);
      final y = 50 + 44 * math.sin(angle);
      dots.write(
        '<circle cx="${x.toStringAsFixed(2)}" cy="${y.toStringAsFixed(2)}" r="2.4" fill="$g"/>',
      );
    }

    return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <g fill="$g" fill-opacity="0.12" stroke="$g" stroke-width="2.6" stroke-linejoin="round">
    <rect x="18" y="18" width="64" height="64" rx="5"/>
    <rect x="18" y="18" width="64" height="64" rx="5" transform="rotate(45 50 50)"/>
  </g>
  ${dots.toString()}
  <circle cx="50" cy="50" r="28" fill="$s" stroke="$g" stroke-width="2"/>
  <circle cx="50" cy="50" r="24" fill="none" stroke="$p" stroke-opacity="0.22" stroke-width="1.2"/>
</svg>''';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.string(
            _svg(
              gold: colors.secondary,
              primary: colors.primary,
              surface: colors.surface,
            ),
            width: size,
            height: size,
          ),
          // The font adds space above and below the digits; evening it out puts
          // the number exactly in the middle of the circle.
          Center(
            child: Text(
              number,
              textAlign: TextAlign.center,
              textWidthBasis: TextWidthBasis.longestLine,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
                leadingDistribution: TextLeadingDistribution.even,
              ),
              strutStyle: const StrutStyle(forceStrutHeight: true, height: 1),
              style: context.textStyles.bodyMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
