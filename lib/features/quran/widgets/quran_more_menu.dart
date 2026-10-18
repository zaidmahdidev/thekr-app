import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/quran/models/quran_reader_palette.dart';
import 'package:thekr_app/features/quran/services/quran_reader_adapter.dart';

/// Single "more" button for the Quran top bar. It replaces the row of secondary
/// icons (share, surah audio, auto scroll, tajweed rules, recitations, fonts)
/// with one tidy bottom sheet, keeping the bar itself short and uncluttered.
class QuranMoreMenuButton extends StatelessWidget {
  const QuranMoreMenuButton({
    super.key,
    required this.palette,
    required this.onSharePage,
  });

  final QuranReaderPalette palette;
  final VoidCallback onSharePage;

  void _open(BuildContext context) {
    final host = context;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        void run(VoidCallback action) {
          Navigator.of(sheetContext).pop();
          // Let the sheet finish closing before opening dialogs or sheets.
          Future.delayed(const Duration(milliseconds: 250), action);
        }

        final items = [
          _MenuItem(
            icon: Icons.ios_share_rounded,
            title: 'مشاركة الصفحة',
            onTap: () => run(onSharePage),
          ),
          _MenuItem(
            icon: Icons.headphones_rounded,
            title: 'الاستماع للسور',
            onTap: () =>
                run(() => QuranReaderAdapter.openSurahAudio(host, palette)),
          ),
          _MenuItem(
            icon: Icons.swipe_down_alt_rounded,
            title: 'تمرير تلقائي',
            onTap: () => run(QuranReaderAdapter.toggleAutoScroll),
          ),
          _MenuItem(
            icon: Icons.color_lens_rounded,
            title: 'أحكام التجويد',
            onTap: () =>
                run(() => QuranReaderAdapter.openTajweedRules(host, palette)),
          ),
          _MenuItem(
            icon: Icons.record_voice_over_rounded,
            title: 'القراءات العشر',
            onTap: () =>
                run(() => QuranReaderAdapter.openRecitations(host, palette)),
          ),
          _MenuItem(
            icon: Icons.font_download_rounded,
            title: 'خطوط المصحف',
            onTap: () => run(() => QuranReaderAdapter.openFonts(host, palette)),
          ),
        ];

        return _MoreSheet(items: items, palette: palette);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _open(context),
      tooltip: 'المزيد',
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: 38.w, height: 44.h),
      icon: Icon(Icons.more_vert_rounded, size: 22.sp, color: palette.icon),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class _MoreSheet extends StatelessWidget {
  const _MoreSheet({required this.items, required this.palette});

  final List<_MenuItem> items;
  final QuranReaderPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.corners.xl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.insets.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: context.insets.md),
                decoration: BoxDecoration(
                  color: palette.text.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(context.corners.sm),
                ),
              ),
              Text(
                'خيارات القراءة',
                style: context.textStyles.titleSmall?.copyWith(
                  color: palette.icon,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.insets.md),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: context.insets.sm,
                mainAxisSpacing: context.insets.md,
                childAspectRatio: 0.95,
                children: [
                  for (final item in items)
                    _MenuTile(item: item, palette: palette),
                ],
              ),
              SizedBox(height: context.insets.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item, required this.palette});

  final _MenuItem item;
  final QuranReaderPalette palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(context.corners.lg),
      onTap: item.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: palette.icon.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 25.sp, color: palette.icon),
          ),
          SizedBox(height: context.insets.sm),
          Text(
            item.title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.labelMedium?.copyWith(
              color: palette.text,
              fontWeight: FontWeight.w600,
              fontSize: 11.5.sp,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
