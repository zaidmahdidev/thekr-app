import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/quran/models/quran_reader_palette.dart';
import 'package:thekr_app/features/quran/services/quran_reader_adapter.dart';
import 'package:thekr_app/features/quran/widgets/quran_page_indicator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Index tab: all surahs or all juz, with the current one highlighted.
class QuranIndexTab extends StatefulWidget {
  const QuranIndexTab({
    super.key,
    required this.currentPage,
    required this.palette,
  });

  final int currentPage;
  final QuranReaderPalette palette;

  @override
  State<QuranIndexTab> createState() => _QuranIndexTabState();
}

class _QuranIndexTabState extends State<QuranIndexTab> {
  static const double _baseRowExtent = 66;

  /// Real row height. The list and the scroll offset must use this same value,
  /// otherwise the current surah lands outside the visible area.
  late final double _rowExtent = _baseRowExtent.h;

  bool _showJuz = false;
  late final List<QuranSurahInfo> _surahs = QuranReaderAdapter.surahs();
  // Prefer the page the library is really on; fall back to the app's copy.
  late final int _page = QuranReaderAdapter.livePage ?? widget.currentPage;
  late final int _currentSurah = QuranReaderAdapter.surahOfPage(_page);
  late final int _currentJuz = QuranReaderAdapter.juzOfPage(_page) ?? -1;
  late final ScrollController _surahController;
  late final ScrollController _juzController;

  /// Offset that shows the item at [index] as the third visible row.
  ScrollController _controllerFor(int index) => ScrollController(
    initialScrollOffset: (index * _rowExtent - _rowExtent * 2).clamp(
      0,
      double.infinity,
    ),
  );

  @override
  void initState() {
    super.initState();
    _surahController = _controllerFor((_currentSurah - 1).clamp(0, 113));
    _juzController = _controllerFor((_currentJuz - 1).clamp(0, 29));
  }

  @override
  void dispose() {
    _surahController.dispose();
    _juzController.dispose();
    super.dispose();
  }

  void _goToSurah(int number) {
    Navigator.of(context).pop();
    QuranReaderAdapter.jumpToSurah(number);
  }

  void _goToJuz(int number) {
    Navigator.of(context).pop();
    QuranReaderAdapter.jumpToJuz(number);
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.insets.md,
            vertical: context.insets.sm,
          ),
          child: SegmentedButton<bool>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: palette.icon.withValues(alpha: 0.18),
              selectedForegroundColor: palette.icon,
              foregroundColor: palette.textMuted,
              side: BorderSide(color: palette.text.withValues(alpha: 0.15)),
            ),
            segments: const [
              ButtonSegment(value: false, label: Text('السور')),
              ButtonSegment(value: true, label: Text('الأجزاء')),
            ],
            selected: {_showJuz},
            onSelectionChanged: (v) => setState(() => _showJuz = v.first),
          ),
        ),
        Expanded(child: _showJuz ? _buildJuz(context) : _buildSurahs(context)),
      ],
    );
  }

  Widget _buildSurahs(BuildContext context) {
    return ListView.builder(
      controller: _surahController,
      itemExtent: _rowExtent,
      itemCount: _surahs.length,
      padding: EdgeInsets.symmetric(horizontal: context.insets.md),
      itemBuilder: (context, index) {
        final surah = _surahs[index];
        return _IndexTile(
          number: surah.number,
          title: surah.name,
          subtitle:
              '${surah.isMeccan ? 'مكية' : 'مدنية'} · ${quranDigits(surah.ayahCount)} آية',
          isCurrent: surah.number == _currentSurah,
          palette: widget.palette,
          onTap: () => _goToSurah(surah.number),
        );
      },
    );
  }

  Widget _buildJuz(BuildContext context) {
    return ListView.builder(
      controller: _juzController,
      itemExtent: _rowExtent,
      itemCount: 30,
      padding: EdgeInsets.symmetric(horizontal: context.insets.md),
      itemBuilder: (context, index) {
        final juz = index + 1;
        return _IndexTile(
          number: juz,
          title: 'الجزء ${quranDigits(juz)}',
          isCurrent: juz == _currentJuz,
          palette: widget.palette,
          onTap: () => _goToJuz(juz),
        );
      },
    );
  }
}

class _IndexTile extends StatelessWidget {
  const _IndexTile({
    required this.number,
    required this.title,
    required this.isCurrent,
    required this.palette,
    required this.onTap,
    this.subtitle,
  });

  final int number;
  final String title;
  final String? subtitle;
  final bool isCurrent;
  final QuranReaderPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Material(
        color: isCurrent
            ? palette.icon.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(context.corners.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.lg),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.insets.sm + 2.w),
            child: Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? palette.icon
                        : palette.icon.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(context.corners.md + 2),
                  ),
                  child: Text(
                    quranDigits(number),
                    style: context.textStyles.labelLarge?.copyWith(
                      color: isCurrent ? palette.surface : palette.icon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: context.insets.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.titleSmall?.copyWith(
                          color: palette.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          style: context.textStyles.labelSmall?.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isCurrent)
                  AppIcon(HugeIcons.strokeRoundedBookmark01, size: 18.sp, color: palette.icon),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
