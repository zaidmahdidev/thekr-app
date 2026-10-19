import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

/// One paragraph of a documented story. Text between « » is Quranic and is
/// highlighted, written between ﴿ ﴾.
class StoryParagraph extends StatelessWidget {
  const StoryParagraph({super.key, required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  static final RegExp _quote = RegExp(r'«([^»]*)»');

  @override
  Widget build(BuildContext context) {
    final base = context.textStyles.bodyLarge!.copyWith(
      color: context.colors.textPrimary,
      fontSize: fontSize,
      height: 1.95,
    );
    final quoted = base.copyWith(
      color: context.colors.primary,
      fontWeight: FontWeight.w700,
      backgroundColor: context.colors.primary.withValues(alpha: 0.07),
    );
    final mark = base.copyWith(
      color: context.colors.secondary,
      fontWeight: FontWeight.bold,
    );

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _quote.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans
        ..add(TextSpan(text: '﴿', style: mark))
        ..add(TextSpan(text: match.group(1), style: quoted))
        ..add(TextSpan(text: '﴾', style: mark));
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));

    return Text.rich(
      TextSpan(style: base, children: spans),
      textAlign: TextAlign.justify,
    );
  }
}
