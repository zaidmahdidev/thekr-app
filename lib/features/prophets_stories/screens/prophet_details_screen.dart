import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../models/prophet_story.dart';
import '../widgets/prophet_details_header.dart';
import '../widgets/prophet_lesson_item.dart';
import '../widgets/prophet_neighbors_bar.dart';
import '../widgets/prophet_section_header.dart';
import '../widgets/story_paragraph.dart';
import '../widgets/story_source_card.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/services/share_service.dart';
import '../../settings/providers/settings_provider.dart';

@RoutePage()
class ProphetDetailsScreen extends ConsumerStatefulWidget {
  final ProphetStory prophet;

  const ProphetDetailsScreen({super.key, required this.prophet});

  @override
  ConsumerState<ProphetDetailsScreen> createState() =>
      _ProphetDetailsScreenState();
}

class _ProphetDetailsScreenState extends ConsumerState<ProphetDetailsScreen> {
  // The offset is not kept between stories: opening the next or the previous
  // prophet must always start from the beginning of the story.
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );

  ProphetStory get prophet => widget.prophet;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    showToast(text: message);
  }

  /// Text copied with the story, always carrying its source.
  String _copyText() {
    final buffer = StringBuffer('${prophet.name}\n${prophet.title}\n\n')
      ..write(prophet.plainText);
    final source = prophet.source;
    if (source != null) {
      buffer.write('\n\nالمصدر: ${source.book} - ${source.author}');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = ref.watch(settingsProvider).fontSize;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Scrollbar(
        controller: _scrollController,
        interactive: true,
        thickness: 4.w,
        radius: Radius.circular(context.corners.sm),
        child: CustomScrollView(
          key: ValueKey(prophet.id),
          controller: _scrollController,
          slivers: [
            ProphetDetailsHeader(
              prophet: prophet,
              onCopyAll: () =>
                  _copyToClipboard(_copyText(), 'تم نسخ القصة بالكامل'),
              onShare: () => ShareService.showShareSheet(
                context,
                ref,
                content: prophet.name,
                subtitle: '${prophet.title}\n\n${prophet.brief}',
                showSubtitleInImage: true,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(context.insets.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: EdgeInsets.all(context.insets.md),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(context.corners.lg),
                      boxShadow: context.shadows.low,
                    ),
                    child: Text(
                      prophet.brief,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: context.colors.textSecondary,
                        height: 1.7,
                        fontSize: fontSize - 2,
                      ),
                    ),
                  ),
                  SizedBox(height: context.insets.lg),
                  const ProphetSectionHeader(title: 'القصة'),
                  if (prophet.isDocumented)
                    ...prophet.paragraphs.map(
                      (text) => Padding(
                        padding: EdgeInsets.only(bottom: context.insets.md),
                        child: StoryParagraph(
                          text: text,
                          fontSize: fontSize,
                        ),
                      ),
                    )
                  else
                    Text(
                      prophet.fullStory,
                      style: context.textStyles.bodyLarge?.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: fontSize,
                        height: 1.6,
                      ),
                    ),
                  SizedBox(height: context.insets.md),
                  StorySourceCard(source: prophet.source),
                  SizedBox(height: context.insets.lg),
                  if (prophet.lessons.isNotEmpty) ...[
                    const ProphetSectionHeader(title: 'الدروس والعبَر'),
                    Padding(
                      padding: EdgeInsets.only(bottom: context.insets.sm),
                      child: Text(
                        'دروس مستخلصة من نص القصة أعلاه',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                    Column(
                      children: prophet.lessons
                          .map(
                            (lesson) => ProphetLessonItem(
                              lesson: lesson,
                              fontSize: fontSize - 2,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  SizedBox(height: context.insets.lg),
                  ProphetNeighborsBar(prophet: prophet),
                  SizedBox(height: 40.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
