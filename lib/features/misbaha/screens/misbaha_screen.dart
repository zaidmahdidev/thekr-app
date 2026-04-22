import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import '../providers/misbaha_provider.dart';

@RoutePage()
class MisbahaScreen extends ConsumerStatefulWidget {
  const MisbahaScreen({super.key});

  @override
  ConsumerState<MisbahaScreen> createState() => _MisbahaScreenState();
}

class _MisbahaScreenState extends ConsumerState<MisbahaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;
  late double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      upperBound: 1000000.0, // Indefinite scrolling
    )..addListener(() {
        setState(() {
          _scrollProgress = _scrollController.value;
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    ref.read(misbahaProvider.notifier).increment();
    
    final target = ref.read(misbahaProvider).totalCount.toDouble();
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleReset() {
    HapticFeedback.vibrate();
    ref.read(misbahaProvider.notifier).reset();
    _scrollController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(misbahaProvider);

    return AppScaffold(
      title: 'المسبحة الإلكترونية',
      body: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // The Real Infinite Loop Master Painter
            Positioned.fill(
              child: CustomPaint(
                painter: InfiniteLoopBeadPainter(
                  scrollProgress: _scrollProgress,
                  primaryColor: context.colors.primary,
                  secondaryColor: context.colors.secondary,
                ),
              ),
            ),

            // Counter Overlay
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 30.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ZikrSelector(),
                    SizedBox(height: 40.h),
                    _CounterDisplay(count: state.count),
                    SizedBox(height: 20.h),
                    _ResetButton(onReset: _handleReset),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    path.moveTo(size.width * 0.18, -150);
    path.cubicTo(
      size.width * 0.45, size.height * 0.3,
      size.width * 0.05, size.height * 0.65,
      size.width * 0.28, size.height + 150,
    );

    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;
    const beadRadius = 32.0;
    const beadSpacing = 72.0;
    final centerPoint = totalLength * 0.45;
    final focusGapSize = 130.0; // The large gap where string is visible

    // Draw String Line
    final stringPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, stringPaint);

    // Number of beads to show (sufficient to cover screen)
    for (int i = -5; i < 20; i++) {
        // Core logic for infinite flow
        double logicalDist = (i * beadSpacing) + (scrollProgress * beadSpacing);
        
        // Wrap the logical distance so it loops infinitely on screen
        double wrappedDist = logicalDist % (beadSpacing * 25); 
        
        // --- NEW SMOOTH GAP LOGIC ---
        // Instead of if/else (which causes jumps), we use a smooth transition.
        // We define a 'transition zone' around the center where the bead 'speeds up' to cross the gap.
        const transitionWidth = 80.0;
        double t = ((wrappedDist - (centerPoint - transitionWidth)) / (transitionWidth * 2)).clamp(0.0, 1.0);
        // Smoothstep curve: 3t^2 - 2t^3
        double smoothT = t * t * (3 - 2 * t);
        
        double actualDist = wrappedDist + (focusGapSize * smoothT);
        // ----------------------------

        // Opacity Fading at edges
        double opacity = 1.0;
        if (actualDist < 100) opacity = (actualDist / 100).clamp(0, 1);
        if (actualDist > totalLength - 100) opacity = ((totalLength - actualDist) / 100).clamp(0, 1);

        if (actualDist >= 0 && actualDist <= totalLength) {
          _drawBeadAtDist(canvas, metrics, actualDist, beadRadius, opacity);
        }
    }
  }

  void _drawBeadAtDist(ui.Canvas canvas, ui.PathMetric metric, double dist, double radius, double opacity) {
    if (dist < 0 || dist > metric.length) return;
    final tangent = metric.getTangentForOffset(dist)!;
    _drawHyperRealisticBead(canvas, tangent.position, radius, tangent.angle, opacity);
  }

  void _drawHyperRealisticBead(Canvas canvas, Offset center, double radius, double angle, double opacity) {
    if (opacity <= 0.05) return;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center.translate(5, 5), radius, shadowPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
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

    final specPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.5 * opacity),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center.translate(-radius*0.4, -radius*0.4), radius: radius*0.3));
    
    canvas.drawCircle(center.translate(-radius*0.35, -radius*0.35), radius*0.2, specPaint);

    final holePaint = Paint()..color = Colors.black.withValues(alpha: 0.7 * opacity);
    final holeOffset = radius * 0.95;
    canvas.drawCircle(center.translate(math.cos(angle - math.pi/2) * holeOffset, math.sin(angle - math.pi/2) * holeOffset), 4, holePaint);
    canvas.drawCircle(center.translate(math.cos(angle + math.pi/2) * holeOffset, math.sin(angle + math.pi/2) * holeOffset), 4, holePaint);
  }

  @override
  bool shouldRepaint(covariant InfiniteLoopBeadPainter oldDelegate) => 
      oldDelegate.scrollProgress != scrollProgress;
}

class _CounterDisplay extends StatelessWidget {
  final int count;
  const _CounterDisplay({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: AppTypography.h1.copyWith(
              fontSize: 84.sp,
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'عدد التسبيحات',
            style: AppTypography.label.copyWith(
              color: context.colors.primary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZikrSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentZikr = ref.watch(misbahaProvider).currentZikr;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: context.colors.primary.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MisbahaZikr>(
          value: currentZikr,
          dropdownColor: context.colors.surface,
          icon: Icon(Icons.auto_awesome_rounded, color: context.colors.secondary, size: 20),
          items: MisbahaZikr.values.map((zikr) {
            return DropdownMenuItem(
              value: zikr,
              child: Text(
                zikr.label,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(misbahaProvider.notifier).setZikr(value);
            }
          },
        ),
      ),
    );
  }
}

class _ResetButton extends ConsumerWidget {
  final VoidCallback onReset;
  const _ResetButton({required this.onReset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton.filled(
      onPressed: onReset,
      icon: Icon(Icons.refresh_rounded, color: context.colors.background),
      style: IconButton.styleFrom(
        backgroundColor: context.colors.secondary,
        padding: EdgeInsets.all(12.w),
      ),
    );
  }
}
