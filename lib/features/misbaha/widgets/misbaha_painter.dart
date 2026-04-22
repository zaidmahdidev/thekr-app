import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class InfiniteLoopBeadPainter extends CustomPainter {
  final double scrollProgress;
  final Color primaryColor;
  final Color secondaryColor;

  InfiniteLoopBeadPainter({
    required this.scrollProgress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    // Beautiful Organic S-Curve for natural handheld feel
    path.moveTo(size.width * 0.18, -150);
    path.cubicTo(
      size.width * 0.45, size.height * 0.3,
      size.width * 0.05, size.height * 0.65,
      size.width * 0.28, size.height + 150,
    );

    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;
    
    // Geometry Constants
    const beadRadius = 32.0;
    const beadSpacing = 72.0;
    final centerPoint = totalLength * 0.45;
    final focusGapSize = 130.0;

    // Draw String Line (Bead String)
    final stringPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, stringPaint);

    // Render Window of Beads
    for (int i = -5; i < 20; i++) {
        double logicalDist = (i * beadSpacing) + (scrollProgress * beadSpacing);
        double wrappedDist = logicalDist % (beadSpacing * 25); 
        
        // --- SMOOTH GAP LOGIC (Sigmoid interpolation) ---
        const transitionWidth = 80.0;
        double t = ((wrappedDist - (centerPoint - transitionWidth)) / (transitionWidth * 2)).clamp(0.0, 1.0);
        double smoothT = t * t * (3 - 2 * t);
        
        double actualDist = wrappedDist + (focusGapSize * smoothT);

        // Edge Fading for Infinite Effect
        double opacity = 1.0;
        if (actualDist < 100) opacity = (actualDist / 100).clamp(0.0, 1.0);
        if (actualDist > totalLength - 100) opacity = ((totalLength - actualDist) / 100).clamp(0.0, 1.0);

        if (actualDist >= 0 && actualDist <= totalLength) {
          _drawBeadAtDist(canvas, metrics, actualDist, beadRadius, opacity);
        }
    }
  }

  void _drawBeadAtDist(Canvas canvas, ui.PathMetric metric, double dist, double radius, double opacity) {
    if (dist < 0 || dist > metric.length) return;
    final tangent = metric.getTangentForOffset(dist)!;
    _drawHyperRealisticBead(canvas, tangent.position, radius, tangent.angle, opacity);
  }

  void _drawHyperRealisticBead(Canvas canvas, Offset center, double radius, double angle, double opacity) {
    if (opacity <= 0.05) return;

    // 1. Drop Shadow (Physicality)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center.translate(5, 5), radius, shadowPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // 2. Base Sphere (Wood Texture Gradient)
    final baseGradient = RadialGradient(
      colors: [
        const Color(0xFFC17F59).withValues(alpha: opacity), 
        const Color(0xFF5D3622).withValues(alpha: opacity), 
        const Color(0xFF2B1810).withValues(alpha: opacity),
      ],
      stops: const [0.0, 0.7, 1.0],
      center: const Alignment(-0.35, -0.35),
    ).createShader(rect);

    canvas.drawCircle(center, radius, Paint()..shader = baseGradient);

    // 3. Specular Highlight (The 3D "Pop")
    final specPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.5 * opacity),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center.translate(-radius*0.4, -radius*0.4), radius: radius*0.3));
    
    canvas.drawCircle(center.translate(-radius*0.35, -radius*0.35), radius*0.2, specPaint);

    // 4. Bead String Hole (Depth)
    final holePaint = Paint()..color = Colors.black.withValues(alpha: 0.7 * opacity);
    final holeOffset = radius * 0.95;
    canvas.drawCircle(center.translate(math.cos(angle - math.pi/2) * holeOffset, math.sin(angle - math.pi/2) * holeOffset), 4, holePaint);
    canvas.drawCircle(center.translate(math.cos(angle + math.pi/2) * holeOffset, math.sin(angle + math.pi/2) * holeOffset), 4, holePaint);
  }

  @override
  bool shouldRepaint(covariant InfiniteLoopBeadPainter oldDelegate) => 
      oldDelegate.scrollProgress != scrollProgress;
}
