import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// A collapsible block: the closed state is a tappable bar with [title], the
/// open state shows [child] below it.
class StoryDetailExpander extends StatefulWidget {
  const StoryDetailExpander({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  State<StoryDetailExpander> createState() => _StoryDetailExpanderState();
}

class _StoryDetailExpanderState extends State<StoryDetailExpander> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: colors.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(context.corners.xl),
          child: InkWell(
            borderRadius: BorderRadius.circular(context.corners.xl),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: EdgeInsets.all(context.insets.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: context.textStyles.titleLarge?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: context.textStyles.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: AppIcon(
                      HugeIcons.strokeRoundedArrowDown01,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _open
              ? Padding(
                  padding: EdgeInsets.only(top: context.insets.md),
                  child: widget.child,
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
