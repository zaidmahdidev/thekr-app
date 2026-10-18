import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quran_library/quran_library.dart';
import 'package:thekr_app/features/quran/models/quran_reader_palette.dart';

/// Single point of contact between the app's reader UI and the `quran_library`
/// package.
///
/// Everything the custom top bar, navigator and menus need from the library goes
/// through here, and the widgets only see the small app models below. When the
/// library changes (or is upgraded), this is the only file to touch. Every call
/// is guarded, so a library change degrades a feature instead of crashing the
/// reader.
class QuranSurahInfo {
  final int number;
  final String name;
  final int ayahCount;
  final bool isMeccan;

  const QuranSurahInfo({
    required this.number,
    required this.name,
    required this.ayahCount,
    required this.isMeccan,
  });
}

class QuranAyahHit {
  final String surahName;
  final int ayahNumber;
  final int page;
  final String text;
  final int _uniqueNumber;

  const QuranAyahHit._({
    required this.surahName,
    required this.ayahNumber,
    required this.page,
    required this.text,
    required int uniqueNumber,
  }) : _uniqueNumber = uniqueNumber;
}

class QuranBookmarkInfo {
  final int id;
  final String name;
  final int page;
  final int ayahNumber;
  final Color color;
  final BookmarkModel _raw;

  const QuranBookmarkInfo._({
    required this.id,
    required this.name,
    required this.page,
    required this.ayahNumber,
    required this.color,
    required BookmarkModel raw,
  }) : _raw = raw;
}

class QuranReaderAdapter {
  QuranReaderAdapter._();

  static QuranLibrary get _library => QuranLibrary();

  // ---------------------------------------------------------------- data

  static List<QuranSurahInfo> surahs() {
    try {
      return QuranCtrl.instance.surahsList
          .map(
            (s) => QuranSurahInfo(
              number: s.number,
              name: s.name,
              ayahCount: s.ayahsNumber,
              isMeccan: s.revelationType.toLowerCase().contains('mecc'),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Page the reader is actually showing (the library's own state), or null.
  static int? get livePage {
    try {
      final page = QuranCtrl.instance.state.currentPageNumber.value;
      return page > 0 ? page : null;
    } catch (_) {
      return null;
    }
  }

  /// Surah the given page starts in, or -1 when it cannot be resolved.
  static int surahOfPage(int page) {
    try {
      return _library
          .getCurrentSurahDataByPageNumber(pageNumber: page)
          .surahNumber;
    } catch (e) {
      debugPrint('QuranReaderAdapter.surahOfPage($page) failed: $e');
    }
    // Fallback: surah of the first ayah on the page.
    try {
      final ayahs = _library.getPageAyahsByPageNumber(pageNumber: page);
      final surah = ayahs.isEmpty ? null : ayahs.first.surahNumber;
      if (surah != null) return surah;
    } catch (_) {}
    return -1;
  }

  static int? juzOfPage(int page) {
    try {
      return _library.getJuzByPageNumber(pageNumber: page).juz;
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------ navigation

  static void jumpToSurah(int number) {
    try {
      _library.jumpToSurah(number);
    } catch (_) {}
  }

  static void jumpToJuz(int number) {
    try {
      _library.jumpToJoz(number);
    } catch (_) {}
  }

  static void jumpToAyah(QuranAyahHit hit) {
    try {
      _library.jumpToAyah(hit.page, hit._uniqueNumber);
    } catch (_) {}
  }

  static void jumpToBookmark(QuranBookmarkInfo bookmark) {
    try {
      _library.jumpToBookmark(bookmark._raw);
    } catch (_) {}
  }

  // ---------------------------------------------------------------- search

  static List<QuranSurahInfo> searchSurahs(String text, {int limit = 6}) {
    try {
      return _library
          .surahSearch(text)
          .take(limit)
          .map(
            (s) => QuranSurahInfo(
              number: s.surahNumber,
              name: s.arabicName,
              ayahCount: s.ayahs.length,
              isMeccan: (s.revelationType ?? '').toLowerCase().contains('mecc'),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static List<QuranAyahHit> searchAyahs(String text, {int limit = 60}) {
    try {
      return _library
          .search(text)
          .take(limit)
          .map(
            (a) => QuranAyahHit._(
              surahName: a.arabicName ?? '',
              ayahNumber: a.ayahNumber,
              page: a.page,
              text: a.ayaTextEmlaey,
              uniqueNumber: a.ayahUQNumber,
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ------------------------------------------------------------- bookmarks

  static List<QuranBookmarkInfo> bookmarks() {
    try {
      return BookmarksCtrl.instance.bookmarks.values
          .expand((list) => list)
          .where((b) => b.page != -1)
          .map(
            (b) => QuranBookmarkInfo._(
              id: b.id,
              name: b.name,
              page: b.page,
              ayahNumber: b.ayahNumber,
              color: Color(b.colorCode),
              raw: b,
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static void removeBookmark(QuranBookmarkInfo bookmark) {
    try {
      _library.removeBookmark(bookmarkId: bookmark.id);
    } catch (_) {}
  }

  // ---------------------------------------------------------- reader state

  static bool get controlsVisible {
    try {
      return QuranCtrl.instance.isShowControl.value;
    } catch (_) {
      return true;
    }
  }

  /// Emits whether the reader controls (bar, audio slider) should be visible.
  static StreamSubscription<bool>? listenControlsVisible(
    void Function(bool visible) onChanged,
  ) {
    try {
      return QuranCtrl.instance.isShowControl.stream.listen(onChanged);
    } catch (_) {
      return null;
    }
  }

  static bool get isAutoScrolling {
    try {
      final state = AutoScrollCtrl.instance.state;
      return state.isActive.value && !state.isPaused.value;
    } catch (_) {
      return false;
    }
  }

  static List<StreamSubscription<bool>> listenAutoScrolling(
    void Function(bool running) onChanged,
  ) {
    try {
      final state = AutoScrollCtrl.instance.state;
      void emit(bool _) => onChanged(isAutoScrolling);
      return [
        state.isActive.stream.listen(emit),
        state.isPaused.stream.listen(emit),
      ];
    } catch (_) {
      return const [];
    }
  }

  static bool get isTasmeeActive {
    try {
      return TasmeeCtrl.instance.state.isTasmeeMode.value;
    } catch (_) {
      return false;
    }
  }

  static StreamSubscription<bool>? listenTasmee(
    void Function(bool active) onChanged,
  ) {
    try {
      return TasmeeCtrl.instance.state.isTasmeeMode.stream.listen(onChanged);
    } catch (_) {
      return null;
    }
  }

  // --------------------------------------------------------------- actions

  static void toggleTasmee() {
    try {
      QuranCtrl.instance.state.isShowMenu.value = false;
      TasmeeCtrl.instance.toggleTasmeeMode();
    } catch (_) {}
  }

  static void toggleAutoScroll() {
    try {
      final ctrl = AutoScrollCtrl.instance;
      if (ctrl.state.isActive.value) {
        ctrl.stopAutoScroll();
      } else {
        ctrl.startAutoScroll(QuranCtrl.instance.state.currentPageNumber.value);
      }
    } catch (_) {}
  }

  static Future<void> openSurahAudio(
    BuildContext context,
    QuranReaderPalette palette,
  ) async {
    try {
      await AudioCtrl.instance.state.audioPlayer.stop();
      QuranCtrl.instance.state.isShowMenu.value = false;
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SurahAudioScreen(
            isDark: palette.isDark,
            style: SurahAudioStyle.defaults(
              isDark: palette.isDark,
              context: context,
            ),
            languageCode: 'ar',
          ),
        ),
      );
    } catch (_) {}
  }

  static Future<void> openTajweedRules(
    BuildContext context,
    QuranReaderPalette palette,
  ) async {
    try {
      await showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: palette.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: TajweedMenuWidget(isDark: palette.isDark, languageCode: 'ar'),
        ),
      );
    } catch (_) {}
  }

  static Future<void> openRecitations(
    BuildContext context,
    QuranReaderPalette palette,
  ) async {
    try {
      final ref =
          WordInfoCtrl.instance.selectedWordRef.value ??
          const WordRef(surahNumber: 1, ayahNumber: 1, wordNumber: 1);
      await showWordInfoBottomSheet(
        context: context,
        ref: ref,
        initialKind: WordInfoKind.recitations,
        isDark: palette.isDark,
      );
    } catch (_) {}
  }

  static Future<void> openFonts(
    BuildContext context,
    QuranReaderPalette palette,
  ) async {
    try {
      await showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: palette.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: FontsDownloadWidget(
            languageCode: 'ar',
            isDark: palette.isDark,
            ctrl: QuranCtrl.instance,
          ),
        ),
      );
    } catch (_) {}
  }
}
