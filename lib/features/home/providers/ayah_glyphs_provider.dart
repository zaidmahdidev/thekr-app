import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/features/quran/services/quran_reader_adapter.dart';

typedef AyahGlyphsRequest = ({int surah, int ayah, int page, bool isDark});

/// Loads a verse in the Mushaf page font. Cached per request, so the font of a
/// page is only loaded once.
final ayahGlyphsProvider =
    FutureProvider.family<QuranAyahGlyphs?, AyahGlyphsRequest>(
      (ref, request) => QuranReaderAdapter.ayahGlyphs(
        surah: request.surah,
        ayah: request.ayah,
        page: request.page,
        isDark: request.isDark,
      ),
    );
