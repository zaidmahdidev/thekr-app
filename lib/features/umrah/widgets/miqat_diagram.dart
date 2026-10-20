import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import '../data/umrah_miqat_data.dart';
import '../models/umrah_models.dart';

/// Schematic of the five miqats around Makkah, placed by their direction.
/// Tapping one selects it. It is for orientation only and not to scale.
class MiqatDiagram extends StatelessWidget {
  const MiqatDiagram({
    super.key,
    required this.selectedId,
    required this.onSelect,
  });

  final String? selectedId;
  final ValueChanged<MiqatSpot> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, 340.w);
        final center = Offset(side / 2, side / 2);
        final orbit = side * 0.34;
        final nodeWidth = 76.w;

        Offset positionOf(MiqatSpot spot) {
          final radians = spot.bearing * math.pi / 180;
          return center + Offset(math.sin(radians), -math.cos(radians)) * orbit;
        }

        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DiagramPainter(
                      center: center,
                      orbit: orbit,
                      ringColor: colors.textSecondary.withValues(alpha: 0.18),
                      spokeColor: colors.textSecondary.withValues(alpha: 0.3),
                      activeColor: colors.secondary,
                      targets: {
                        for (final spot in UmrahMiqatData.spots)
                          spot.id: positionOf(spot),
                      },
                      selectedId: selectedId,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'الشمال ↑',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ),
                const _Kaaba(),
                for (final spot in UmrahMiqatData.spots)
                  Positioned(
                    left: positionOf(spot).dx - nodeWidth / 2,
                    top: positionOf(spot).dy - 24.w,
                    width: nodeWidth,
                    child: _Node(
                      spot: spot,
                      selected: spot.id == selectedId,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onSelect(spot);
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Kaaba extends StatelessWidget {
  const _Kaaba();

  @override
  Widget build(BuildContext context) {
    final gold = context.colors.secondary;
    return Align(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(context.corners.md),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.35),
                  blurRadius: 16.r,
                  spreadRadius: 1.r,
                ),
              ],
            ),
            child: Align(
              alignment: const Alignment(0, -0.35),
              child: Container(
                height: 6.h,
                color: gold,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'مكة',
            style: context.textStyles.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.spot,
    required this.selected,
    required this.onTap,
  });

  final MiqatSpot spot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = 44.w;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? colors.secondary : colors.surface,
              border: Border.all(
                color: selected ? colors.secondary : colors.primary,
                width: selected ? 2.4 : 1.6,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colors.secondary.withValues(alpha: 0.5),
                        blurRadius: 14.r,
                        spreadRadius: 2.r,
                      ),
                    ]
                  : context.shadows.low,
            ),
            child: Center(
              child: AppIcon(
                HugeIcons.strokeRoundedLocation01,
                size: 22.w,
                color: selected ? Colors.white : colors.primary,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            spot.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textStyles.bodySmall?.copyWith(
              color: selected ? colors.primary : colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagramPainter extends CustomPainter {
  _DiagramPainter({
    required this.center,
    required this.orbit,
    required this.ringColor,
    required this.spokeColor,
    required this.activeColor,
    required this.targets,
    required this.selectedId,
  });

  final Offset center;
  final double orbit;
  final Color ringColor;
  final Color spokeColor;
  final Color activeColor;
  final Map<String, Offset> targets;
  final String? selectedId;

  @override
  void paint(Canvas canvas, Size size) {
    final ring = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, orbit * 0.5, ring);
    canvas.drawCircle(center, orbit, ring);
    canvas.drawCircle(center, orbit * 1.32, ring);

    for (final entry in targets.entries) {
      final active = entry.key == selectedId;
      final paint = Paint()
        ..color = active ? activeColor : spokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = active ? 2.4 : 1.2;
      final direction = (entry.value - center) / (entry.value - center).distance;
      final start = center + direction * (orbit * 0.22);
      final end = entry.value - direction * (orbit * 0.2);
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy);
      if (active) {
        canvas.drawPath(path, paint);
      } else {
        _drawDashed(canvas, path, paint);
      }
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + 5, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DiagramPainter old) =>
      old.selectedId != selectedId ||
      old.center != center ||
      old.ringColor != ringColor ||
      old.activeColor != activeColor;
}
