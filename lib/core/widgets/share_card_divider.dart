import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Thin ornamental divider (line - diamond - line) used on shared images.
class ShareCardDivider extends StatelessWidget {
  const ShareCardDivider({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget line() =>
        Container(width: 46, height: 1, color: color.withValues(alpha: 0.6));

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        line(),
        const SizedBox(width: 8),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(width: 7, height: 7, color: color),
        ),
        const SizedBox(width: 8),
        line(),
      ],
    );
  }
}
