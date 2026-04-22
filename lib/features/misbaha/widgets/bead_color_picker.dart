import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import '../models/misbaha_models.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: type.colors,
            center: const Alignment(-0.3, -0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
            if (isMain)
              BoxShadow(
                color: type.colors.first.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        // child: isMain && type == BeadType.wood
        //     ? Icon(Icons.palette_rounded, color: Colors.red, size: 20.r)
        //     : null,
      ),
    );
  }
}
