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

enum ShareTemplate {
  classic,
  luxury,
  spiritual;

  String get title {
    switch (this) {
      case ShareTemplate.classic:
        return 'الكلاسيكي الهادئ';
      case ShareTemplate.luxury:
        return 'الداكن الفاخر';
      case ShareTemplate.spiritual:
        return 'الروحاني الحديث';
    }
  }
}

enum AppThemeType { defaultTheme, desert, forest }

/// حالة الإعدادات الشاملة
class SettingsState {
  final ThemeMode themeMode;
  final AppThemeType appTheme;
  final bool notificationsEnabled;
  final String languageCode;
  final double fontSize;
  final List<HomeSection> homeSections;
  final ShareTemplate shareTemplate;

  SettingsState({
    required this.themeMode,
    this.appTheme = AppThemeType.defaultTheme,
    this.notificationsEnabled = true,
    this.languageCode = 'ar',
    this.fontSize = 16.0,
    required this.homeSections,
    this.shareTemplate = ShareTemplate.classic,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    AppThemeType? appTheme,
    bool? notificationsEnabled,
    String? languageCode,
    double? fontSize,
    List<HomeSection>? homeSections,
    ShareTemplate? shareTemplate,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      appTheme: appTheme ?? this.appTheme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      languageCode: languageCode ?? this.languageCode,
      fontSize: fontSize ?? this.fontSize,
      homeSections: homeSections ?? this.homeSections,
      shareTemplate: shareTemplate ?? this.shareTemplate,
    );
  }
}

/// المزود الخاص بالإعدادات
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
    : super(
        SettingsState(
          themeMode: _getInitialTheme(),
          appTheme: _getInitialAppTheme(),
          fontSize: CacheHelper.getData(key: 'fontSize') ?? 16.0,
          homeSections: _getInitialHomeSections(),
          notificationsEnabled:
              CacheHelper.getData(key: 'notificationsEnabled') ?? true,
          shareTemplate: _getInitialShareTemplate(),
        ),
      );

  static ThemeMode _getInitialTheme() {
    final String? theme = CacheHelper.getData(key: 'themeMode');
    if (theme == 'light') return ThemeMode.light;
    if (theme == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  static AppThemeType _getInitialAppTheme() {
    final String? theme = CacheHelper.getData(key: 'appTheme');
    if (theme == null) return AppThemeType.defaultTheme;
    return AppThemeType.values.firstWhere(
      (e) => e.name == theme,
      orElse: () => AppThemeType.defaultTheme,
    );
  }

  static List<HomeSection> _getInitialHomeSections() {
    final List<dynamic>? saved = CacheHelper.getData(key: 'homeSections');
    if (saved == null) {
      return HomeSection.values;
    }
    return saved
        .map(
          (e) => HomeSection.values.firstWhere(
            (element) => element.name == e,
            orElse: () => HomeSection.prayerTimes,
          ),
        )
        .toList();
  }

  static ShareTemplate _getInitialShareTemplate() {
    final String? template = CacheHelper.getData(key: 'shareTemplate');
    if (template == null) return ShareTemplate.classic;
    return ShareTemplate.values.firstWhere(
      (e) => e.name == template,
      orElse: () => ShareTemplate.classic,
    );
  }

  void toggleTheme(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    CacheHelper.saveData(key: 'themeMode', value: mode.name);
  }

  void updateAppTheme(AppThemeType theme) {
    state = state.copyWith(appTheme: theme);
    CacheHelper.saveData(key: 'appTheme', value: theme.name);
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

  void updateShareTemplate(ShareTemplate template) {
    state = state.copyWith(shareTemplate: template);
    CacheHelper.saveData(key: 'shareTemplate', value: template.name);
  }
}
