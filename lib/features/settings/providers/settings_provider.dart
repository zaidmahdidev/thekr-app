import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/notification_service.dart';

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
  final bool morningNotificationEnabled;
  final TimeOfDay morningNotificationTime;
  final bool eveningNotificationEnabled;
  final TimeOfDay eveningNotificationTime;
  final bool fridayNotificationEnabled;
  final bool wirdNotificationEnabled;
  final TimeOfDay wirdNotificationTime;
  final bool fajrAthanEnabled;
  final bool dhuhrAthanEnabled;
  final bool asrAthanEnabled;
  final bool maghribAthanEnabled;
  final bool ishaAthanEnabled;
  final String languageCode;
  final double fontSize;
  final List<HomeSection> homeSections;
  final ShareTemplate shareTemplate;

  SettingsState({
    required this.themeMode,
    this.appTheme = AppThemeType.defaultTheme,
    this.notificationsEnabled = true,
    this.morningNotificationEnabled = true,
    this.morningNotificationTime = const TimeOfDay(hour: 6, minute: 0),
    this.eveningNotificationEnabled = true,
    this.eveningNotificationTime = const TimeOfDay(hour: 18, minute: 0),
    this.fridayNotificationEnabled = true,
    this.wirdNotificationEnabled = false,
    this.wirdNotificationTime = const TimeOfDay(hour: 21, minute: 0),
    this.fajrAthanEnabled = true,
    this.dhuhrAthanEnabled = true,
    this.asrAthanEnabled = true,
    this.maghribAthanEnabled = true,
    this.ishaAthanEnabled = true,
    this.languageCode = 'ar',
    this.fontSize = 16.0,
    required this.homeSections,
    this.shareTemplate = ShareTemplate.classic,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    AppThemeType? appTheme,
    bool? notificationsEnabled,
    bool? morningNotificationEnabled,
    TimeOfDay? morningNotificationTime,
    bool? eveningNotificationEnabled,
    TimeOfDay? eveningNotificationTime,
    bool? fridayNotificationEnabled,
    bool? wirdNotificationEnabled,
    TimeOfDay? wirdNotificationTime,
    bool? fajrAthanEnabled,
    bool? dhuhrAthanEnabled,
    bool? asrAthanEnabled,
    bool? maghribAthanEnabled,
    bool? ishaAthanEnabled,
    String? languageCode,
    double? fontSize,
    List<HomeSection>? homeSections,
    ShareTemplate? shareTemplate,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      appTheme: appTheme ?? this.appTheme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      morningNotificationEnabled:
          morningNotificationEnabled ?? this.morningNotificationEnabled,
      morningNotificationTime:
          morningNotificationTime ?? this.morningNotificationTime,
      eveningNotificationEnabled:
          eveningNotificationEnabled ?? this.eveningNotificationEnabled,
      eveningNotificationTime:
          eveningNotificationTime ?? this.eveningNotificationTime,
      fridayNotificationEnabled:
          fridayNotificationEnabled ?? this.fridayNotificationEnabled,
      wirdNotificationEnabled:
          wirdNotificationEnabled ?? this.wirdNotificationEnabled,
      wirdNotificationTime: wirdNotificationTime ?? this.wirdNotificationTime,
      fajrAthanEnabled: fajrAthanEnabled ?? this.fajrAthanEnabled,
      dhuhrAthanEnabled: dhuhrAthanEnabled ?? this.dhuhrAthanEnabled,
      asrAthanEnabled: asrAthanEnabled ?? this.asrAthanEnabled,
      maghribAthanEnabled: maghribAthanEnabled ?? this.maghribAthanEnabled,
      ishaAthanEnabled: ishaAthanEnabled ?? this.ishaAthanEnabled,
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
          morningNotificationEnabled:
              CacheHelper.getData(key: 'morning_notification_enabled') ?? true,
          morningNotificationTime: _getInitialTime(
            'morning_notification_time',
            const TimeOfDay(hour: 6, minute: 0),
          ),
          eveningNotificationEnabled:
              CacheHelper.getData(key: 'evening_notification_enabled') ?? true,
          eveningNotificationTime: _getInitialTime(
            'evening_notification_time',
            const TimeOfDay(hour: 18, minute: 0),
          ),
          fridayNotificationEnabled:
              CacheHelper.getData(key: 'friday_notification_enabled') ?? true,
          wirdNotificationEnabled:
              CacheHelper.getData(key: 'wird_notification_enabled') ?? false,
          wirdNotificationTime: _getInitialTime(
            'wird_notification_time',
            const TimeOfDay(hour: 21, minute: 0),
          ),
          fajrAthanEnabled: CacheHelper.getData(key: 'fajr_athan_enabled') ?? true,
          dhuhrAthanEnabled: CacheHelper.getData(key: 'dhuhr_athan_enabled') ?? true,
          asrAthanEnabled: CacheHelper.getData(key: 'asr_athan_enabled') ?? true,
          maghribAthanEnabled: CacheHelper.getData(key: 'maghrib_athan_enabled') ?? true,
          ishaAthanEnabled: CacheHelper.getData(key: 'isha_athan_enabled') ?? true,
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
    try {
      final dynamic theme = CacheHelper.getData(key: 'appTheme');
      if (theme == null || theme is! String) return AppThemeType.defaultTheme;
      return AppThemeType.values.firstWhere(
        (e) => e.name == theme,
        orElse: () => AppThemeType.defaultTheme,
      );
    } catch (_) {
      return AppThemeType.defaultTheme;
    }
  }

  static List<HomeSection> _getInitialHomeSections() {
    try {
      final dynamic saved = CacheHelper.getData(key: 'homeSections');
      if (saved == null || saved is! List) {
        return HomeSection.values;
      }
      return saved
          .map(
            (e) => HomeSection.values.firstWhere(
              (element) => element.name == e.toString(),
              orElse: () => HomeSection.prayerTimes,
            ),
          )
          .whereType<HomeSection>()
          .toList();
    } catch (_) {
      return HomeSection.values;
    }
  }

  static TimeOfDay _getInitialTime(String key, TimeOfDay defaultTime) {
    final dynamic saved = CacheHelper.getData(key: key);
    if (saved == null || saved is! String) return defaultTime;
    try {
      final parts = saved.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return defaultTime;
    }
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

  void toggleMorningNotification(bool enabled) {
    state = state.copyWith(morningNotificationEnabled: enabled);
    CacheHelper.saveData(key: 'morning_notification_enabled', value: enabled);
    if (enabled) {
      NotificationService.scheduleMorningAzkar(state.morningNotificationTime);
    } else {
      NotificationService.cancelMorningNotification();
    }
  }

  void updateMorningTime(TimeOfDay time) {
    state = state.copyWith(morningNotificationTime: time);
    CacheHelper.saveData(
      key: 'morning_notification_time',
      value: '${time.hour}:${time.minute}',
    );
    if (state.morningNotificationEnabled) {
      NotificationService.scheduleMorningAzkar(time);
    }
  }

  void toggleEveningNotification(bool enabled) {
    state = state.copyWith(eveningNotificationEnabled: enabled);
    CacheHelper.saveData(key: 'evening_notification_enabled', value: enabled);
    if (enabled) {
      NotificationService.scheduleEveningAzkar(state.eveningNotificationTime);
    } else {
      NotificationService.cancelEveningNotification();
    }
  }

  void updateEveningTime(TimeOfDay time) {
    state = state.copyWith(eveningNotificationTime: time);
    CacheHelper.saveData(
      key: 'evening_notification_time',
      value: '${time.hour}:${time.minute}',
    );
    if (state.eveningNotificationEnabled) {
      NotificationService.scheduleEveningAzkar(time);
    }
  }

  void toggleFridayNotification(bool enabled) {
    state = state.copyWith(fridayNotificationEnabled: enabled);
    CacheHelper.saveData(key: 'friday_notification_enabled', value: enabled);
    if (enabled) {
      NotificationService.scheduleFridayKahf(
        const TimeOfDay(hour: 8, minute: 0),
      );
    } else {
      NotificationService.cancelFridayNotification();
    }
  }

  void toggleWirdNotification(bool enabled) {
    state = state.copyWith(wirdNotificationEnabled: enabled);
    CacheHelper.saveData(key: 'wird_notification_enabled', value: enabled);

    if (enabled) {
      NotificationService.scheduleWirdNotification(state.wirdNotificationTime);
    } else {
      NotificationService.cancelWirdNotification();
    }
  }

  void updateWirdTime(TimeOfDay time) {
    state = state.copyWith(wirdNotificationTime: time);
    CacheHelper.saveData(
      key: 'wird_notification_time',
      value: '${time.hour}:${time.minute}',
    );

    if (state.wirdNotificationEnabled) {
      NotificationService.scheduleWirdNotification(time);
    }
  }

  void toggleFajrAthan(bool enabled) {
    state = state.copyWith(fajrAthanEnabled: enabled);
    CacheHelper.saveData(key: 'fajr_athan_enabled', value: enabled);
  }

  void toggleDhuhrAthan(bool enabled) {
    state = state.copyWith(dhuhrAthanEnabled: enabled);
    CacheHelper.saveData(key: 'dhuhr_athan_enabled', value: enabled);
  }

  void toggleAsrAthan(bool enabled) {
    state = state.copyWith(asrAthanEnabled: enabled);
    CacheHelper.saveData(key: 'asr_athan_enabled', value: enabled);
  }

  void toggleMaghribAthan(bool enabled) {
    state = state.copyWith(maghribAthanEnabled: enabled);
    CacheHelper.saveData(key: 'maghrib_athan_enabled', value: enabled);
  }

  void toggleIshaAthan(bool enabled) {
    state = state.copyWith(ishaAthanEnabled: enabled);
    CacheHelper.saveData(key: 'isha_athan_enabled', value: enabled);
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
