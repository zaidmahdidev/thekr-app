import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/home/data/daily_content_data.dart';
import 'package:thekr_app/features/home/models/inspiration_item.dart';
import 'package:thekr_app/features/home/widgets/inspiration_card.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// "إلهامات يومية": today's verse, hadith and dhikr. Swipe the card or tap the
/// small tabs in the header. The selection rotates by day of year, so it is
/// stable for the whole day.
class InspirationCarousel extends StatefulWidget {
  const InspirationCarousel({super.key});

  @override
  State<InspirationCarousel> createState() => _InspirationCarouselState();
}

class _InspirationCarouselState extends State<InspirationCarousel> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  late final List<InspirationItem> _items = _buildItems();

  static List<InspirationItem> _buildItems() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    final ayah = dailyAyahs[dayOfYear % dailyAyahs.length];
    final hadith = dailyHadiths[dayOfYear % dailyHadiths.length];
    final dhikr = dailyAdhkars[dayOfYear % dailyAdhkars.length];

    final ayahSource = 'سورة ${ayah.surah} - آية ${ayah.ayahNumber}';

    return [
      InspirationItem(
        type: InspirationType.ayah,
        content: '﴿${ayah.text}﴾',
        footer: ayahSource,
        source: '$ayahSource - صفحة ${ayah.page}',
        ayah: AyahRef(
          surah: ayah.surahNumber,
          ayah: ayah.ayahNumber,
          page: ayah.page,
        ),
      ),
      InspirationItem(
        type: InspirationType.hadith,
        content: hadith.text,
        footer: hadith.source,
        source: hadith.source,
      ),
      InspirationItem(
        type: InspirationType.dhikr,
        content: dhikr.text,
        footer: dhikr.reward,
        source: dhikr.source,
        note: dhikr.note,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.insets.md,
              context.insets.sm,
              context.insets.md,
              context.insets.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: context.colors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: context.insets.sm),
                Text(
                  'إلهامات يومية',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ValueListenableBuilder<int>(
                  valueListenable: _currentPage,
                  builder: (context, page, _) => Row(
                    children: [
                      for (int i = 0; i < _items.length; i++)
                        _TabChip(
                          icon: _items[i].type.icon,
                          selected: page == i,
                          onTap: () => _goTo(i),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 172.h,
            child: PageView.builder(
              controller: _pageController,
              clipBehavior: Clip.none,
              onPageChanged: (index) => _currentPage.value = index,
              itemCount: _items.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.fromLTRB(
                  context.insets.md,
                  2.h,
                  context.insets.md,
                  10.h,
                ),
                child: InspirationCard(item: _items[index]),
              ),
            ),
          ),
          SizedBox(height: context.insets.sm),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final AppIconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.colors.secondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: EdgeInsetsDirectional.only(start: 6.w),
        width: selected ? 38.w : 28.w,
        height: 26.h,
        decoration: BoxDecoration(
          color: selected ? gold : gold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(context.corners.xl),
        ),
        child: AppIcon(icon, size: 14.sp, color: selected ? Colors.white : gold),
      ),
    );
  }
}
