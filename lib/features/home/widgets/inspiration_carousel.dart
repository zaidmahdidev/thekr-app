import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/features/home/data/ayah_data.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/router/app_router.dart';

class InspirationCarousel extends StatefulWidget {
  const InspirationCarousel({super.key});

  @override
  State<InspirationCarousel> createState() => _InspirationCarouselState();
}

class _InspirationCarouselState extends State<InspirationCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    // Current Ayah selection logic
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final ayahIndex = dayOfYear % dailyAyahs.length;
    final ayah = dailyAyahs[ayahIndex];

    final items = [
      _InspirationItem(
        type: 'آية اليوم',
        content: ayah.text,
        subtitle: '${ayah.surah} - [${ayah.ayahNumber}]',
        icon: Icons.auto_stories_rounded,
        onTap: () => context.router.push(SurahRoute(currentPage: ayah.page)),
      ),
      _InspirationItem(
        type: 'حديث اليوم',
        content: '« مَنْ سَلَكَ طَرِيقاً يَبْتَغِي فِيهِ عِلْماً سَهَّلَ اللهُ لَهُ طَرِيقاً إِلَى الْجَنَّةِ »',
        subtitle: 'رواه مسلم',
        icon: Icons.menu_book_rounded,
        onTap: () {},
      ),
      _InspirationItem(
        type: 'ذكر الآن',
        content: 'سبحان الله وبحمده، سبحان الله العظيم',
        subtitle: 'ثقيلتان في الميزان',
        icon: Icons.favorite_rounded,
        onTap: () {},
      ),
    ];

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.insets.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إلهامات يومية',
                  style: AppTypography.h3.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: List.generate(
                    items.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4.h,
                      width: _currentPage == index ? 12.w : 4.w,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? context.colors.primary
                            : context.colors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.insets.sm),
          SizedBox(
            height: 180.h,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.insets.md),
                  child: _InspirationCard(item: item),
                );
              },
            ),
          ),
          SizedBox(height: context.insets.md),
        ],
      ),
    );
  }
}

class _InspirationCard extends StatelessWidget {
  final _InspirationItem item;

  const _InspirationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.xl),
        boxShadow: context.shadows.low,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary.withValues(alpha: 0.05),
            context.colors.surface,
          ],
        ),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(context.corners.xl),
          child: Padding(
            padding: EdgeInsets.all(context.insets.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      item.icon,
                      color: context.colors.primary.withValues(alpha: 0.3),
                      size: 24.sp,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.insets.sm,
                        vertical: context.insets.sm / 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(context.corners.md),
                      ),
                      child: Text(
                        item.type,
                        style: context.textStyles.labelSmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  item.content,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                    color: context.colors.textPrimary,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30.w,
                      height: 1,
                      color: context.colors.primary.withValues(alpha: 0.1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.insets.sm),
                      child: Text(
                        item.subtitle,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.textSecondary,
                          fontStyle: FontStyle.italic,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    Container(
                      width: 30.w,
                      height: 1,
                      color: context.colors.primary.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InspirationItem {
  final String type;
  final String content;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _InspirationItem({
    required this.type,
    required this.content,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
