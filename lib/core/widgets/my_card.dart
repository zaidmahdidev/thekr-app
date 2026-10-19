import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

/// The app's list card: soft gradient surface, hairline border and a gentle
/// press animation. [isHighlighted] gives it the primary tint and border.
class MyCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const MyCard({
    Key? key,
    required this.child,
    this.onTap,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final highlighted = widget.isHighlighted;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.insets.sm / 2,
        horizontal: context.insets.sm,
      ),
      child: GestureDetector(
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.insets.md,
              vertical: context.insets.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.corners.xl),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  highlighted
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.surface,
                  highlighted
                      ? colors.primary.withValues(alpha: 0.06)
                      : Color.alphaBlend(
                          colors.primary.withValues(alpha: 0.035),
                          colors.surface,
                        ),
                ],
              ),
              border: Border.all(
                color: highlighted
                    ? colors.primary
                    : colors.primary.withValues(alpha: 0.1),
                width: highlighted ? 1.5 : 1,
              ),
              boxShadow: highlighted
                  ? context.shadows.medium
                  : context.shadows.low,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
