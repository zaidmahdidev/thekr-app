import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';

/// حالة الإعدادات الشاملة
class SettingsState {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String languageCode;

  SettingsState({
    required this.themeMode,
    this.notificationsEnabled = true,
    this.languageCode = 'ar',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? languageCode,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

/// المزود الخاص بالإعدادات
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState(themeMode: ThemeMode.light)) {
    _loadSettings();
  }

  static const String _themeKey = 'isDarkMode';
  static const String _notificationsKey = 'notificationsEnabled';

  void _loadSettings() {
    final bool? isDark = CacheHelper.getData(key: _themeKey);
    final bool? notifications = CacheHelper.getData(key: _notificationsKey);

    state = state.copyWith(
      themeMode: isDark == null 
          ? ThemeMode.light 
          : (isDark ? ThemeMode.dark : ThemeMode.light),
      notificationsEnabled: notifications ?? true,
    );
  }

  /// تبديل الثيم
  Future<void> toggleTheme(bool isDark) async {
    state = state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light);
    await CacheHelper.saveData(key: _themeKey, value: isDark);
  }

  /// تبديل التنبيهات
  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await CacheHelper.saveData(key: _notificationsKey, value: enabled);
  }
}
