import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'story_paragraph.dart';
import 'story_verse_block.dart';

/// A story told as a narrative: '## ' lines are chapter headings, '@@ ' lines
/// are blocks of Quranic verses ('@@ reference | text'), the other lines are
/// the story's own paragraphs.
class StoryNarrative extends StatelessWidget {
  const StoryNarrative({super.key, required this.lines, required this.fontSize});

  final List<String> lines;
  final double fontSize;

  static const String _headingMark = '## ';
  static const String _verseMark = '@@ ';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          if (line.startsWith(_headingMark))
            _Heading(title: line.substring(_headingMark.length))
          else if (line.startsWith(_verseMark))
            Padding(
              padding: EdgeInsets.only(bottom: context.insets.md),
              child: _verseBlock(line.substring(_verseMark.length)),
            )
          else
            Padding(
              padding: EdgeInsets.only(bottom: context.insets.md),
              child: StoryParagraph(text: line, fontSize: fontSize),
            ),
      ],
    );
  }
}

extension on StoryNarrative {
  Widget _verseBlock(String body) {
    final split = body.indexOf(' | ');
    final reference = split < 0 ? '' : body.substring(0, split);
    final text = split < 0 ? body : body.substring(split + 3);
    return StoryVerseBlock(
      text: text,
      reference: reference,
      fontSize: fontSize,
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(
        top: context.insets.md,
        bottom: context.insets.md,
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: colors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: context.insets.sm),
          Expanded(
            child: Text(
              title,
              style: context.textStyles.titleLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
