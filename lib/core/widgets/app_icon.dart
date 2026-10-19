import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Icon data of the app: a Hugeicons glyph.
typedef AppIconData = List<List<dynamic>>;

/// The only widget the app uses to draw icons.
///
/// It reads color and size from the surrounding [IconTheme] like [Icon] does,
/// and flips the directional arrows in right-to-left layouts.
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.color, this.size, this.strokeWidth});

  final AppIconData icon;
  final Color? color;
  final double? size;
  final double? strokeWidth;

  static const double glyphScale = 0.8;

  static const List<AppIconData> _directional = [
    HugeIcons.strokeRoundedArrowLeft01,
    HugeIcons.strokeRoundedArrowRight01,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final box = size ?? theme.size ?? 24;
    // A Hugeicons glyph fills its whole box, while a Material glyph leaves about
    // a fifth of it empty. Drawing it smaller keeps the same look and layout.
    Widget result = SizedBox(
      width: box,
      height: box,
      child: Center(
        child: HugeIcon(
          icon: icon,
          color: color ?? theme.color,
          size: box * glyphScale,
          strokeWidth: strokeWidth,
        ),
      ),
    );

    final mirrors = _directional.any((d) => identical(d, icon));
    if (mirrors && Directionality.of(context) == TextDirection.rtl) {
      result = Transform.flip(flipX: true, child: result);
    }
    return result;
  }
}
