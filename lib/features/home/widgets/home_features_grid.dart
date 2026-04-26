import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/features/home/widgets/modern_feature_card.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';

class HomeFeaturesGrid extends StatelessWidget {
  const HomeFeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: context.insets.md,
        vertical: context.insets.sm,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.82,
          crossAxisSpacing: context.insets.sm,
          mainAxisSpacing: context.insets.sm,
        ),
        delegate: SliverChildListDelegate([
          _FeatureItem(
            title: "القرآن الكريم",
            icon: AppAssets.quran,
            route: SurahRoute(
              currentPage: CacheHelper.getData(key: 'pageNumber') ?? 1,
            ),
          ),
          _FeatureItem(
            title: "الأذكار",
            icon: AppAssets.azkar,
            route: const AzkarRoute(),
          ),
          _FeatureItem(
            title: "حصن المسلم",
            icon: AppAssets.husnAlMuslim,
            route: const HusinAlMuslimRoute(),
          ),
          _FeatureItem(
            title: "الأربعين النووية",
            icon: AppAssets.hadith,
            route: const HadithNawawiRoute(),
          ),
          _FeatureItem(
            title: "أسماء الله",
            icon: AppAssets.asmaAllah,
            route: AsmaAllahRoute(),
          ),
          _FeatureItem(
            title: "القبلة",
            icon: AppAssets.qiblah,
            route: const QiblahRoute(),
          ),
          _FeatureItem(
            title: "قصص الأنبياء",
            icon: AppAssets.stories,
            route: const ProphetsListRoute(),
          ),
          _FeatureItem(
            title: "المسبحة",
            icon: AppAssets.misbaha,
            route: const MisbahaRoute(),
          ),
          _FeatureItem(
            title: "بث مباشر",
            icon: AppAssets.live,
            route: const LiveStreamRoute(),
          ),
        ]),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String title;
  final String icon;
  final PageRouteInfo? route;

  const _FeatureItem({required this.title, required this.icon, this.route});

  @override
  Widget build(BuildContext context) {
    return ModernFeatureCard(
      title: title,
      imgUrl: icon,
      onTap: () => route != null
          ? context.router.push(route!)
          : showToast(text: 'قريباً إن شاء الله'),
    );
  }
}
