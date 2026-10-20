import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/thikr_card.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import '../data/umrah_intro_data.dart';
import '../providers/umrah_text.dart';
import '../widgets/umrah_disclaimer.dart';
import '../widgets/umrah_font_actions.dart';
import '../widgets/umrah_pillar_tile.dart';
import '../widgets/umrah_section_title.dart';
import '../widgets/umrah_text_card.dart';

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
          UmrahTextCard(UmrahIntroData.meaning),
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
            UmrahPillarTile(pillar: pillar),
          Text(
            UmrahIntroData.pillarsNote,
            style: text.small(context, color: colors.textSecondary),
          ),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('متى تؤدّى وكم تستغرق؟'),
          SizedBox(height: context.insets.md),
          UmrahTextCard(UmrahIntroData.timing),
          SizedBox(height: context.insets.lg),
          const UmrahDisclaimer(),
        ],
      ),
    );
  }
}
