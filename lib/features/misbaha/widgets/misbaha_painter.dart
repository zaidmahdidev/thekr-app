import 'package:flutter/material.dart';
import '../models/misbaha_models.dart';
import 'bead_renderer.dart';

/// Draws the tasbih: a string running along an S curve with beads that slide
/// along it. Each bead is drawn by [BeadRenderer].
class InfiniteLoopBeadPainter extends CustomPainter {
  final double scrollProgress;
  final Color primaryColor;
  final Color secondaryColor;
  final BeadType beadType;

  InfiniteLoopBeadPainter({
    required this.scrollProgress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.beadType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    // Organic S curve for a natural hand-held feel.
    path.moveTo(size.width * 0.18, -150);
    path.cubicTo(
      size.width * 0.45,
      size.height * 0.3,
      size.width * 0.05,
      size.height * 0.65,
      size.width * 0.28,
      size.height + 150,
    );

    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;

    const beadRadius = 32.0;
    const beadSpacing = 72.0;
    final centerPoint = totalLength * 0.45;
    const focusGapSize = 130.0;

    // The string: a soft shadow and the thread. It runs behind the beads.
    canvas.drawPath(
      path.shift(const Offset(1.5, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = BeadRenderer.threadColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    for (int i = -5; i < 20; i++) {
      final logicalDist = (i * beadSpacing) + (scrollProgress * beadSpacing);
      final wrappedDist = logicalDist % (beadSpacing * 25);

      // Smooth, wider gap around the focus point (smoothstep).
      const transitionWidth = 80.0;
      final t =
          ((wrappedDist - (centerPoint - transitionWidth)) /
                  (transitionWidth * 2))
              .clamp(0.0, 1.0);
      final smoothT = t * t * (3 - 2 * t);
      final actualDist = wrappedDist + (focusGapSize * smoothT);

      // Fade at both ends for the endless effect.
      double opacity = 1.0;
      if (actualDist < 100) opacity = (actualDist / 100).clamp(0.0, 1.0);
      if (actualDist > totalLength - 100) {
        opacity = ((totalLength - actualDist) / 100).clamp(0.0, 1.0);
      }

      if (actualDist < 0 || actualDist > totalLength || opacity <= 0.05) {
        continue;
      }

      final tangent = metrics.getTangentForOffset(actualDist)!;
      BeadRenderer.paint(
        canvas,
        center: tangent.position,
        radius: beadRadius,
        type: beadType,
        angle: tangent.angle,
        opacity: opacity,
      );
    }
  }

  /// Repaint when the beads move OR when the look changes.
  @override
  bool shouldRepaint(covariant InfiniteLoopBeadPainter old) =>
      old.scrollProgress != scrollProgress ||
      old.beadType != beadType ||
      old.secondaryColor != secondaryColor ||
      old.primaryColor != primaryColor;
}
