import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Row of bouncing bars that shows audio is playing. When [active] is false the
/// bars rest at a low, even height.
class RadioEqualizer extends StatefulWidget {
  const RadioEqualizer({
    super.key,
    required this.active,
    required this.color,
    this.height = 28,
    this.barWidth = 3,
    this.bars = 5,
  });

  final bool active;
  final Color color;
  final double height;
  final double barWidth;
  final int bars;

  @override
  State<RadioEqualizer> createState() => _RadioEqualizerState();
}

class _RadioEqualizerState extends State<RadioEqualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant RadioEqualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.bars * widget.barWidth * 2 - widget.barWidth;
    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _EqualizerPainter(
              progress: widget.active ? _controller.value : null,
              color: widget.color,
              bars: widget.bars,
              barWidth: widget.barWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class _EqualizerPainter extends CustomPainter {
  _EqualizerPainter({
    required this.progress,
    required this.color,
    required this.bars,
    required this.barWidth,
  });

  /// 0..1 loop position, or null when the bars should rest.
  final double? progress;
  final Color color;
  final int bars;
  final double barWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    for (var i = 0; i < bars; i++) {
      final level = progress == null
          ? 0.18
          : 0.22 +
                0.78 *
                    (0.5 +
                        0.5 *
                            math.sin(
                              progress! * 2 * math.pi * (1 + i % 3) +
                                  i * 1.7,
                            ));
      final barHeight = math.max(barWidth, size.height * level);
      final x = barWidth / 2 + i * barWidth * 2;
      final center = size.height / 2;
      canvas.drawLine(
        Offset(x, center - barHeight / 2),
        Offset(x, center + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EqualizerPainter old) =>
      old.progress != progress || old.color != color;
}
