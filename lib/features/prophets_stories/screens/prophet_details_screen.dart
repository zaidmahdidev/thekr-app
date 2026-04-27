import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/tokens/typography.dart';
import '../models/prophet_story.dart';
import '../widgets/prophet_details_header.dart';
import '../widgets/prophet_lesson_item.dart';
import '../widgets/prophet_section_header.dart';
import '../widgets/prophet_verse_card.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/services/share_service.dart';

@RoutePage()
class ProphetDetailsScreen extends StatelessWidget {
  final ProphetStory prophet;

  const ProphetDetailsScreen({super.key, required this.prophet});

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    showToast(text: message,backgroundColor: context.colors.background);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          // Modular Header
          ProphetDetailsHeader(
            prophet: prophet,
            onCopyAll: () => _copyToClipboard(
              context,
              '${prophet.name}\n${prophet.title}\n\n${prophet.fullStory}',
              'تم نسخ القصة بالكامل',
            ),
            onShare: () => ShareService.showShareSheet(
              context,
              content: prophet.name,
              subtitle: '${prophet.title}\n\n${prophet.fullStory}',
            ),
          ),

          // Content
          SliverPadding(
            padding: EdgeInsets.all(context.insets.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title and Brief
                ProphetSectionTitle(title: prophet.title, isHero: true),
                Text(
                  prophet.brief,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: context.insets.lg),

                const ProphetSectionHeader(title: 'القصة'),
                Text(
                  prophet.fullStory,
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.colors.textPrimary,
                    fontSize: 16.sp,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: context.insets.lg),

                // Quranic Verses Section
                if (prophet.quranVerses.isNotEmpty) ...[
                  const ProphetSectionHeader(title: 'آيات من القرآن الكريم'),
                  ...prophet.quranVerses.map(
                    (verse) => ProphetVerseCard(
                      verse: verse,
                      onCopy: () => _copyToClipboard(
                        context,
                        verse,
                        'تم نسخ الآية الكريمة',
                      ),
                    ),
                  ),
                  SizedBox(height: context.insets.md),
                ],

                // Lessons Section
                if (prophet.lessons.isNotEmpty) ...[
                  const ProphetSectionHeader(title: 'الدروس والعبَر'),
                  Column(
                    children: prophet.lessons
                        .map((lesson) => ProphetLessonItem(lesson: lesson))
                        .toList(),
                  ),
                ],

                SizedBox(height: 40.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
