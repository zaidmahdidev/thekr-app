import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/thikr_card.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/umrah/providers/umrah_text.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_disclaimer.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_font_actions.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_notes_card.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_pillar_tile.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_section_title.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_text_card.dart';
import '../data/hajj_intro_data.dart';

/// What Hajj is, its ruling and conditions, its virtue, and what it is made of.
@RoutePage()
class HajjIntroScreen extends ConsumerWidget {
  const HajjIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;

    Widget verse(String body, String source) => ThikrCard(
      text: body,
      footnote: source,
      actions: ThikrAction.copyAndShare(
        context,
        ref,
        text: body,
        footnote: source,
      ),
    );

    return AppScaffold(
      appBar: BaseAppBar(
        title: 'تعرّف على الحج',
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
          const UmrahSectionTitle('ما هو الحج؟'),
          SizedBox(height: context.insets.md),
          const UmrahTextCard(HajjIntroData.meaning),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('حكمه وشروطه'),
          SizedBox(height: context.insets.md),
          const UmrahTextCard(HajjIntroData.ruling),
          verse(HajjIntroData.ruleVerse.text, HajjIntroData.ruleVerse.source),
          SizedBox(height: context.insets.sm),
          const UmrahNotesCard(notes: HajjIntroData.conditions),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('زمن الحج'),
          SizedBox(height: context.insets.md),
          const UmrahTextCard(HajjIntroData.timing),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('فضل الحج'),
          SizedBox(height: context.insets.sm),
          for (final virtue in HajjIntroData.virtues)
            verse(virtue.text, virtue.source),
          verse(
            HajjIntroData.noObscenityVerse.text,
            HajjIntroData.noObscenityVerse.source,
          ),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('أركان الحج وواجباته'),
          SizedBox(height: context.insets.md),
          for (final pillar in HajjIntroData.pillars)
            UmrahPillarTile(pillar: pillar),
          Text(
            HajjIntroData.pillarsNote,
            style: text.small(context, color: colors.textSecondary),
          ),
          SizedBox(height: context.insets.lg),
          const UmrahDisclaimer(),
        ],
      ),
    );
  }
}
