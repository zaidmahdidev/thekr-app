import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/misbaha_models.dart';

/// Draws one solid bead (no holes: beads sit against each other so the string
/// stays hidden) shaded like a real sphere: contact shadow, light from the
/// upper left, edge darkening, bounce light, highlights and a material detail
/// (wood grain, gem glow or metal bands). Shared by the tasbih and the bead
/// picker so they always look the same.
class BeadRenderer {
  BeadRenderer._();

  /// Color of the string.
  static const Color threadColor = Color(0xFFD9A441);

  static void paint(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required BeadType type,
    // Direction of the string at the bead (radians); the wood grain follows it.
    double angle = math.pi / 2,
    double opacity = 1,
  }) {
    final fade = opacity < 0.99;
    if (fade) {
      canvas.saveLayer(
        Rect.fromCircle(center: center, radius: radius * 1.6),
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }

    final colors = type.colors;
    final light = colors[0];
    final body = colors[1];
    final dark = colors[2];
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Contact shadow.
    canvas.drawCircle(
      center.translate(radius * 0.18, radius * 0.26),
      radius * 0.95,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );

    // 2. Sphere body lit from the upper left.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.38, -0.42),
          radius: 1.08,
          colors: [_lighten(light, 0.1), light, body, dark],
          stops: const [0.0, 0.26, 0.66, 1.0],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    // 3. Material detail.
    switch (type.material) {
      case BeadMaterial.wood:
        _woodGrain(canvas, center, radius, angle, dark);
      case BeadMaterial.gem:
        _gemGlow(canvas, center, radius, light);
      case BeadMaterial.metal:
        _metalBands(canvas, center, radius);
    }

    // 4. Edge darkening (ambient occlusion).
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.42),
          ],
          stops: const [0.0, 0.62, 1.0],
        ).createShader(rect),
    );

    // 5. Light bounced from the table onto the lower right.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.55, 0.62),
          radius: 0.55,
          colors: [
            _lighten(light, 0.05).withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ).createShader(rect),
    );

    // 6. Soft broad highlight.
    final highlight = center.translate(-radius * 0.36, -radius * 0.4);
    canvas.drawCircle(
      highlight,
      radius * 0.55,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(
                  alpha: type.material == BeadMaterial.metal ? 0.55 : 0.4,
                ),
                Colors.white.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: highlight, radius: radius * 0.55),
            ),
    );

    canvas.restore();

    // 7. Sharp specular spot.
    canvas.save();
    canvas.translate(center.dx - radius * 0.42, center.dy - radius * 0.5);
    canvas.rotate(-0.6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 0.34,
        height: radius * 0.18,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.restore();

    // 8. Thin rim light.
    canvas.drawArc(
      rect.deflate(0.8),
      math.pi * 0.9,
      math.pi * 0.55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = Colors.white.withValues(alpha: 0.28),
    );

    if (fade) canvas.restore();
  }

  static void _woodGrain(
    Canvas canvas,
    Offset c,
    double r,
    double angle,
    Color dark,
  ) {
    // Grain runs along the string.
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = dark.withValues(alpha: 0.2);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle + 0.35);
    for (int i = -4; i <= 4; i++) {
      final y = i * r * 0.22;
      final p = Path()
        ..moveTo(-r, y)
        ..quadraticBezierTo(-r * 0.3, y + r * 0.08 * (i.isEven ? 1 : -1), 0, y)
        ..quadraticBezierTo(r * 0.4, y - r * 0.1 * (i.isEven ? 1 : -1), r, y);
      canvas.drawPath(p, grain);
    }
    canvas.restore();
  }

  static void _gemGlow(Canvas canvas, Offset c, double r, Color light) {
    final center = c.translate(r * 0.1, r * 0.12);
    canvas.drawCircle(
      center,
      r * 0.7,
      Paint()
        ..shader = RadialGradient(
          colors: [light.withValues(alpha: 0.35), light.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: r * 0.7)),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.78),
      math.pi * 0.15,
      math.pi * 0.55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.1
        ..strokeCap = StrokeCap.round
        ..color = light.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
  }

  static void _metalBands(Canvas canvas, Offset c, double r) {
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.55),
            Colors.black.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.4),
            Colors.black.withValues(alpha: 0.28),
          ],
          const [0.0, 0.28, 0.5, 0.7, 1.0],
        ),
    );
  }

  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
