import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/core/widgets/base_app_bar.dart';
import 'package:thekr_app/core/widgets/my_card.dart';
import 'package:thekr_app/core/widgets/base_animation_list_view.dart';
import 'package:thekr_app/features/ruqyah/data/ruqyah_data.dart';

@RoutePage()
class RuqyahScreen extends StatelessWidget {
  const RuqyahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: BaseAppBar(
          title: 'الرقية الشرعية',
          showBlur: true,
          bottom: TabBar(
            indicatorColor: context.colors.secondary,
            labelColor: context.colors.secondary,
            unselectedLabelColor: context.colors.textSecondary,
            labelStyle: AppTypography.button,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'آيات الرقية'),
              Tab(text: 'أدعية الرقية'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RuqyahList(items: RuqyahData.verses),
            RuqyahList(items: RuqyahData.supplications),
          ],
        ),
      ),
    );
  }
}

class RuqyahList extends StatelessWidget {
  final List<RuqyahItem> items;
  const RuqyahList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: context.insets.md),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return BaseAnimationListView(
            index: index,
            child: MyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(context.corners.sm),
                        ),
                        child: Text(
                          item.title,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (item.count > 1)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: context.colors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(context.corners.sm),
                          ),
                          child: Text(
                            'كررها ${item.count} مرات',
                            style: AppTypography.label.copyWith(
                              color: context.colors.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: context.insets.md),
                  Text(
                    item.content,
                    textAlign: TextAlign.center,
                    style: AppTypography.h2.copyWith(
                      height: 1.8.h,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: context.insets.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item.content));
                          showToast(text: 'تم نسخ النص',backgroundColor: context.colors.background);

                        },
                        icon: Icon(Icons.copy_rounded, size: 20.w),
                        color: context.colors.primary,
                        tooltip: 'نسخ',
                      ),
                      IconButton(
                        onPressed: () {
                          Share.share('${item.title}\n\n${item.content}\n\nتطبيق ذكر');
                        },
                        icon: Icon(Icons.share_rounded, size: 20.w),
                        color: context.colors.primary,
                        tooltip: 'مشاركة',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
