import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

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

class _MyCardState extends State<MyCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.insets.sm / 2,
        horizontal: context.insets.sm,
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.insets.md,
              vertical: context.insets.md,
            ),
            decoration: BoxDecoration(
              color: widget.isHighlighted
                  ? context.colors.primary.withValues(alpha: isDark ? 0.3 : 0.1)
                  : context.colors.surface,
              borderRadius: BorderRadius.circular(context.corners.lg),
              border: Border.all(
                color: widget.isHighlighted
                    ? context.colors.primary
                    : context.colors.primary.withValues(alpha: 0.1),
                width: widget.isHighlighted ? 1.5 : 1,
              ),
              boxShadow: widget.isHighlighted ? context.shadows.medium : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
