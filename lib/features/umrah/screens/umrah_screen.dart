import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import '../data/umrah_summary.dart';
import '../providers/umrah_text.dart';
import '../widgets/umrah_disclaimer.dart';
import '../widgets/umrah_font_actions.dart';
import '../widgets/umrah_hero.dart';
import '../widgets/umrah_menu_tile.dart';
import '../widgets/umrah_overview_strip.dart';
import '../widgets/umrah_section_title.dart';

/// Home of the Umrah guide. A reference to read before the trip: the six rites
/// at a glance, then the sections that explain the rest.
@RoutePage()
class UmrahScreen extends ConsumerWidget {
  const UmrahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = ref.watch(umrahTextProvider);

    return AppScaffold(
      appBar: BaseAppBar(title: 'دليل المعتمر', actions: umrahFontActions(ref)),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.insets.md,
          context.insets.sm,
          context.insets.md,
          context.insets.lg + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          const UmrahHero(),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('العمرة في نظرة'),
          SizedBox(height: context.insets.sm),
          Text(
            'هذه مناسك العمرة بالترتيب. اضغط على أي منسك لتقرأ شرحه.',
            style: text.small(context, color: colors.textSecondary),
          ),
          SizedBox(height: context.insets.md),
          UmrahOverviewStrip(
            onOpen: (step) =>
                context.router.push(UmrahStepRoute(stepNumber: step.number)),
          ),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('تعرّف أكثر'),
          SizedBox(height: context.insets.md),
          UmrahMenuTile(
            icon: HugeIcons.strokeRoundedBook02,
            title: 'تعرّف على العمرة',
            subtitle: 'معناها وفضلها وأركانها',
            color: colors.primary,
            onTap: () => context.router.push(const UmrahIntroRoute()),
          ),
          UmrahMenuTile(
            icon: HugeIcons.strokeRoundedLocation01,
            title: 'من أين أحرم؟',
            subtitle: 'الميقات المناسب لجهة قدومك',
            color: colors.primary,
            onTap: () => context.router.push(const UmrahMiqatRoute()),
          ),
          UmrahMenuTile(
            icon: HugeIcons.strokeRoundedAlert02,
            title: 'محظورات الإحرام',
            subtitle: 'ما يُمنع على المحرم وما يجوز له',
            color: colors.error,
            onTap: () => context.router.push(const UmrahProhibitionsRoute()),
          ),
          UmrahMenuTile(
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            title: 'الأخطاء الشائعة',
            subtitle: 'أخطاء يقع فيها كثيرون وصوابها',
            color: colors.success,
            onTap: () => context.router.push(const UmrahMistakesRoute()),
          ),
          UmrahMenuTile(
            icon: HugeIcons.strokeRoundedBackpack01,
            title: 'قائمة التجهيز',
            subtitle: 'ما تحتاج حمله قبل السفر',
            color: colors.secondary,
            onTap: () => context.router.push(const UmrahChecklistRoute()),
          ),
          SizedBox(height: context.insets.sm),
          SizedBox(
            height: 52.h,
            child: OutlinedButton.icon(
              onPressed: () =>
                  ShareService.shareAsText(context, UmrahSummary.build(), null),
              icon: const AppIcon(HugeIcons.strokeRoundedShare08),
              label: const Text('مشاركة ملخص للطباعة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.corners.xl),
                ),
              ),
            ),
          ),
          SizedBox(height: context.insets.lg),
          const UmrahDisclaimer(),
        ],
      ),
    );
  }
}
