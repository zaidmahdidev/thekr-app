import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/quran/models/quran_reader_palette.dart';
import 'package:thekr_app/features/quran/widgets/navigator/quran_bookmarks_tab.dart';
import 'package:thekr_app/features/quran/widgets/navigator/quran_index_tab.dart';
import 'package:thekr_app/features/quran/widgets/navigator/quran_search_tab.dart';

enum QuranNavigatorTab { contents, search, bookmarks }

/// Opens the Quran navigator (index, search, bookmarks) as a bottom sheet.
/// [initialTab] lets the top bar open straight on the search tab.
Future<void> showQuranNavigator(
  BuildContext context, {
  required QuranNavigatorTab initialTab,
  required int currentPage,
  required QuranReaderPalette palette,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => QuranNavigatorSheet(
      initialTab: initialTab,
      currentPage: currentPage,
      palette: palette,
    ),
  );
}

class QuranNavigatorSheet extends StatelessWidget {
  const QuranNavigatorSheet({
    super.key,
    required this.initialTab,
    required this.currentPage,
    required this.palette,
  });

  final QuranNavigatorTab initialTab;
  final int currentPage;
  final QuranReaderPalette palette;

  static const _labels = ['الفهرس', 'البحث', 'الفواصل'];
  static const double _heightFactor = 0.82;

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return DefaultTabController(
      length: _labels.length,
      initialIndex: initialTab.index,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: Container(
          height: MediaQuery.sizeOf(context).height * _heightFactor,
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.corners.xl),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: context.insets.sm + 2.h),
                decoration: BoxDecoration(
                  color: palette.text.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(context.corners.sm),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.insets.md),
                child: Container(
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: palette.text.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(context.corners.xl),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.all(4.r),
                    indicator: BoxDecoration(
                      color: palette.icon,
                      borderRadius: BorderRadius.circular(context.corners.xl),
                    ),
                    labelColor: palette.surface,
                    unselectedLabelColor: palette.textMuted,
                    labelStyle: context.textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [for (final label in _labels) Tab(text: label)],
                  ),
                ),
              ),
              SizedBox(height: context.insets.sm),
              Expanded(
                child: TabBarView(
                  children: [
                    QuranIndexTab(currentPage: currentPage, palette: palette),
                    QuranSearchTab(
                      palette: palette,
                      autofocus: initialTab == QuranNavigatorTab.search,
                    ),
                    QuranBookmarksTab(palette: palette),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
