import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/umrah/providers/umrah_text.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_disclaimer.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_dua_block.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_font_actions.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_lesson_nav.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_notes_card.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_numbered_list.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_section_title.dart';
import '../data/hajj_days_data.dart';
import '../models/hajj_models.dart';
import '../widgets/illustrations/day_sequence_illustration.dart';
import '../widgets/illustrations/jamarat_illustration.dart';
import '../widgets/illustrations/mashaar_illustration.dart';
import 'package:thekr_app/core/utils/app_digits.dart';

/// One stage of Hajj written as a lesson: what to do, in order, the duas and the
/// points to watch. Previous / next buttons move along the stages.
@RoutePage()
class HajjDayScreen extends ConsumerWidget {
  const HajjDayScreen({super.key, required this.dayNumber});

  final int dayNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = HajjDaysData.all;
    final day = days.firstWhere((d) => d.number == dayNumber);
    final previous = day.number > 1 ? days[day.number - 2] : null;
    final next = day.number < days.length ? days[day.number] : null;

    void goTo(HajjDay target) =>
        context.router.replace(HajjDayRoute(dayNumber: target.number));

    return AppScaffold(
      appBar: BaseAppBar(title: day.title, actions: umrahFontActions(ref)),
      bottomNavigationBar: UmrahLessonNav(
        hasPrevious: previous != null,
        nextTitle: next?.title,
        onPrevious: previous == null ? null : () => goTo(previous),
        onNext: next == null ? null : () => goTo(next),
        onFinish: () => context.router.maybePop(),
      ),
      body: ListView(
        // A new key per lesson, so moving to the next one starts at the top.
        key: ValueKey(day.number),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(context.insets.md),
        children: [
          _Header(day: day),
          if (day.illustration != null) ...[
            SizedBox(height: context.insets.lg),
            switch (day.illustration!) {
              HajjIllustrationKind.mashaar => const MashaarIllustration(),
              HajjIllustrationKind.daySequence =>
                const DaySequenceIllustration(),
              HajjIllustrationKind.jamarat => const JamaratIllustration(),
            },
          ],
          for (final rite in day.rites) ...[
            SizedBox(height: context.insets.lg),
            UmrahSectionTitle(rite.title),
            SizedBox(height: context.insets.md),
            UmrahNumberedList(items: rite.steps),
          ],
          if (day.duas.isNotEmpty) ...[
            SizedBox(height: context.insets.lg),
            const UmrahSectionTitle('الأدعية والأذكار'),
            SizedBox(height: context.insets.sm),
            for (final dua in day.duas) UmrahDuaBlock(dua: dua),
          ],
          if (day.notes.isNotEmpty) ...[
            SizedBox(height: context.insets.lg),
            const UmrahSectionTitle('تنبيهات'),
            SizedBox(height: context.insets.md),
            UmrahNotesCard(notes: day.notes),
          ],
          SizedBox(height: context.insets.lg),
          const UmrahDisclaimer(),
          SizedBox(height: context.insets.md),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.day});

  final HajjDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.14),
            ),
            child: Center(
              child: AppIcon(day.icon, size: 32.w, color: colors.primary),
            ),
          ),
          SizedBox(width: context.insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${day.dayLabel} · المرحلة ${AppDigits.of(day.number)} من ${AppDigits.of(HajjDaysData.all.length)}',
                  style: text.small(context, color: colors.textSecondary),
                ),
                Text(
                  day.summary,
                  style: text.title(context, color: colors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
