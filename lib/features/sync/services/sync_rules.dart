/// How a saved key is combined when the phone and the account disagree.
enum SyncKind {
  /// The side that changed it last wins.
  latestWins,

  /// A day of the habit tracker: both sides' ticks are kept.
  habitDay,

  /// The larger number wins (best streak never goes down).
  maxNumber,
}

/// Which local keys are backed up, and how. Everything not listed here stays
/// on the device: counters of app opens, review dates, "new" badge state,
/// downloaded fonts, and the stored location (handled on its own).
class SyncRules {
  SyncRules._();

  static const String habitDayPrefix = 'habit_';

  /// Keys that make up the stored location. They are synced as one place.
  static const String latKey = 'cached_lat';
  static const String lngKey = 'cached_lng';
  static const String cityKey = 'cached_city';
  static const String districtKey = 'cached_district';
  static const Set<String> locationKeys = {
    latKey,
    lngKey,
    cityKey,
    districtKey,
  };

  static const Set<String> _latestWins = {
    // Look and reading
    'themeMode',
    'appTheme',
    'fontSize',
    'azkarLayout',
    'homeSections',
    'shareTemplate',
    'shareCardRatio',
    'shareCardSignature',
    // How prayer times are calculated
    'prayer_method',
    'prayer_madhab',
    'prayer_high_lat',
    'prayer_ramadan_isha',
    // Reminders and athan
    'notificationsEnabled',
    'morning_notification_enabled',
    'morning_notification_time',
    'evening_notification_enabled',
    'evening_notification_time',
    'friday_notification_enabled',
    'wird_notification_enabled',
    'wird_notification_time',
    'athan_enabled',
    'fajr_athan_enabled',
    'dhuhr_athan_enabled',
    'asr_athan_enabled',
    'maghrib_athan_enabled',
    'isha_athan_enabled',
    'durood_interval_minutes',
    // Content the user made
    'user_azkar_list',
    // Quran
    'pageNumber',
    'quranReadingTheme',
    // Misbaha
    'misbaha_total_count',
    'misbaha_bead_type',
    'misbaha_target',
    // Radio
    'radio_favorites',
    'radio_last_station',
    // Guides
    'umrah_checklist',
    'hajj_checklist',
  };

  static const List<String> _latestWinsPrefixes = [
    'misbaha_zikr_',
    'prayer_adj_',
  ];

  /// Best streak only ever grows. (The all-time points are recomputed from
  /// the saved days on every start, so they are not stored in the account.)
  static const Set<String> _maxNumber = {'habitBestStreak'};

  /// The kind of [key], or null when it must not leave the device.
  static SyncKind? kindOf(String key) {
    if (_latestWins.contains(key)) return SyncKind.latestWins;
    for (final prefix in _latestWinsPrefixes) {
      if (key.startsWith(prefix)) return SyncKind.latestWins;
    }
    if (_maxNumber.contains(key)) return SyncKind.maxNumber;
    if (key.startsWith(habitDayPrefix)) return SyncKind.habitDay;
    return null;
  }

  /// Keys whose change time is worth recording. Habit days are merged by
  /// content, so they need no stamp.
  static bool needsStamp(String key) {
    final kind = kindOf(key);
    return locationKeys.contains(key) ||
        kind == SyncKind.latestWins ||
        kind == SyncKind.maxNumber;
  }
}
