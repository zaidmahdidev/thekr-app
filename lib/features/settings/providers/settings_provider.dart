import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';

/// حالة الإعدادات الشاملة
class SettingsState {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String languageCode;
  final double fontSize;

  SettingsState({
    required this.themeMode,
    this.notificationsEnabled = true,
    this.languageCode = 'ar',
    this.fontSize = 18.0,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? languageCode,
    double? fontSize,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      languageCode: languageCode ?? this.languageCode,
      fontSize: fontSize ?? this.fontSize,
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
  static const String _fontSizeKey = 'fontSize';

  void _loadSettings() {
    final bool? isDark = CacheHelper.getData(key: _themeKey);
    final bool? notifications = CacheHelper.getData(key: _notificationsKey);
    final double? fontSize = CacheHelper.getData(key: _fontSizeKey);

    state = state.copyWith(
      themeMode: isDark == null 
          ? ThemeMode.light 
          : (isDark ? ThemeMode.dark : ThemeMode.light),
      notificationsEnabled: notifications ?? true,
      fontSize: fontSize ?? 18.0,
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

  /// تحديث حجم الخط
  Future<void> updateFontSize(double newSize) async {
    state = state.copyWith(fontSize: newSize);
    await CacheHelper.saveData(key: _fontSizeKey, value: newSize);
  }
}
