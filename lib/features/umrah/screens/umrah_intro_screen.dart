import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/thikr_card.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import '../data/umrah_intro_data.dart';
import '../models/umrah_models.dart';
import '../providers/umrah_text.dart';
import '../widgets/umrah_disclaimer.dart';
import '../widgets/umrah_font_actions.dart';
import '../widgets/umrah_section_title.dart';

/// What Umrah is, why it matters and what it is made of.
@RoutePage()
class UmrahIntroScreen extends ConsumerWidget {
  const UmrahIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;

    return AppScaffold(
      appBar: BaseAppBar(
        title: 'تعرّف على العمرة',
        actions: umrahFontActions(ref),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.insets.md,
          context.insets.sm,
          context.insets.md,
          context.insets.lg + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          const UmrahSectionTitle('ما هي العمرة؟'),
          SizedBox(height: context.insets.md),
          _TextCard(UmrahIntroData.meaning),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('فضل العمرة'),
          SizedBox(height: context.insets.sm),
          for (final virtue in UmrahIntroData.virtues)
            ThikrCard(
              text: virtue.text,
              footnote: virtue.source,
              actions: ThikrAction.copyAndShare(
                context,
                ref,
                text: virtue.text,
                footnote: virtue.source,
              ),
            ),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('مما تتكوّن العمرة'),
          SizedBox(height: context.insets.md),
          for (final pillar in UmrahIntroData.pillars)
            _PillarTile(pillar: pillar),
          Text(
            UmrahIntroData.pillarsNote,
            style: text.small(context, color: colors.textSecondary),
          ),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('متى تؤدّى وكم تستغرق؟'),
          SizedBox(height: context.insets.md),
          _TextCard(UmrahIntroData.timing),
          SizedBox(height: context.insets.lg),
          const UmrahDisclaimer(),
        ],
      ),
    );
  }
}

class _TextCard extends ConsumerWidget {
  const _TextCard(this.text);

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = ref.watch(umrahTextProvider);
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.12)),
        boxShadow: context.shadows.low,
      ),
      child: Text(text, style: styles.body(context)),
    );
  }
}

class _PillarTile extends ConsumerWidget {
  const _PillarTile({required this.pillar});

  final UmrahPillar pillar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;
    final isPillar = pillar.kind == 'ركن';
    final accent = isPillar ? colors.primary : colors.secondary;

    return Container(
      margin: EdgeInsets.only(bottom: context.insets.sm + 2.w),
      padding: EdgeInsets.all(context.insets.sm + 4.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
        boxShadow: context.shadows.low,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.12),
            ),
            child: Center(
              child: AppIcon(pillar.icon, size: 24.w, color: accent),
            ),
          ),
          SizedBox(width: context.insets.sm + 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: context.insets.sm,
                  children: [
                    Text(pillar.title, style: text.title(context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(context.corners.xl),
                      ),
                      child: Text(
                        pillar.kind,
                        style: text
                            .small(context, color: accent)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Text(pillar.meaning, style: text.body(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
