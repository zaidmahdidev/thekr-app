import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/quran/models/quran_reader_palette.dart';
import 'package:thekr_app/features/quran/services/quran_reader_adapter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/utils/quran_text.dart';

/// Bookmarks tab: the verses the user marked, with jump and delete.
class QuranBookmarksTab extends StatefulWidget {
  const QuranBookmarksTab({super.key, required this.palette});

  final QuranReaderPalette palette;

  @override
  State<QuranBookmarksTab> createState() => _QuranBookmarksTabState();
}

class _QuranBookmarksTabState extends State<QuranBookmarksTab> {
  void _open(QuranBookmarkInfo bookmark) {
    Navigator.of(context).pop();
    QuranReaderAdapter.jumpToBookmark(bookmark);
  }

  void _remove(QuranBookmarkInfo bookmark) {
    QuranReaderAdapter.removeBookmark(bookmark);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final bookmarks = QuranReaderAdapter.bookmarks();

    if (bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.insets.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                HugeIcons.strokeRoundedBookmark01,
                size: 48.sp,
                color: palette.icon.withValues(alpha: 0.4),
              ),
              SizedBox(height: context.insets.sm),
              Text(
                'لا توجد فواصل بعد',
                style: context.textStyles.titleSmall?.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'اضغط مطولاً على أي آية ثم اختر إضافة فاصل لتعود إليها بسرعة',
                textAlign: TextAlign.center,
                style: context.textStyles.bodySmall?.copyWith(
                  color: palette.textMuted,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: context.insets.md),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 3.h),
          child: Material(
            color: palette.text.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(context.corners.lg),
            child: InkWell(
              borderRadius: BorderRadius.circular(context.corners.lg),
              onTap: () => _open(bookmark),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.insets.md,
                  vertical: context.insets.sm,
                ),
                child: Row(
                  children: [
                    AppIcon(HugeIcons.strokeRoundedBookmark01, color: bookmark.color),
                    SizedBox(width: context.insets.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookmark.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textStyles.titleSmall?.copyWith(
                              color: palette.text,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'صفحة ${QuranText.digits(bookmark.page)} · آية ${QuranText.digits(bookmark.ayahNumber)}',
                            style: context.textStyles.labelSmall?.copyWith(
                              color: palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'حذف',
                      onPressed: () => _remove(bookmark),
                      icon: AppIcon(
                        HugeIcons.strokeRoundedDelete02,
                        color: context.colors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
