import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/utils/quran_text.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/thikr_card.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import '../data/umrah_steps_data.dart';
import '../models/umrah_models.dart';
import '../providers/umrah_text.dart';
import '../widgets/illustrations/ihram_illustration.dart';
import '../widgets/illustrations/sai_illustration.dart';
import '../widgets/illustrations/tawaf_illustration.dart';
import '../widgets/umrah_disclaimer.dart';
import '../widgets/umrah_font_actions.dart';
import '../widgets/umrah_notes_card.dart';
import '../widgets/umrah_numbered_list.dart';
import '../widgets/umrah_section_title.dart';

/// One rite of Umrah written as a lesson: what it is, how it is done, the duas
/// to say and the points to watch. Previous / next buttons move along the
/// lessons in order.
@RoutePage()
class UmrahStepScreen extends ConsumerWidget {
  const UmrahStepScreen({super.key, required this.stepNumber});

  final int stepNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = UmrahStepsData.all;
    final step = steps.firstWhere((s) => s.number == stepNumber);
    final previous = step.number > 1 ? steps[step.number - 2] : null;
    final next = step.number < steps.length ? steps[step.number] : null;

    void goTo(UmrahStep target) =>
        context.router.replace(UmrahStepRoute(stepNumber: target.number));

    return AppScaffold(
      appBar: BaseAppBar(title: step.title, actions: umrahFontActions(ref)),
      bottomNavigationBar: _LessonNav(
        previous: previous,
        next: next,
        onPrevious: previous == null ? null : () => goTo(previous),
        onNext: next == null ? null : () => goTo(next),
        onFinish: () => context.router.maybePop(),
      ),
      body: ListView(
        // A new key per lesson, so moving to the next one starts at the top
        // instead of keeping the scroll position of the previous lesson.
        key: ValueKey(step.number),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(context.insets.md),
        children: [
          _Header(step: step),
          if (step.illustration != null) ...[
            SizedBox(height: context.insets.lg),
            switch (step.illustration!) {
              UmrahIllustrationKind.ihram => const IhramIllustration(),
              UmrahIllustrationKind.tawaf => const TawafIllustration(),
              UmrahIllustrationKind.sai => const SaiIllustration(),
            },
          ],
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('كيف تؤديها'),
          SizedBox(height: context.insets.md),
          UmrahNumberedList(items: step.how),
          if (step.duas.isNotEmpty) ...[
            SizedBox(height: context.insets.lg),
            const UmrahSectionTitle('الأدعية والأذكار'),
            SizedBox(height: context.insets.sm),
            for (final dua in step.duas) _DuaBlock(dua: dua),
          ],
          if (step.notes.isNotEmpty) ...[
            SizedBox(height: context.insets.lg),
            const UmrahSectionTitle('تنبيهات'),
            SizedBox(height: context.insets.md),
            UmrahNotesCard(notes: step.notes),
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
  const _Header({required this.step});

  final UmrahStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;
    final steps = UmrahStepsData.all;

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
              child: AppIcon(step.icon, size: 32.w, color: colors.primary),
            ),
          ),
          SizedBox(width: context.insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المنسك ${QuranText.digits(step.number)} من ${QuranText.digits(steps.length)}',
                  style: text.small(context, color: colors.textSecondary),
                ),
                Text(
                  step.summary,
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

class _DuaBlock extends ConsumerWidget {
  const _DuaBlock({required this.dua});

  final UmrahDua dua;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: context.insets.sm,
            right: context.insets.sm,
            left: context.insets.sm,
          ),
          child: Text(
            dua.title,
            style: text.title(context, color: context.colors.primary),
          ),
        ),
        ThikrCard(
          text: dua.text,
          footnote: dua.source,
          actions: ThikrAction.copyAndShare(
            context,
            ref,
            text: dua.text,
            footnote: dua.source,
          ),
        ),
      ],
    );
  }
}

/// Previous and next lesson, with their names so the reader knows where each
/// button leads.
class _LessonNav extends StatelessWidget {
  const _LessonNav({
    required this.previous,
    required this.next,
    required this.onPrevious,
    required this.onNext,
    required this.onFinish,
  });

  final UmrahStep? previous;
  final UmrahStep? next;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.corners.xl),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.insets.md,
        context.insets.sm + 2.w,
        context.insets.md,
        context.insets.sm + 2.w + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: context.shadows.medium,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.corners.xl),
        ),
      ),
      child: Row(
        children: [
          if (previous != null) ...[
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(
                      color: colors.textSecondary.withValues(alpha: 0.35),
                    ),
                    shape: shape,
                  ),
                  child: const Text('السابق'),
                ),
              ),
            ),
            SizedBox(width: context.insets.sm + 2.w),
          ],
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52.h,
              child: FilledButton.icon(
                onPressed: next == null ? onFinish : onNext,
                icon: AppIcon(
                  next == null
                      ? HugeIcons.strokeRoundedCheckmarkCircle02
                      : HugeIcons.strokeRoundedArrowRight01,
                ),
                iconAlignment: IconAlignment.end,
                label: Text(
                  next == null ? 'انتهيت من الدليل' : 'التالي: ${next!.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: shape,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
