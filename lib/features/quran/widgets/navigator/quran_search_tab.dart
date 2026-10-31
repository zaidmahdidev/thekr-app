import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/quran/models/quran_reader_palette.dart';
import 'package:thekr_app/features/quran/services/quran_reader_adapter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/utils/quran_text.dart';

/// Search tab: matches surah names / numbers first, then verses by their text.
class QuranSearchTab extends StatefulWidget {
  const QuranSearchTab({
    super.key,
    required this.palette,
    this.autofocus = false,
  });

  final QuranReaderPalette palette;
  final bool autofocus;

  @override
  State<QuranSearchTab> createState() => _QuranSearchTabState();
}

class _QuranSearchTabState extends State<QuranSearchTab> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<QuranSurahInfo> _surahs = const [];
  List<QuranAyahHit> _ayahs = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(value));
  }

  void _search(String value) {
    final text = value.trim();
    setState(() {
      _query = text;
      _surahs = text.isEmpty ? const [] : QuranReaderAdapter.searchSurahs(text);
      _ayahs = text.isEmpty ? const [] : QuranReaderAdapter.searchAyahs(text);
    });
  }

  void _goToSurah(QuranSurahInfo surah) {
    Navigator.of(context).pop();
    QuranReaderAdapter.jumpToSurah(surah.number);
  }

  void _goToAyah(QuranAyahHit ayah) {
    Navigator.of(context).pop();
    QuranReaderAdapter.jumpToAyah(ayah);
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final results = _surahs.length + _ayahs.length;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.insets.md,
            vertical: context.insets.sm,
          ),
          child: TextField(
            controller: _controller,
            autofocus: widget.autofocus,
            onChanged: _onChanged,
            cursorColor: palette.icon,
            textInputAction: TextInputAction.search,
            style: context.textStyles.bodyMedium?.copyWith(color: palette.text),
            decoration: InputDecoration(
              hintText: 'ابحث بكلمة من الآية أو اسم السورة أو رقمها',
              hintStyle: context.textStyles.bodySmall?.copyWith(
                color: palette.textMuted,
              ),
              prefixIcon: AppIcon(HugeIcons.strokeRoundedSearch01, color: palette.icon),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: AppIcon(HugeIcons.strokeRoundedCancel01, color: palette.textMuted),
                      onPressed: () {
                        _controller.clear();
                        _search('');
                      },
                    ),
              filled: true,
              fillColor: palette.text.withValues(alpha: 0.06),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: context.insets.sm + 4.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.corners.xl),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: _query.isEmpty
              ? _Hint(
                  icon: HugeIcons.strokeRoundedSearchList01,
                  text: 'اكتب كلمة للبحث في القرآن الكريم',
                  palette: palette,
                )
              : results == 0
              ? _Hint(
                  icon: HugeIcons.strokeRoundedSearchRemove,
                  text: 'لا توجد نتائج مطابقة',
                  palette: palette,
                )
              : ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(horizontal: context.insets.md),
                  itemCount: results,
                  itemBuilder: (context, index) {
                    if (index < _surahs.length) {
                      final surah = _surahs[index];
                      return _ResultTile(
                        icon: HugeIcons.strokeRoundedBookOpen01,
                        title: surah.name,
                        subtitle: '${QuranText.digits(surah.ayahCount)} آية',
                        palette: palette,
                        onTap: () => _goToSurah(surah),
                      );
                    }
                    final ayah = _ayahs[index - _surahs.length];
                    return _ResultTile(
                      icon: HugeIcons.strokeRoundedQuoteDown,
                      title: ayah.text,
                      maxTitleLines: 2,
                      subtitle:
                          '${ayah.surahName} · آية ${QuranText.digits(ayah.ayahNumber)} · صفحة ${QuranText.digits(ayah.page)}',
                      palette: palette,
                      onTap: () => _goToAyah(ayah),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text, required this.palette});

  final AppIconData icon;
  final String text;
  final QuranReaderPalette palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 44.sp, color: palette.icon.withValues(alpha: 0.4)),
          SizedBox(height: context.insets.sm),
          Text(
            text,
            style: context.textStyles.bodySmall?.copyWith(
              color: palette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.onTap,
    this.maxTitleLines = 1,
  });

  final AppIconData icon;
  final String title;
  final String subtitle;
  final QuranReaderPalette palette;
  final int maxTitleLines;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Material(
        color: palette.text.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(context.corners.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.lg),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(context.insets.sm + 4.w),
            child: Row(
              children: [
                AppIcon(icon, size: 20.sp, color: palette.icon),
                SizedBox(width: context.insets.sm + 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: maxTitleLines,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: palette.text,
                          fontWeight: FontWeight.w600,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.labelSmall?.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
