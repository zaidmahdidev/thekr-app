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
import 'package:thekr_app/features/umrah/providers/umrah_text.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_disclaimer.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_font_actions.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_hero.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_menu_tile.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_section_title.dart';
import '../data/hajj_summary.dart';
import '../widgets/hajj_overview_strip.dart';

/// Home of the Hajj guide. A reference to read before the trip: the six stages
/// at a glance, then the sections that explain the rest.
@RoutePage()
class HajjScreen extends ConsumerWidget {
  const HajjScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = ref.watch(umrahTextProvider);

    return AppScaffold(
      appBar: BaseAppBar(title: 'دليل الحاج', actions: umrahFontActions(ref)),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.insets.md,
          context.insets.sm,
          context.insets.md,
          context.insets.lg + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          const UmrahHero(
            title: 'تعلّم الحج قبل أن تسافر',
            subtitle:
                'مرجع مبسّط لكل الأعمار، يشرح المناسك يوماً بيوم بأدلتها.',
            tip:
                'اقرأه في بيتك وأنت مرتاح، وأثناء الحج اترك هاتفك في جيبك وتفرّغ للعبادة.',
          ),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('الخطوة الأولى'),
          SizedBox(height: context.insets.md),
          // The type of Hajj decides what the pilgrim does from the miqat on,
          // so it comes before everything else.
          UmrahMenuTile(
            icon: HugeIcons.strokeRoundedStar,
            title: 'اختر نسكك أولاً',
            subtitle: 'التمتع أو القِران أو الإفراد، وهو يحدد ما تفعله بعده',
            color: colors.secondary,
            onTap: () => context.router.push(const HajjTypesRoute()),
          ),
          SizedBox(height: context.insets.md),
          const UmrahSectionTitle('الحج في نظرة'),
          SizedBox(height: context.insets.sm),
          Text(
            'هذه مراحل الحج بالترتيب. اضغط على أي مرحلة لتقرأ شرحها.',
            style: text.small(context, color: colors.textSecondary),
          ),
          SizedBox(height: context.insets.md),
          HajjOverviewStrip(
            onOpen: (day) =>
                context.router.push(HajjDayRoute(dayNumber: day.number)),
          ),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('تعرّف أكثر'),
          SizedBox(height: context.insets.md),
          UmrahMenuTile(
            icon: HugeIcons.strokeRoundedBook02,
            title: 'تعرّف على الحج',
            subtitle: 'حكمه وفضله وأركانه وواجباته',
            color: colors.primary,
            onTap: () => context.router.push(const HajjIntroRoute()),
          ),
          UmrahMenuTile(
            icon: HugeIcons.strokeRoundedPassport,
            title: 'التصريح والتسجيل',
            subtitle: 'ما تحتاجه قبل أن تحجز',
            color: colors.primary,
            onTap: () => context.router.push(const HajjPermitRoute()),
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
            icon: HugeIcons.strokeRoundedUserMultiple,
            title: 'أحكام خاصة والفدية',
            subtitle: 'المرأة والمريض والهدي والفدية',
            color: colors.secondary,
            onTap: () => context.router.push(const HajjSpecialRoute()),
          ),
          UmrahMenuTile(
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            title: 'الأخطاء الشائعة',
            subtitle: 'أخطاء يقع فيها كثيرون وصوابها',
            color: colors.success,
            onTap: () => context.router.push(const HajjMistakesRoute()),
          ),
          UmrahMenuTile(
            icon: HugeIcons.strokeRoundedBackpack01,
            title: 'قائمة التجهيز',
            subtitle: 'ما تحتاج حمله قبل السفر',
            color: colors.secondary,
            onTap: () => context.router.push(const HajjChecklistRoute()),
          ),
          SizedBox(height: context.insets.sm),
          SizedBox(
            height: 52.h,
            child: OutlinedButton.icon(
              onPressed: () =>
                  ShareService.shareAsText(context, HajjSummary.build(), null),
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
