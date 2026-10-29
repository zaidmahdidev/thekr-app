import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/quran/models/quran_reader_palette.dart';
import 'package:thekr_app/features/quran/providers/quran_provider.dart';
import 'package:thekr_app/features/quran/services/quran_reader_adapter.dart';
import 'package:thekr_app/core/utils/app_digits.dart';

/// Shows the current page and juz in the middle of the Quran top bar.
class QuranPageIndicator extends ConsumerWidget {
  const QuranPageIndicator({
    super.key,
    required this.providerPage,
    required this.palette,
  });

  /// Argument of [quranProvider] (the page the screen was opened with).
  final int providerPage;
  final QuranReaderPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(
      quranProvider(providerPage).select((s) => s.currentPage),
    );
    final juz = QuranReaderAdapter.juzOfPage(page);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'صفحة ${AppDigits.of(page)}',
          maxLines: 1,
          style: context.textStyles.labelLarge?.copyWith(
            color: palette.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (juz != null)
          Text(
            'الجزء ${AppDigits.of(juz)}',
            maxLines: 1,
            style: context.textStyles.labelSmall?.copyWith(
              color: palette.textMuted,
            ),
          ),
      ],
    );
  }
}
