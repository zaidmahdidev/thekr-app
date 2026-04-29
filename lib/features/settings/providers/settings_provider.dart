import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';

enum HomeSection {
  prayerTimes,
  inspiration,
  features,
  dynamicSections,
  shareCard;

  String get title {
    switch (this) {
      case HomeSection.prayerTimes:
        return 'مواقيت الصلاة';
      case HomeSection.inspiration:
        return 'إلهامات يومية';
      case HomeSection.features:
        return 'الخدمات الأساسية';
      case HomeSection.dynamicSections:
        return 'أقسام متنوعة (الجمعة/الصيام)';
      case HomeSection.shareCard:
        return 'مشاركة التطبيق';
    }
  }
}

/// حالة الإعدادات الشاملة
class SettingsState {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String languageCode;
  final double fontSize;
  final List<HomeSection> homeSections;

  SettingsState({
    required this.themeMode,
    this.notificationsEnabled = true,
    this.languageCode = 'ar',
    this.fontSize = 18.0,
    required this.homeSections,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? languageCode,
    double? fontSize,
    List<HomeSection>? homeSections,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      languageCode: languageCode ?? this.languageCode,
      fontSize: fontSize ?? this.fontSize,
      homeSections: homeSections ?? this.homeSections,
    );
  }
}

/// المزود الخاص بالإعدادات
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(SettingsState(
          themeMode: _getInitialTheme(),
          fontSize: CacheHelper.getData(key: 'fontSize') ?? 18.0,
          homeSections: _getInitialHomeSections(),
          notificationsEnabled: CacheHelper.getData(key: 'notificationsEnabled') ?? true,
        ));

  static ThemeMode _getInitialTheme() {
    final String? theme = CacheHelper.getData(key: 'themeMode');
    if (theme == 'light') return ThemeMode.light;
    if (theme == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  static List<HomeSection> _getInitialHomeSections() {
    final List<dynamic>? saved = CacheHelper.getData(key: 'homeSections');
    if (saved == null) {
      return HomeSection.values;
    }
    return saved
        .map((e) => HomeSection.values.firstWhere(
              (element) => element.name == e,
              orElse: () => HomeSection.prayerTimes,
            ))
        .toList();
  }

  void toggleTheme(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    CacheHelper.saveData(key: 'themeMode', value: mode.name);
  }

  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    CacheHelper.saveData(key: 'notificationsEnabled', value: enabled);
  }

  void updateFontSize(double size) {
    state = state.copyWith(fontSize: size);
    CacheHelper.saveData(key: 'fontSize', value: size);
  }

  void reorderHomeSections(List<HomeSection> sections) {
    state = state.copyWith(homeSections: sections);
    CacheHelper.saveData(
      key: 'homeSections',
      value: sections.map((e) => e.name).toList(),
    );
  }
}
