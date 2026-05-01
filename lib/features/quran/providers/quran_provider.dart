import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';

class QuranState {
  final int currentPage;
  final bool isCapturing;
  final bool isDarkMode;

  QuranState({
    required this.currentPage,
    this.isCapturing = false,
    this.isDarkMode = false,
  });

  QuranState copyWith({
    int? currentPage,
    bool? isCapturing,
    bool? isDarkMode,
  }) {
    return QuranState(
      currentPage: currentPage ?? this.currentPage,
      isCapturing: isCapturing ?? this.isCapturing,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class QuranNotifier extends StateNotifier<QuranState> {
  QuranNotifier(int initialPage) : super(QuranState(
    currentPage: initialPage,
    isDarkMode: CacheHelper.getData(key: 'quran_is_dark') ?? false,
  ));

  static const _lastPageKey = 'pageNumber';
  static const _isDarkKey = 'isDarkMode';

  Future<void> updatePage(int page) async {
    state = state.copyWith(currentPage: page);
    await _persistPage(page);
  }

  void toggleDarkMode() {
    final newValue = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newValue);
    CacheHelper.saveData(key: _isDarkKey, value: newValue);
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
