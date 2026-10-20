import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import '../data/umrah_intro_data.dart';
import '../models/umrah_models.dart';
import '../providers/umrah_text.dart';
import '../widgets/umrah_disclaimer.dart';
import '../widgets/umrah_font_actions.dart';

/// Mistakes many pilgrims make, each with the correct way next to it.
@RoutePage()
class UmrahMistakesScreen extends ConsumerWidget {
  const UmrahMistakesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);

    return AppScaffold(
      appBar: BaseAppBar(
        title: 'الأخطاء الشائعة',
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
          Text(
            'معرفة هذه الأخطاء قبل السفر تُجنّبك الوقوع فيها.',
            style: text.body(context, color: context.colors.textSecondary),
          ),
          SizedBox(height: context.insets.md),
          for (final mistake in UmrahIntroData.mistakes)
            _MistakeCard(mistake: mistake),
          SizedBox(height: context.insets.sm),
          const UmrahDisclaimer(),
        ],
      ),
    );
  }
}

class _MistakeCard extends ConsumerWidget {
  const _MistakeCard({required this.mistake});

  final UmrahMistake mistake;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.only(bottom: context.insets.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.12)),
        boxShadow: context.shadows.low,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _Row(
            icon: HugeIcons.strokeRoundedCancel01,
            label: 'الخطأ',
            body: mistake.wrong,
            color: colors.error,
            text: text,
          ),
          _Row(
            icon: HugeIcons.strokeRoundedTick02,
            label: 'الصواب',
            body: mistake.right,
            color: colors.success,
            text: text,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.body,
    required this.color,
    required this.text,
  });

  final AppIconData icon;
  final String label;
  final String body;
  final Color color;
  final UmrahTextStyles text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.07),
      padding: EdgeInsets.all(context.insets.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Center(
              child: AppIcon(icon, size: 17.w, color: Colors.white),
            ),
          ),
          SizedBox(width: context.insets.sm + 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text
                      .small(context, color: color)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(body, style: text.body(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
