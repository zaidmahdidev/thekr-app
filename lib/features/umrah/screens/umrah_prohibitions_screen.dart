import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import '../data/umrah_prohibitions_data.dart';
import '../models/umrah_models.dart';
import '../providers/umrah_text.dart';
import '../widgets/umrah_disclaimer.dart';
import '../widgets/umrah_font_actions.dart';
import '../widgets/umrah_section_title.dart';

/// What the pilgrim must avoid from the moment of ihram, grouped by who it
/// applies to, followed by the common things that are still allowed.
@RoutePage()
class UmrahProhibitionsScreen extends ConsumerWidget {
  const UmrahProhibitionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: BaseAppBar(
        title: 'محظورات الإحرام',
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
          for (final group in ProhibitionGroup.values) ...[
            UmrahSectionTitle(group.label),
            SizedBox(height: context.insets.md),
            for (final item in UmrahProhibitionsData.all.where(
              (p) => p.group == group,
            ))
              _ProhibitionTile(item: item),
            SizedBox(height: context.insets.sm),
          ],
          SizedBox(height: context.insets.sm),
          const UmrahSectionTitle('ما يجوز للمحرم'),
          SizedBox(height: context.insets.md),
          const _AllowedCard(),
          SizedBox(height: context.insets.lg),
          const UmrahDisclaimer(text: UmrahProhibitionsData.penaltyNote),
        ],
      ),
    );
  }
}

class _ProhibitionTile extends ConsumerWidget {
  const _ProhibitionTile({required this.item});

  final Prohibition item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final color = context.colors.error;
    return Container(
      margin: EdgeInsets.only(bottom: context.insets.sm + 2.w),
      padding: EdgeInsets.all(context.insets.sm + 4.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: context.shadows.low,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Center(child: AppIcon(item.icon, size: 22.w, color: color)),
          ),
          SizedBox(width: context.insets.sm + 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: text.title(context)),
                SizedBox(height: 2.h),
                Text(
                  item.detail,
                  style: text.body(
                    context,
                    color: context.colors.textPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllowedCard extends ConsumerWidget {
  const _AllowedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final color = context.colors.success;
    return Container(
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          for (final (index, line) in UmrahProhibitionsData.allowed.indexed)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == UmrahProhibitionsData.allowed.length - 1
                    ? 0
                    : context.insets.sm + 2.w,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: AppIcon(
                      HugeIcons.strokeRoundedCheckmarkCircle02,
                      size: 20.w,
                      color: color,
                    ),
                  ),
                  SizedBox(width: context.insets.sm),
                  Expanded(child: Text(line, style: text.body(context))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
