import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/features/home/data/daily_content_data.dart';

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
    // Selection logic based on day of year
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    // Ayah selection
    final ayahIndex = dayOfYear % dailyAyahs.length;
    final ayah = dailyAyahs[ayahIndex];

    // Hadith selection
    final hadithIndex = dayOfYear % dailyHadiths.length;
    final hadith = dailyHadiths[hadithIndex];

    // Adhkar selection
    final adhkarsIndex = dayOfYear % dailyAdhkars.length;
    final adhkar = dailyAdhkars[adhkarsIndex];

    final items = [
      _InspirationItem(
        type: 'آية اليوم',
        content: ayah.text,
        subtitle: '${ayah.surah} - [${ayah.ayahNumber}]',
        icon: Icons.auto_stories_rounded,
        onTap: () => context.router.push(QuranRoute(currentPage: ayah.page)),
      ),
      _InspirationItem(
        type: 'حديث اليوم',
        content: hadith.text,
        subtitle: hadith.source,
        icon: Icons.menu_book_rounded,
        onTap: () {},
      ),
      _InspirationItem(
        type: 'ذكر اليوم',
        content: adhkar.text,
        subtitle: adhkar.reward,
        icon: Icons.auto_awesome,
        onTap: () {},
      ),
    ];

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.insets.md,
              vertical: context.insets.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إلهامات يومية',
                  style: context.textStyles.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                            ? context.colors.secondary
                            : context.colors.secondary.withValues(alpha: 0.2),
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
            height: 155.h,
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
    final isAyah = item.type == 'آية اليوم';

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
          width: 0.8.w,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(context.corners.xl),
          child: Padding(
            padding: EdgeInsets.all(context.insets.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      item.icon,
                      color: context.colors.secondary.withValues(alpha: 0.7),
                      size: 24.sp,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.insets.sm,
                        vertical: (context.insets.sm / 2),
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(context.corners.md),
                      ),
                      child: Text(
                        item.type,
                        style: context.textStyles.labelLarge?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Expanded(
                  flex: 8,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        item.content,
                        textAlign: TextAlign.center,
                        style: context.textStyles.bodyLarge?.copyWith(
                          fontSize: _calculateFontSize(item.content, isAyah),
                          fontWeight: isAyah
                              ? FontWeight.normal
                              : FontWeight.w500,
                          height: isAyah ? 1.7 : 1.6,
                          color: context.colors.textPrimary,
                          fontFamily: isAyah ? 'hafs' : 'Tajawal',
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 35.w,
                      height: 1.h,
                      color: context.colors.primary.withValues(alpha: 0.1),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.insets.sm,
                        ),
                        child: Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.textSecondary,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 35.w,
                      height: 1.h,
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

  double _calculateFontSize(String text, bool isAyah) {
    if (isAyah) {
      if (text.length > 100) return 16.sp;
      if (text.length > 60) return 18.sp;
      return 20.sp;
    } else {
      if (text.length > 100) return 13.sp;
      if (text.length > 60) return 15.sp;
      return 17.sp;
    }
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
