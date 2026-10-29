import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'umrah_illustration_frame.dart';
import 'package:thekr_app/core/utils/app_digits.dart';

enum _Landmark {
  blackStone(
    'الحجر الأسود',
    'منه يبدأ الطواف وإليه ينتهي. استلمه وقبّله إن تيسّر دون أذى، وإلا فأشر إليه بيدك اليمنى وقل «الله أكبر».',
  ),
  yamani(
    'الركن اليماني',
    'استلمه بيدك اليمنى إن تيسّر دون تقبيل. فإن لم يتيسّر فامضِ دون إشارة. وبينه وبين الحجر الأسود تقول: «ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار».',
  ),
  iraqi(
    'الركن العراقي',
    'تمرّ به دون استلام. فالمشروع استلام الحجر الأسود والركن اليماني فقط.',
  ),
  shami(
    'الركن الشامي',
    'تمرّ به دون استلام. فالمشروع استلام الحجر الأسود والركن اليماني فقط.',
  ),
  hijr(
    'الحِجر',
    'جدار على شكل نصف دائرة، وهو من البيت. طُف من خارجه، ومن طاف من داخله لم يُحسب ذلك الشوط.',
  ),
  maqam(
    'مقام إبراهيم',
    'بعد تمام الطواف تصلي ركعتين خلفه إن تيسّر دون إيذاء، وإلا ففي أي موضع من المسجد.',
  );

  const _Landmark(this.title, this.body);

  final String title;
  final String body;
}

/// Top view of the Kaaba and the path of tawaf. Tap a landmark to learn what to
/// do there, or play the demo to see the direction and the seven rounds.
class TawafIllustration extends StatefulWidget {
  const TawafIllustration({super.key});

  @override
  State<TawafIllustration> createState() => _TawafIllustrationState();
}

class _TawafIllustrationState extends State<TawafIllustration>
    with SingleTickerProviderStateMixin {
  /// The first three rounds are quicker (raml for men), the rest ordinary.
  static const double _fastLapSeconds = 3;
  static const double _normalLapSeconds = 4.5;
  static const double _totalSeconds =
      3 * _fastLapSeconds + 4 * _normalLapSeconds;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (_totalSeconds * 1000).round()),
  );

  _Landmark? _selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Rounds completed (0..7, fractional) after [fraction] of the demo.
  static double _lapsAt(double fraction) {
    final seconds = fraction * _totalSeconds;
    const fastTotal = 3 * _fastLapSeconds;
    if (seconds <= fastTotal) return seconds / _fastLapSeconds;
    return 3 + (seconds - fastTotal) / _normalLapSeconds;
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = _selected;

    return UmrahIllustrationFrame(
      title: 'مسار الطواف حول الكعبة',
      infoTitle: selected?.title,
      infoBody: selected?.body,
      hint:
          'الكعبة عن يسارك دائماً، والدوران عكس عقارب الساعة. اضغط على أي علامة لتعرف معناها.',
      footer: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final laps = _lapsAt(_controller.value);
          final done = _controller.isCompleted;
          final lap = done ? 7 : math.min(7, laps.floor() + 1);
          final started = _controller.value > 0;
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
                      : 'شاهد الطواف',
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
                      ? 'سبعة أشواط تبدأ من الحجر الأسود'
                      : done
                      ? 'تمّ الطواف عند الحجر الأسود'
                      : 'الشوط ${AppDigits.of(lap)} من ${AppDigits.of(7)}${lap <= 3 ? ' · الرمل للرجال' : ''}',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = math.min(constraints.maxWidth, 330.w);
          final center = Offset(side / 2, side / 2);
          final half = side * 0.13; // half-diagonal of the Kaaba diamond
          final orbit = side * 0.355;

          Offset onOrbit(double degrees, [double scale = 1]) {
            final r = degrees * math.pi / 180;
            return center + Offset(math.cos(r), -math.sin(r)) * orbit * scale;
          }

          final markers = <_Landmark, Offset>{
            _Landmark.blackStone: onOrbit(0),
            _Landmark.iraqi: onOrbit(90),
            _Landmark.shami: onOrbit(180),
            _Landmark.yamani: onOrbit(270),
            _Landmark.hijr: onOrbit(135),
            _Landmark.maqam: onOrbit(48, 1.32),
          };

          return Center(
            child: SizedBox(
              width: side,
              height: side,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => CustomPaint(
                          painter: _TawafPainter(
                            center: center,
                            half: half,
                            orbit: orbit,
                            laps: _lapsAt(_controller.value),
                            showDot: _controller.value > 0,
                            ink: colors.textPrimary,
                            soft: colors.textSecondary.withValues(alpha: 0.35),
                            gold: colors.secondary,
                            accent: colors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  for (final entry in markers.entries)
                    Positioned(
                      left: entry.value.dx - 40.w,
                      top: entry.value.dy - 17.w,
                      width: 80.w,
                      child: _Marker(
                        label: entry.key.title,
                        selected: entry.key == selected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = entry.key);
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? colors.secondary : colors.surface,
              border: Border.all(
                color: selected ? colors.secondary : colors.primary,
                width: selected ? 2.2 : 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colors.secondary.withValues(alpha: 0.5),
                        blurRadius: 10.r,
                        spreadRadius: 1.r,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: AppIcon(
                HugeIcons.strokeRoundedInformationCircle,
                size: 15.w,
                color: selected ? Colors.white : colors.primary,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textStyles.bodySmall?.copyWith(
              color: selected ? colors.primary : colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TawafPainter extends CustomPainter {
  _TawafPainter({
    required this.center,
    required this.half,
    required this.orbit,
    required this.laps,
    required this.showDot,
    required this.ink,
    required this.soft,
    required this.gold,
    required this.accent,
  });

  final Offset center;

  /// Half the diagonal of the diamond that stands for the Kaaba.
  final double half;
  final double orbit;

  /// Rounds completed so far, fractional.
  final double laps;
  final bool showDot;
  final Color ink;
  final Color soft;
  final Color gold;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    // Path of tawaf, dashed.
    final ring = Paint()
      ..color = soft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final circle = Path()
      ..addOval(Rect.fromCircle(center: center, radius: orbit));
    for (final metric in circle.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 6, metric.length)), ring);
        d += 12;
      }
    }

    // Direction arrows (counter-clockwise), at the north-east and south-west.
    _arrow(canvas, 20);
    _arrow(canvas, 200);

    // Hijr: a half ring on the north-west side, outside the Kaaba.
    final north = center + Offset(0, -half);
    final west = center + Offset(-half, 0);
    final mid = (north + west) / 2;
    final radius = (north - west).distance / 2;
    final hijr = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: mid, radius: radius),
      -math.pi / 4,
      -math.pi,
      false,
      hijr,
    );

    // The Kaaba, seen from above, with its corners on the four directions.
    final kaaba = Path()
      ..moveTo(center.dx, center.dy - half)
      ..lineTo(center.dx + half, center.dy)
      ..lineTo(center.dx, center.dy + half)
      ..lineTo(center.dx - half, center.dy)
      ..close();
    canvas.drawShadow(kaaba, Colors.black, 6, false);
    canvas.drawPath(kaaba, Paint()..color = Colors.black.withValues(alpha: 0.88));
    canvas.drawPath(
      kaaba,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round,
    );
    // Door on the north-east wall.
    final doorMid = Offset(center.dx + half / 2, center.dy - half / 2);
    canvas.drawLine(
      doorMid + Offset(-half * 0.16, -half * 0.16),
      doorMid + Offset(half * 0.16, half * 0.16),
      Paint()
        ..color = gold
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
    // Black Stone at the east corner, Yamani corner at the south.
    canvas.drawCircle(
      center + Offset(half, 0),
      4.2,
      Paint()..color = gold,
    );
    canvas.drawCircle(
      center + Offset(0, half),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    // Start line at the Black Stone.
    canvas.drawLine(
      center + Offset(half + 6, 0),
      center + Offset(orbit + 14, 0),
      Paint()
        ..color = gold.withValues(alpha: 0.7)
        ..strokeWidth = 1.4,
    );

    if (showDot) {
      final angle = 2 * math.pi * laps; // counter-clockwise from the east
      final pos =
          center + Offset(math.cos(angle), -math.sin(angle)) * orbit;
      // Progress of the current round as a bright arc.
      final fraction = laps - laps.floorToDouble();
      if (fraction > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: orbit),
          0,
          -2 * math.pi * fraction,
          false,
          Paint()
            ..color = gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
      }
      canvas.drawCircle(pos, 11, Paint()..color = gold.withValues(alpha: 0.28));
      canvas.drawCircle(pos, 6, Paint()..color = gold);
      canvas.drawCircle(
        pos,
        6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  /// Small arrow head on the path showing the counter-clockwise direction.
  void _arrow(Canvas canvas, double degrees) {
    final a = degrees * math.pi / 180;
    final p = center + Offset(math.cos(a), -math.sin(a)) * orbit;
    // Tangent for counter-clockwise movement on screen.
    final tangent = Offset(-math.sin(a), -math.cos(a));
    final normal = Offset(-tangent.dy, tangent.dx);
    final tip = p + tangent * 8;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((p + normal * 5).dx, (p + normal * 5).dy)
      ..lineTo((p - normal * 5).dx, (p - normal * 5).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _TawafPainter old) =>
      old.laps != laps ||
      old.showDot != showDot ||
      old.center != center ||
      old.gold != gold ||
      old.accent != accent;
}
