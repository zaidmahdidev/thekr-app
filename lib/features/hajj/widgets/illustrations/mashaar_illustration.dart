import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/features/umrah/widgets/illustrations/umrah_illustration_frame.dart';

enum _Place {
  makkah(
    'مكة',
    'فيها الكعبة. تطوف فيها طواف الإفاضة وتسعى، ويكون طواف الوداع آخر عهدك بها.',
    Offset(0.12, 0.64),
  ),
  mina(
    'منى',
    'تتوجه إليها يوم التروية، وتعود إليها يوم العيد لرمي جمرة العقبة والهدي والحلق، ثم تبيت بها أيام التشريق وترمي الجمرات الثلاث.',
    Offset(0.36, 0.36),
  ),
  muzdalifah(
    'مزدلفة',
    'بين منى وعرفة. تصلي بها المغرب والعشاء جمعاً وتبيت حتى الفجر، ثم تنصرف إلى منى قبل طلوع الشمس.',
    Offset(0.62, 0.64),
  ),
  arafah(
    'عرفة',
    'الوقوف بها ركن الحج، قال ﷺ: «الحج عرفة». تبقى فيها حتى غروب الشمس. ووادي عرنة ليس منها.',
    Offset(0.88, 0.36),
  );

  const _Place(this.title, this.body, this.position);

  final String title;
  final String body;

  /// Place on the schematic, as fractions of its width and height.
  final Offset position;
}

class _Stage {
  const _Stage(this.when, this.from, this.to, this.text);

  final String when;
  final _Place from;
  final _Place to;
  final String text;
}

const List<_Stage> _stages = [
  _Stage('٨ ذو الحجة', _Place.makkah, _Place.mina,
      'تحرم بالحج وتتوجه إلى منى، وتصلي بها الصلوات قصراً.'),
  _Stage('٩ ذو الحجة', _Place.mina, _Place.arafah,
      'تتجه إلى عرفة بعد طلوع الشمس، وتقف بها حتى غروب الشمس.'),
  _Stage('غروب يوم عرفة', _Place.arafah, _Place.muzdalifah,
      'تنصرف بسكينة وتصلي المغرب والعشاء جمعاً وتبيت بمزدلفة.'),
  _Stage('١٠ ذو الحجة', _Place.muzdalifah, _Place.mina,
      'بعد الفجر إلى منى: رمي جمرة العقبة والهدي والحلق.'),
  _Stage('١٠ ذو الحجة', _Place.mina, _Place.makkah,
      'طواف الإفاضة والسعي بمكة، ثم العودة إلى منى للمبيت.'),
  _Stage('١١ و١٢ و١٣', _Place.mina, _Place.mina,
      'المبيت بمنى ورمي الجمرات الثلاث بعد الزوال كل يوم.'),
  _Stage('عند المغادرة', _Place.mina, _Place.makkah,
      'طواف الوداع بمكة ثم المغادرة.'),
];

/// Schematic of the four places of Hajj with the route the pilgrim takes day by
/// day. Tap a place to learn what happens there, or play the route.
class MashaarIllustration extends StatefulWidget {
  const MashaarIllustration({super.key});

  @override
  State<MashaarIllustration> createState() => _MashaarIllustrationState();
}

class _MashaarIllustrationState extends State<MashaarIllustration>
    with SingleTickerProviderStateMixin {
  static const double _stageSeconds = 3.2;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: (_stages.length * _stageSeconds * 1000).round(),
    ),
  );

  _Place? _selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Stage index and progress (0..1) inside it.
  ({int index, double t}) _at(double fraction) {
    final total = fraction * _stages.length;
    final index = math.min(_stages.length - 1, total.floor());
    final t = fraction >= 1 ? 1.0 : total - index;
    return (index: index, t: Curves.easeInOut.transform(t));
  }

  void _togglePlay() {
    HapticFeedback.selectionClick();
    setState(() => _selected = null);
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
    final started = _controller.value > 0;
    final stage = _stages[_at(_controller.value).index];
    final showStage = _selected == null && started;

    return UmrahIllustrationFrame(
      title: 'المشاعر ومسار الحاج',
      infoTitle: _selected != null
          ? _selected!.title
          : showStage
          ? stage.when
          : null,
      infoBody: _selected != null
          ? _selected!.body
          : showStage
          ? stage.text
          : null,
      hint:
          'أربعة أماكن: مكة ومنى ومزدلفة وعرفة. اضغط على أي مكان، أو شاهد مسار الحاج يوماً بيوم.',
      footer: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final done = _controller.isCompleted;
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
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
                    : 'شاهد مسار الحاج',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.corners.xl),
                ),
              ),
            ),
          );
        },
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = 210.w;
          Offset pos(_Place p) =>
              Offset(p.position.dx * width, p.position.dy * height);

          return SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final state = _at(_controller.value);
                        final current = _stages[state.index];
                        final from = pos(current.from);
                        final to = pos(current.to);
                        return CustomPaint(
                          painter: _MapPainter(
                            places: {for (final p in _Place.values) p: pos(p)},
                            legs: [
                              for (final s in _stages)
                                if (s.from != s.to) (pos(s.from), pos(s.to)),
                            ],
                            // The highlighted leg only appears once the route plays.
                            activeFrom: _controller.value == 0 ||
                                    current.from == current.to
                                ? null
                                : from,
                            activeTo: _controller.value == 0 ||
                                    current.from == current.to
                                ? null
                                : to,
                            dot: _controller.value > 0
                                ? Offset.lerp(from, to, state.t)
                                : null,
                            line: colors.textSecondary.withValues(alpha: 0.35),
                            active: colors.secondary,
                            ground: colors.primary.withValues(alpha: 0.06),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                for (final place in _Place.values)
                  Positioned(
                    left: pos(place).dx - 36.w,
                    top: pos(place).dy - 26.w,
                    width: 72.w,
                    child: _Marker(
                      place: place,
                      selected: place == _selected,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selected = place);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.place,
    required this.selected,
    required this.onTap,
  });

  final _Place place;
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
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? colors.secondary : colors.surface,
              border: Border.all(
                color: selected ? colors.secondary : colors.primary,
                width: selected ? 2.2 : 1.6,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colors.secondary.withValues(alpha: 0.5),
                        blurRadius: 12.r,
                        spreadRadius: 1.r,
                      ),
                    ]
                  : context.shadows.low,
            ),
            child: Center(
              child: AppIcon(
                switch (place) {
                  _Place.makkah => HugeIcons.strokeRoundedMosque01,
                  _Place.mina => HugeIcons.strokeRoundedTent,
                  _Place.muzdalifah => HugeIcons.strokeRoundedMoon02,
                  _Place.arafah => HugeIcons.strokeRoundedMountain,
                },
                size: 19.w,
                color: selected ? Colors.white : colors.primary,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            place.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textStyles.bodySmall?.copyWith(
              color: selected ? colors.primary : colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.places,
    required this.legs,
    required this.activeFrom,
    required this.activeTo,
    required this.dot,
    required this.line,
    required this.active,
    required this.ground,
  });

  final Map<_Place, Offset> places;
  final List<(Offset, Offset)> legs;
  final Offset? activeFrom;
  final Offset? activeTo;
  final Offset? dot;
  final Color line;
  final Color active;
  final Color ground;

  @override
  void paint(Canvas canvas, Size size) {
    // Soft ground behind the four places.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.08, size.width, size.height * 0.84),
        const Radius.circular(18),
      ),
      Paint()..color = ground,
    );

    final dashed = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    for (final (a, b) in legs) {
      _dashedLine(canvas, a, b, dashed);
    }

    if (activeFrom != null && activeTo != null) {
      canvas.drawLine(
        activeFrom!,
        activeTo!,
        Paint()
          ..color = active
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round,
      );
    }

    if (dot != null) {
      canvas.drawCircle(dot!, 13, Paint()..color = active.withValues(alpha: 0.3));
      canvas.drawCircle(dot!, 7, Paint()..color = active);
      canvas.drawCircle(
        dot!,
        7,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    final total = (b - a).distance;
    if (total == 0) return;
    final direction = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      canvas.drawLine(
        a + direction * d,
        a + direction * math.min(d + 5, total),
        paint,
      );
      d += 10;
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) =>
      old.dot != dot ||
      old.activeFrom != activeFrom ||
      old.activeTo != activeTo ||
      old.active != active ||
      old.line != line;
}
