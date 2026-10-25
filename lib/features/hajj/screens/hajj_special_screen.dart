import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/umrah/providers/umrah_text.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_disclaimer.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_font_actions.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_numbered_list.dart';
import '../data/hajj_special_data.dart';
import '../models/hajj_models.dart';

/// Special cases: women, the sick and the elderly, the sacrifice and the
/// penalties. Each topic opens to read its points.
@RoutePage()
class HajjSpecialScreen extends ConsumerWidget {
  const HajjSpecialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: BaseAppBar(
        title: 'أحكام خاصة والفدية',
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
          for (final topic in HajjSpecialData.topics) _TopicCard(topic: topic),
          SizedBox(height: context.insets.sm),
          const UmrahDisclaimer(text: HajjSpecialData.askScholarsNote),
        ],
      ),
    );
  }
}

class _TopicCard extends ConsumerWidget {
  const _TopicCard({required this.topic});

  final HajjSpecialTopic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.only(bottom: context.insets.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
        boxShadow: context.shadows.low,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: context.insets.md,
            vertical: 4.h,
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            context.insets.md,
            0,
            context.insets.md,
            context.insets.md,
          ),
          shape: const Border(),
          collapsedShape: const Border(),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withValues(alpha: 0.12),
            ),
            child: Center(
              child: AppIcon(topic.icon, size: 24.w, color: colors.primary),
            ),
          ),
          title: Text(topic.title, style: text.title(context)),
          children: [
            UmrahNumberedList(items: topic.points),
            SizedBox(height: context.insets.sm),
            Text(
              'المصدر: ${topic.source}',
              style: text.small(context, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
