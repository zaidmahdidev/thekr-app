import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/umrah/providers/umrah_text.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_disclaimer.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_font_actions.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_numbered_list.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_segmented_control.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_text_card.dart';
import '../data/hajj_types_data.dart';
import '../models/hajj_models.dart';

/// The three ways of performing Hajj. Pick one at the top to read how it is
/// done, what it says at ihram, whether a sacrifice is owed and when it ends.
@RoutePage()
class HajjTypesScreen extends ConsumerStatefulWidget {
  const HajjTypesScreen({super.key});

  @override
  ConsumerState<HajjTypesScreen> createState() => _HajjTypesScreenState();
}

class _HajjTypesScreenState extends ConsumerState<HajjTypesScreen> {
  HajjType _selected = HajjTypesData.all.first;

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;
    final type = _selected;

    return AppScaffold(
      appBar: BaseAppBar(title: 'أنواع الحج', actions: umrahFontActions(ref)),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.insets.md,
          context.insets.sm,
          context.insets.md,
          context.insets.lg + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          const UmrahTextCard(HajjTypesData.intro),
          SizedBox(height: context.insets.md),
          UmrahSegmentedControl<HajjType>(
            values: HajjTypesData.all,
            selected: type,
            labelOf: (t) => t.title,
            onChanged: (value) => setState(() => _selected = value),
          ),
          SizedBox(height: context.insets.lg),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Column(
              key: ValueKey(type.title),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeHeader(type: type),
                SizedBox(height: context.insets.md),
                Text('كيف تؤديه', style: text.title(context, color: colors.primary)),
                SizedBox(height: context.insets.sm),
                UmrahNumberedList(items: type.how),
                SizedBox(height: context.insets.md),
                _Fact(
                  icon: HugeIcons.strokeRoundedCoins01,
                  label: 'الهدي',
                  value: type.hady,
                ),
                SizedBox(height: context.insets.sm),
                _Fact(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  label: 'التحلل',
                  value: type.exitsIhram,
                ),
              ],
            ),
          ),
          SizedBox(height: context.insets.lg),
          UmrahTextCard(HajjTypesData.bestNote),
          SizedBox(height: context.insets.lg),
          const UmrahDisclaimer(),
        ],
      ),
    );
  }
}

class _TypeHeader extends ConsumerWidget {
  const _TypeHeader({required this.type});

  final HajjType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;
    final accent = type.isBest ? colors.secondary : colors.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.insets.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.corners.xl),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.16),
            ),
            child: Center(child: AppIcon(type.icon, size: 26.w, color: accent)),
          ),
          SizedBox(width: context.insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: context.insets.sm,
                  children: [
                    Text(type.title, style: text.title(context, color: accent)),
                    if (type.isBest) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(
                            context.corners.xl,
                          ),
                        ),
                        child: Text(
                          'الأفضل',
                          style: text
                              .small(context, color: accent)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'تقول عند الإحرام: ${type.talbiyah}',
                  style: text.small(context, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends ConsumerWidget {
  const _Fact({required this.icon, required this.label, required this.value});

  final AppIconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: AppIcon(icon, size: 22.w, color: colors.primary),
          ),
          SizedBox(width: context.insets.sm + 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.title(context)),
                Text(value, style: text.body(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
