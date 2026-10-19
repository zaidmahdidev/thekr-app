import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Islamic geometric lattice for the home header, drawn as an SVG.
///
/// Rows of eight-pointed stars (two squares, one turned by 45 degrees) with a
/// small diamond between them; it fades out toward the bottom so the content
/// under it stays clean.
class HeroPattern extends StatelessWidget {
  const HeroPattern({super.key, this.opacity = 0.32});

  final double opacity;

  static const double _cell = 44;
  static const double _width = 440;
  static const double _height = 264;

  static final String _svg = _build();

  static String _star(double cx, double cy, double half) {
    final x = (cx - half).toStringAsFixed(1);
    final y = (cy - half).toStringAsFixed(1);
    final size = (half * 2).toStringAsFixed(1);
    final center = '${cx.toStringAsFixed(1)} ${cy.toStringAsFixed(1)}';
    return '<rect x="$x" y="$y" width="$size" height="$size" rx="2"/>'
        '<rect x="$x" y="$y" width="$size" height="$size" rx="2" transform="rotate(45 $center)"/>'
        '<circle cx="${cx.toStringAsFixed(1)}" cy="${cy.toStringAsFixed(1)}" r="3.2"/>';
  }

  static String _diamond(double cx, double cy, double r) {
    final points = [
      '${(cx).toStringAsFixed(1)},${(cy - r).toStringAsFixed(1)}',
      '${(cx + r).toStringAsFixed(1)},${(cy).toStringAsFixed(1)}',
      '${(cx).toStringAsFixed(1)},${(cy + r).toStringAsFixed(1)}',
      '${(cx - r).toStringAsFixed(1)},${(cy).toStringAsFixed(1)}',
    ].join(' ');
    return '<polygon points="$points"/>';
  }

  static String _build() {
    final shapes = StringBuffer();
    const rows = 7;
    final cols = (_width / _cell).ceil() + 1;
    for (var j = 0; j < rows; j++) {
      final shift = j.isOdd ? _cell / 2 : 0.0;
      final cy = _cell / 2 + j * (_cell * 0.8);
      for (var i = 0; i < cols; i++) {
        final cx = i * _cell + shift;
        shapes.write(_star(cx, cy, 14));
        shapes.write(_diamond(cx + _cell / 2, cy, 5));
      }
    }
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $_width $_height">'
        '<g fill="none" stroke="#FFFFFF" stroke-width="1.1" stroke-linejoin="round">'
        '$shapes</g></svg>';
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.transparent],
        stops: [0.15, 0.95],
      ).createShader(rect),
      child: Opacity(
        opacity: opacity,
        child: SvgPicture.string(
          _svg,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}
