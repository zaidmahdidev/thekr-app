import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/url_helper.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_disclaimer.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_font_actions.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_section_title.dart';
import 'package:thekr_app/features/umrah/widgets/umrah_text_card.dart';
import '../data/hajj_intro_data.dart';

/// What a pilgrim needs to arrange before Hajj. The rules change every season,
/// so this page states what is stable and sends the reader to the official
/// sources for the rest.
@RoutePage()
class HajjPermitScreen extends ConsumerWidget {
  const HajjPermitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    Widget link(String label, String url, AppIconData icon) => Padding(
      padding: EdgeInsets.only(bottom: context.insets.sm + 2.w),
      child: SizedBox(
        height: 52.h,
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => UrlHelper.launchURL(url),
          icon: AppIcon(icon),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.corners.xl),
            ),
          ),
        ),
      ),
    );

    return AppScaffold(
      appBar: BaseAppBar(
        title: 'التصريح والتسجيل',
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
          const UmrahSectionTitle('لا حج بلا تصريح'),
          SizedBox(height: context.insets.md),
          const UmrahTextCard(HajjIntroData.permitNote),
          SizedBox(height: context.insets.lg),
          const UmrahSectionTitle('المصادر الرسمية'),
          SizedBox(height: context.insets.md),
          link(
            'منصة نسك',
            HajjIntroData.nusukUrl,
            HugeIcons.strokeRoundedLinkSquare01,
          ),
          link(
            'وزارة الحج والعمرة',
            HajjIntroData.ministryUrl,
            HugeIcons.strokeRoundedLinkSquare01,
          ),
          SizedBox(height: context.insets.md),
          const UmrahDisclaimer(
            text:
                'يفتح الزر موقعاً خارجياً. تأكد من أنك على الموقع الرسمي قبل '
                'إدخال أي بيانات أو دفع أي مبلغ.',
          ),
        ],
      ),
    );
  }
}
