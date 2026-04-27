import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/home/widgets/feature_card.dart';
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
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: context.insets.sm * 0.8,
          mainAxisSpacing: context.insets.sm * 0.8,
        ),
        delegate: SliverChildListDelegate([
          _FeatureItem(
            title: "القرآن الكريم",
            icon: Icons.menu_book_rounded,
            color: const Color(0xff27ae60),
            route: SurahRoute(
              currentPage: CacheHelper.getData(key: 'pageNumber') ?? 1,
            ),
          ),
          _FeatureItem(
            title: "الأذكار",
            icon: Icons.wb_sunny_rounded,
            color: const Color(0xfff39c12),
            route: const AzkarRoute(),
          ),
          _FeatureItem(
            title: "حصن المسلم",
            icon: Icons.security_rounded,
            color: const Color(0xff2c3e50),
            route: const HusinAlMuslimRoute(),
          ),
          _FeatureItem(
            title: "الأربعين النووية",
            icon: Icons.library_books_rounded,
            color: const Color(0xffc0392b),
            route: const HadithNawawiRoute(),
          ),
          _FeatureItem(
            title: "أسماء الله",
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xff8e44ad),
            route: AsmaAllahRoute(),
          ),
          _FeatureItem(
            title: "القبلة",
            icon: Icons.explore_rounded,
            color: const Color(0xff16a085),
            route: const QiblahRoute(),
          ),
          _FeatureItem(
            title: "قصص الأنبياء",
            icon: Icons.history_edu_rounded,
            color: const Color(0xff795548),
            route: const ProphetsListRoute(),
          ),
          _FeatureItem(
            title: "المسبحة الالكترونية",
            icon: Icons.touch_app,
            color: const Color(0xff5d2c01),
            route: const MisbahaRoute(),
          ),
          _FeatureItem(
            title: "بث مباشر",
            icon: Icons.live_tv_rounded,
            color: const Color(0xffe74c3c),
            route: const LiveStreamRoute(),
          ),
          _FeatureItem(
            title: "الرقية الشرعية",
            icon: Icons.health_and_safety_rounded,
            color: const Color(0xff00bcd4),
            route: const RuqyahRoute(),
          ),
          _FeatureItem(
            title: "الإعدادات",
            icon: Icons.settings_suggest_rounded,
            color: const Color(0xff95a5a6),
            route: const SettingsRoute(),
          ),
        ]),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final PageRouteInfo? route;

  const _FeatureItem({
    required this.title,
    required this.icon,
    required this.color,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    return FeatureCard(
      title: title,
      icon: icon,
      color: color,
      onTap: () => route != null
          ? context.router.push(route!)
          : showToast(text: 'قريباً إن شاء الله'),
    );
  }
}
