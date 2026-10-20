import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import '../umrah_segmented_control.dart';
import 'umrah_illustration_frame.dart';

enum _Spot {
  safa(
    'الصفا',
    'منه يبدأ السعي. اقرأ «إن الصفا والمروة من شعائر الله»، واصعد حتى ترى الكعبة واستقبلها، وكبّر وهلّل وادعُ. وتكرر الذكر ثلاث مرات.',
  ),
  marwa(
    'المروة',
    'عندها ينتهي الشوط السابع. افعل عليها كما فعلت على الصفا: استقبل الكعبة، وكبّر وهلّل وادعُ.',
  ),
  greens(
    'العلمان الأخضران',
    'علامتان خضراوان يُسرع الرجال بينهما في المشي. أما المرأة فتمشي ولا تسرع.',
  );

  const _Spot(this.title, this.body);

  final String title;
  final String body;
}

/// Side view of the path between Safa and Marwa with the green markers. The
/// demo walks the seven rounds, ending at Marwa; men speed up between the
/// markers.
class SaiIllustration extends StatefulWidget {
  const SaiIllustration({super.key});

  @override
  State<SaiIllustration> createState() => _SaiIllustrationState();
}

class _SaiIllustrationState extends State<SaiIllustration>
    with SingleTickerProviderStateMixin {
  static const int _rounds = 7;
  static const double _lapSeconds = 4;

  /// Where the green markers sit along the path (fractions of its length).
  static const double _greenStart = 0.38;
  static const double _greenEnd = 0.62;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (_rounds * _lapSeconds * 1000).round()),
  );

  _Spot? _selected;
  bool _isMan = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Position along the path (0 = Safa, 1 = Marwa) and the round number.
  ({double position, int lap}) _stateAt(double fraction) {
    final total = fraction * _rounds;
    final lap = math.min(_rounds - 1, total.floor());
    final progress = fraction >= 1 ? 1.0 : total - lap;
    final along = _isMan ? _withRunning(progress) : progress;
    final forward = lap.isEven; // even rounds go Safa -> Marwa
    final atEnd = fraction >= 1;
    return (
      position: atEnd ? 1.0 : (forward ? along : 1 - along),
      lap: lap + 1,
    );
  }

  /// Time-warp so the walker covers the green zone twice as fast.
  static double _withRunning(double t) {
    const walk = _greenStart + (1 - _greenEnd);
    const run = _greenEnd - _greenStart;
    const total = walk + run / 2;
    final t1 = _greenStart / total;
    final t2 = (run / 2) / total;
    if (t < t1) return t / t1 * _greenStart;
    if (t < t1 + t2) {
      return _greenStart + (t - t1) / t2 * run;
    }
    return _greenEnd + (t - t1 - t2) / (1 - t1 - t2) * (1 - _greenEnd);
  }

  void _togglePlay() {
    HapticFeedback.selectionClick();
    if (_controller.isAnimating) {
      _controller.stop();
    } else if (_controller.isCompleted) {
      _controller.forward(from: 0);
    } else {
      _controller.forward();
    }
    setState(() {});
  }

  void _select(_Spot spot) {
    HapticFeedback.selectionClick();
    setState(() => _selected = spot);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = _selected;

    return UmrahIllustrationFrame(
      title: 'السعي بين الصفا والمروة',
      infoTitle: selected?.title,
      infoBody: selected?.body,
      hint:
          'الشوط من الصفا إلى المروة، والعودة شوط آخر، فينتهي السابع عند المروة. اضغط على أي علامة.',
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UmrahSegmentedControl<bool>(
            values: const [true, false],
            selected: _isMan,
            labelOf: (isMan) => isMan ? 'رجل' : 'امرأة',
            onChanged: (value) => setState(() {
              _isMan = value;
              _controller.reset();
            }),
          ),
          SizedBox(height: context.insets.sm),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final state = _stateAt(_controller.value);
              final done = _controller.isCompleted;
              final started = _controller.value > 0;
              final toMarwa = (state.lap - 1).isEven;
              return Row(
                children: [
                  FilledButton.icon(
                    onPressed: _togglePlay,
                    icon: AppIcon(
                      _controller.isAnimating
                          ? HugeIcons.strokeRoundedPause
                          : HugeIcons.strokeRoundedPlay,
                      size: 20.w,
                    ),
                    label: Text(
                      _controller.isAnimating
                          ? 'إيقاف'
                          : done
                          ? 'إعادة'
                          : 'شاهد السعي',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.corners.xl),
                      ),
                    ),
                  ),
                  SizedBox(width: context.insets.sm + 2.w),
                  Expanded(
                    child: Text(
                      !started
                          ? 'سبعة أشواط تبدأ بالصفا'
                          : done
                          ? 'انتهى السعي عند المروة'
                          : 'الشوط ${QuranText.digits(state.lap)} من ${QuranText.digits(_rounds)} · ${toMarwa ? 'نحو المروة' : 'نحو الصفا'}',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = 150.w;
          final left = width * 0.14;
          final right = width * 0.86;
          final trackY = height * 0.62;

          return SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => CustomPaint(
                        painter: _SaiPainter(
                          left: left,
                          right: right,
                          trackY: trackY,
                          position: _stateAt(_controller.value).position,
                          showDot: _controller.value > 0,
                          greenStart: _greenStart,
                          greenEnd: _greenEnd,
                          track: colors.textSecondary.withValues(alpha: 0.45),
                          hill: colors.primary,
                          gold: colors.secondary,
                          green: colors.success,
                        ),
                      ),
                    ),
                  ),
                ),
                _label(context, _Spot.safa, right, trackY - 82.w, selected),
                _label(context, _Spot.marwa, left, trackY - 82.w, selected),
                Positioned(
                  left: left + (right - left) * _greenStart - 34.w,
                  top: trackY + 22.w,
                  width: (right - left) * (_greenEnd - _greenStart) + 68.w,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _select(_Spot.greens),
                    child: Text(
                      _Spot.greens.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: _selected == _Spot.greens
                            ? colors.success
                            : colors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _label(
    BuildContext context,
    _Spot spot,
    double x,
    double top,
    _Spot? selected,
  ) {
    final colors = context.colors;
    final isSelected = selected == spot;
    return Positioned(
      left: x - 42.w,
      top: top,
      width: 84.w,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(spot),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: isSelected ? colors.secondary : colors.surface,
                borderRadius: BorderRadius.circular(context.corners.xl),
                border: Border.all(
                  color: isSelected ? colors.secondary : colors.primary,
                  width: isSelected ? 2 : 1.4,
                ),
              ),
              child: Text(
                spot.title,
                style: context.textStyles.bodySmall?.copyWith(
                  color: isSelected ? Colors.white : colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaiPainter extends CustomPainter {
  _SaiPainter({
    required this.left,
    required this.right,
    required this.trackY,
    required this.position,
    required this.showDot,
    required this.greenStart,
    required this.greenEnd,
    required this.track,
    required this.hill,
    required this.gold,
    required this.green,
  });

  final double left;
  final double right;
  final double trackY;

  /// 0 at Safa (right), 1 at Marwa (left).
  final double position;
  final bool showDot;
  final double greenStart;
  final double greenEnd;
  final Color track;
  final Color hill;
  final Color gold;
  final Color green;

  double _x(double t) => right + (left - right) * t;

  @override
  void paint(Canvas canvas, Size size) {
    // Hills at both ends.
    for (final x in [right, left]) {
      final path = Path()
        ..moveTo(x - 34, trackY)
        ..quadraticBezierTo(x - 10, trackY - 34, x, trackY - 40)
        ..quadraticBezierTo(x + 10, trackY - 34, x + 34, trackY)
        ..close();
      canvas.drawPath(path, Paint()..color = hill.withValues(alpha: 0.18));
      canvas.drawPath(
        path,
        Paint()
          ..color = hill
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // The path itself.
    canvas.drawLine(
      Offset(right, trackY),
      Offset(left, trackY),
      Paint()
        ..color = track
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Green zone and its two markers.
    final zoneStart = _x(greenStart);
    final zoneEnd = _x(greenEnd);
    canvas.drawLine(
      Offset(zoneStart, trackY),
      Offset(zoneEnd, trackY),
      Paint()
        ..color = green.withValues(alpha: 0.6)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    for (final x in [zoneStart, zoneEnd]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, trackY - 14), width: 8, height: 26),
          const Radius.circular(3),
        ),
        Paint()..color = green,
      );
      canvas.drawCircle(Offset(x, trackY - 14), 2.4, Paint()..color = Colors.white);
    }

    if (showDot) {
      final x = _x(position);
      canvas.drawCircle(Offset(x, trackY), 12, Paint()..color = gold.withValues(alpha: 0.28));
      canvas.drawCircle(Offset(x, trackY), 6.5, Paint()..color = gold);
      canvas.drawCircle(
        Offset(x, trackY),
        6.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SaiPainter old) =>
      old.position != position ||
      old.showDot != showDot ||
      old.left != left ||
      old.right != right ||
      old.gold != gold ||
      old.green != green;
}
