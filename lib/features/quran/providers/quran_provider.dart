import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';

enum QuranTheme { light, dark, sepia, green, blueGrey }

class QuranState {
  final int currentPage;
  final bool isCapturing;
  final QuranTheme readingTheme;

  QuranState({
    required this.currentPage,
    this.isCapturing = false,
    this.readingTheme = QuranTheme.light,
  });

  bool get isDarkMode => readingTheme == QuranTheme.dark || readingTheme == QuranTheme.blueGrey;

  QuranState copyWith({
    int? currentPage,
    bool? isCapturing,
    QuranTheme? readingTheme,
  }) {
    return QuranState(
      currentPage: currentPage ?? this.currentPage,
      isCapturing: isCapturing ?? this.isCapturing,
      readingTheme: readingTheme ?? this.readingTheme,
    );
  }
}

class QuranNotifier extends StateNotifier<QuranState> {
  QuranNotifier(int initialPage)
      : super(QuranState(
          currentPage: initialPage,
          readingTheme: _getInitialTheme(),
        ));

  static const _lastPageKey = 'pageNumber';
  static const _themeKey = 'quranReadingTheme';

  static QuranTheme _getInitialTheme() {
    final themeIndex = CacheHelper.getData(key: _themeKey);
    if (themeIndex != null && themeIndex < QuranTheme.values.length) {
      return QuranTheme.values[themeIndex];
    }
    return PlatformDispatcher.instance.platformBrightness == Brightness.dark
        ? QuranTheme.dark
        : QuranTheme.light;
  }

  Future<void> updatePage(int page) async {
    state = state.copyWith(currentPage: page);
    await _persistPage(page);
  }

  void setTheme(QuranTheme theme) {
    state = state.copyWith(readingTheme: theme);
    CacheHelper.saveData(key: _themeKey, value: theme.index);
  }

  void setCapturing(bool capturing) {
    state = state.copyWith(isCapturing: capturing);
  }

  Future<void> _persistPage(int page) async {
    await CacheHelper.saveData(key: _lastPageKey, value: page);
  }

  Future<void> saveCurrentProgress() async {
    await _persistPage(state.currentPage);
  }
}

final quranProvider = StateNotifierProvider.family<QuranNotifier, QuranState, int>((ref, initialPage) {
  return QuranNotifier(initialPage);
});
