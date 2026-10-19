import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import '../models/misbaha_models.dart';
import 'bead_renderer.dart';

class BeadColorPicker extends StatefulWidget {
  final BeadType currentType;
  final Function(BeadType) onSelected;

  const BeadColorPicker({
    super.key,
    required this.currentType,
    required this.onSelected,
  });

  @override
  State<BeadColorPicker> createState() => _BeadColorPickerState();
}

class _BeadColorPickerState extends State<BeadColorPicker> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isExpanded)
          ...BeadType.values.where((e) => e != widget.currentType).map((type) {
            return Padding(
              padding: EdgeInsets.only(bottom: context.insets.sm),
              child: _BeadOption(
                type: type,
                onTap: () {
                  widget.onSelected(type);
                  setState(() => _isExpanded = false);
                },
              ),
            );
          }),
        _BeadOption(
          type: widget.currentType,
          isMain: true,
          onTap: () => setState(() => _isExpanded = !_isExpanded),
        ),
      ],
    );
  }
}

class _BeadOption extends StatelessWidget {
  final BeadType type;
  final VoidCallback onTap;
  final bool isMain;

  const _BeadOption({
    required this.type,
    required this.onTap,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = 46.r;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ring that marks the bead in use.
            if (isMain)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.secondary.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                ),
              ),
            // The same bead as on the string.
            CustomPaint(
              size: Size.square(size - 10.r),
              painter: _BeadPreviewPainter(type),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeadPreviewPainter extends CustomPainter {
  _BeadPreviewPainter(this.type);

  final BeadType type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    BeadRenderer.paint(canvas, center: center, radius: radius, type: type);
  }

  @override
  bool shouldRepaint(covariant _BeadPreviewPainter old) => old.type != type;
}
