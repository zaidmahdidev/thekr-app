import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'umrah_illustration_frame.dart';

enum _Piece {
  izar(
    'الإزار',
    'قطعة غير مفصّلة على الجسم تُلفّ على النصف الأسفل. ويُستحب أن تكون بيضاء نظيفة.',
  ),
  rida(
    'الرداء',
    'قطعة تُوضع على النصف الأعلى. وفي الطواف يجعل الرجل وسطه تحت إبطه الأيمن وطرفيه على كتفه الأيسر (الاضطباع)، ثم يغطي كتفه بعد الطواف.',
  ),
  sandals(
    'النعلان',
    'السنة أن يحرم الرجل في نعلين.',
  );

  const _Piece(this.title, this.body);

  final String title;
  final String body;
}

/// Flat drawing of what a man wears for ihram: two plain cloths and sandals.
/// It shows objects only; tapping one explains how it is worn.
class IhramIllustration extends StatefulWidget {
  const IhramIllustration({super.key});

  @override
  State<IhramIllustration> createState() => _IhramIllustrationState();
}

class _IhramIllustrationState extends State<IhramIllustration> {
  _Piece? _selected;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;

    return UmrahIllustrationFrame(
      title: 'ثياب إحرام الرجل',
      infoTitle: selected?.title,
      infoBody: selected?.body,
      hint: 'ثلاث قطع فقط. اضغط على أي واحدة لتعرف كيف تُلبس.',
      child: Row(
        children: [
          for (final piece in _Piece.values)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _PieceCard(
                  piece: piece,
                  selected: piece == selected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selected = piece);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PieceCard extends StatelessWidget {
  const _PieceCard({
    required this.piece,
    required this.selected,
    required this.onTap,
  });

  final _Piece piece;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.all(context.insets.sm),
        decoration: BoxDecoration(
          color: selected
              ? colors.secondary.withValues(alpha: 0.12)
              : colors.background,
          borderRadius: BorderRadius.circular(context.corners.lg),
          border: Border.all(
            color: selected
                ? colors.secondary
                : colors.textSecondary.withValues(alpha: 0.18),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 78.w,
              width: double.infinity,
              child: CustomPaint(
                painter: _PiecePainter(
                  piece: piece,
                  cloth: Colors.white,
                  line: colors.textSecondary.withValues(alpha: 0.55),
                  accent: colors.primary,
                  leather: colors.secondary,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              piece.title,
              style: context.textStyles.bodyMedium?.copyWith(
                color: selected ? colors.secondary : colors.textPrimary,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PiecePainter extends CustomPainter {
  _PiecePainter({
    required this.piece,
    required this.cloth,
    required this.line,
    required this.accent,
    required this.leather,
  });

  final _Piece piece;
  final Color cloth;
  final Color line;
  final Color accent;

  /// Base color of the sandals, taken from the theme.
  final Color leather;

  @override
  void paint(Canvas canvas, Size size) {
    switch (piece) {
      case _Piece.izar:
        _drawCloth(canvas, size, widthFactor: 0.78, heightFactor: 0.78, folds: 3);
      case _Piece.rida:
        _drawCloth(canvas, size, widthFactor: 0.9, heightFactor: 0.62, folds: 4);
      case _Piece.sandals:
        _drawSandals(canvas, size);
    }
  }

  void _drawCloth(
    Canvas canvas,
    Size size, {
    required double widthFactor,
    required double heightFactor,
    required int folds,
  }) {
    final w = size.width * widthFactor;
    final h = size.height * heightFactor;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: w,
      height: h,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    canvas.drawShadow(Path()..addRRect(rrect), Colors.black, 3, false);
    canvas.drawRRect(rrect, Paint()..color = cloth);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Soft fold lines.
    final fold = Paint()
      ..color = line.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var i = 1; i <= folds; i++) {
      final y = rect.top + rect.height * i / (folds + 1);
      canvas.drawLine(Offset(rect.left + 6, y), Offset(rect.right - 6, y), fold);
    }
    // Plain stripe at the edge, as on woven ihram cloth.
    canvas.drawLine(
      Offset(rect.left + 5, rect.top + 5),
      Offset(rect.right - 5, rect.top + 5),
      Paint()
        ..color = accent.withValues(alpha: 0.5)
        ..strokeWidth = 1.6,
    );
  }

  void _drawSandals(Canvas canvas, Size size) {
    final hsl = HSLColor.fromColor(leather);
    final sole = Paint()..color = leather.withValues(alpha: 0.8);
    final edge = Paint()
      ..color = hsl.withLightness((hsl.lightness * 0.6).clamp(0.0, 1.0)).toColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final strap = Paint()
      ..color = hsl.withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0)).toColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;

    for (final dx in [-0.21, 0.21]) {
      final cx = size.width / 2 + size.width * dx;
      final top = size.height * 0.04;
      final bottom = size.height * 0.96;
      final toeW = size.width * 0.17;
      final heelW = size.width * 0.12;
      // Foot-shaped sole: wide at the toes, narrower at the heel.
      final path = Path()
        ..moveTo(cx, top)
        ..cubicTo(cx + toeW * 1.15, top, cx + toeW * 1.1, size.height * 0.45, cx + heelW, size.height * 0.62)
        ..cubicTo(cx + heelW * 1.05, size.height * 0.8, cx + heelW * 0.9, bottom, cx, bottom)
        ..cubicTo(cx - heelW * 0.9, bottom, cx - heelW * 1.05, size.height * 0.8, cx - heelW, size.height * 0.62)
        ..cubicTo(cx - toeW * 1.1, size.height * 0.45, cx - toeW * 1.15, top, cx, top)
        ..close();
      canvas.drawPath(path, sole);
      canvas.drawPath(path, edge);
      // One strap across the forefoot and one over the instep.
      final y1 = size.height * 0.3;
      canvas.drawPath(
        Path()
          ..moveTo(cx - toeW * 0.95, y1 + size.height * 0.05)
          ..quadraticBezierTo(cx, y1 - size.height * 0.1, cx + toeW * 0.95, y1 + size.height * 0.05),
        strap,
      );
      final y2 = size.height * 0.55;
      canvas.drawPath(
        Path()
          ..moveTo(cx - toeW * 0.85, y2 + size.height * 0.04)
          ..quadraticBezierTo(cx, y2 - size.height * 0.1, cx + toeW * 0.85, y2 + size.height * 0.04),
        strap,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PiecePainter old) =>
      old.piece != piece ||
      old.line != line ||
      old.accent != accent ||
      old.leather != leather;
}
