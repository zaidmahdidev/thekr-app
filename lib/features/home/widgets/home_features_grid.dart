import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/home/widgets/feature_card.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/providers/feature_badge_provider.dart';
import 'package:thekr_app/core/widgets/new_feature_badge.dart';

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
            imagePath: AppAssets.fQuran,
            color: const Color(0xff27ae60),
            onTap: () {
              final lastPage = CacheHelper.getData(key: 'pageNumber') ?? 1;
              context.router.push(QuranRoute(currentPage: lastPage));
            },
          ),
          _FeatureItem(
            title: "الأذكار",
            imagePath: AppAssets.fAzkar,
            color: const Color(0xfff39c12),
            route: const AzkarRoute(),
          ),
          _FeatureItem(
            title: "حصن المسلم",
            imagePath: AppAssets.fHusn,
            color: const Color(0xff2c3e50),
            route: const HusinAlMuslimRoute(),
          ),
          _FeatureItem(
            title: "الأربعين النووية",
            imagePath: AppAssets.fHadith,
            color: const Color(0xffc0392b),
            route: const HadithNawawiRoute(),
          ),
          _FeatureItem(
            title: "أسماء الله",
            imagePath: AppAssets.fAsmaAllah,
            color: const Color(0xff8e44ad),
            route: AsmaAllahRoute(),
          ),
          _FeatureItem(
            title: "القبلة",
            imagePath: AppAssets.fQiblah,
            color: const Color(0xff16a085),
            route: const QiblahRoute(),
          ),
          _FeatureItem(
            title: "قصص الأنبياء",
            imagePath: AppAssets.fProphets,
            color: const Color(0xff795548),
            route: const ProphetsListRoute(),
          ),
          _FeatureItem(
            title: "المسبحة الالكترونية",
            imagePath: AppAssets.fMisbaha,
            color: const Color(0xff5d2c01),
            route: const MisbahaRoute(),
          ),
          _FeatureItem(
            title: "بث مباشر",
            imagePath: AppAssets.fLive,
            color: const Color(0xffe74c3c),
            route: const LiveStreamRoute(),
          ),
          _FeatureItem(
            title: "التقويم الإسلامي",
            imagePath: AppAssets.fCalendar,
            color: const Color(0xff009688),
            route: const CalendarRoute(),
            featureId: 'calendar',
            addedInVersion: '1.2.1',
          ),
          _FeatureItem(
            title: "متتبع العبادات",
            imagePath: AppAssets.fHabitTracker,
            color: const Color(0xff3498db),
            route: const HabitTrackerRoute(),
            featureId: 'habit_tracker',
            addedInVersion: '1.2.1',
          ),
          _FeatureItem(
            title: "الإعدادات",
            imagePath: AppAssets.fSettings,
            color: const Color(0xff95a5a6),
            route: const SettingsRoute(),
          ),
        ]),
      ),
    );
  }
}

class _FeatureItem extends ConsumerWidget {
  final String title;
  final String? imagePath;
  final IconData? icon;
  final Color color;
  final PageRouteInfo? route;
  final VoidCallback? onTap;
  final String? featureId;
  final String? addedInVersion;

  const _FeatureItem({
    required this.title,
    this.imagePath,
    this.icon,
    required this.color,
    this.route,
    this.onTap,
    this.featureId,
    this.addedInVersion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasBadge = featureId != null && addedInVersion != null;

    final card = FeatureCard(
      title: title,
      imgUrl: imagePath,
      icon: icon,
      color: color,
      onTap: () {
        if (hasBadge) {
          ref.read(featureBadgeProvider.notifier).recordFeatureClick(featureId!);
        }

        if (onTap != null) {
          onTap!();
        } else if (route != null) {
          context.router.push(route!);
        } else {
          showToast(text: 'قريباً إن شاء الله');
        }
      },
    );

    if (hasBadge) {
      return NewFeatureBadge(
        featureId: featureId!,
        addedInVersion: addedInVersion!,
        child: card,
      );
    }

    return card;
  }
}
