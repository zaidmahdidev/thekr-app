import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';

/// How prayer times are calculated. These are the methods the `adhan` library
/// offers; the screens only use this enum, never the library.
enum PrayerCalcMethod {
  ummAlQura(
    title: 'أم القرى (مكة المكرمة)',
    detail: 'الفجر 18.5° والعشاء بعد المغرب بـ 90 دقيقة',
  ),
  muslimWorldLeague(
    title: 'رابطة العالم الإسلامي',
    detail: 'الفجر 18° والعشاء 17°',
  ),
  egyptian(
    title: 'الهيئة المصرية العامة للمساحة',
    detail: 'الفجر 19.5° والعشاء 17.5°',
  ),
  karachi(
    title: 'جامعة العلوم الإسلامية - كراتشي',
    detail: 'الفجر 18° والعشاء 18°',
  ),
  northAmerica(
    title: 'أمريكا الشمالية (ISNA)',
    detail: 'الفجر 15° والعشاء 15°',
  ),
  dubai(title: 'دبي', detail: 'الفجر 18.2° والعشاء 18.2°'),
  kuwait(title: 'الكويت', detail: 'الفجر 18° والعشاء 17.5°'),
  qatar(
    title: 'قطر',
    detail: 'الفجر 18° والعشاء بعد المغرب بـ 90 دقيقة',
  ),
  singapore(title: 'سنغافورة', detail: 'الفجر 20° والعشاء 18°'),
  turkey(
    title: 'تركيا (رئاسة الشؤون الدينية)',
    detail: 'الفجر 18° والعشاء 17°',
  ),
  tehran(
    title: 'طهران (معهد الجيوفيزياء)',
    detail: 'الفجر 17.7° والعشاء 14° والمغرب 4.5°',
  ),
  moonSighting(
    title: 'لجنة رؤية الهلال',
    detail: 'الفجر 18° والعشاء 18°',
  );

  const PrayerCalcMethod({required this.title, required this.detail});

  final String title;

  /// The angles it uses, shown under the name.
  final String detail;
}

/// Which shadow length decides the start of Asr.
enum AsrMadhab {
  jumhur(
    title: 'الجمهور',
    detail: 'الشافعي والمالكي والحنبلي: ظل الشيء مثله',
  ),
  hanafi(title: 'الحنفي', detail: 'ظل الشيء مثليه، فيتأخر وقت العصر');

  const AsrMadhab({required this.title, required this.detail});

  final String title;
  final String detail;
}

/// How Fajr and Isha are limited where the night is very short (far north).
enum HighLatitudeMode {
  middleOfNight(title: 'منتصف الليل', detail: 'الفجر والعشاء لا يتجاوزان منتصف الليل'),
  seventhOfNight(title: 'سُبع الليل', detail: 'يُحدَّد بسُبع الليل من أوله وآخره'),
  twilightAngle(title: 'زاوية الشفق', detail: 'نسبة الزاوية إلى 60° من الليل');

  const HighLatitudeMode({required this.title, required this.detail});

  final String title;
  final String detail;
}

/// The user's choices for calculating prayer times. The defaults are exactly
/// what the app always used, so nobody's times change until they choose.
class PrayerCalcSettings {
  const PrayerCalcSettings({
    this.method = PrayerCalcMethod.ummAlQura,
    this.madhab = AsrMadhab.jumhur,
    this.highLatitude = HighLatitudeMode.middleOfNight,
    this.adjustments = const {},
    this.ramadanIsha = true,
  });

  final PrayerCalcMethod method;
  final AsrMadhab madhab;
  final HighLatitudeMode highLatitude;

  /// Minutes added to (or taken from) each prayer, to match a local mosque.
  final Map<AppPrayer, int> adjustments;

  /// Umm al-Qura only: Isha is 120 minutes after Maghrib in Ramadan instead of
  /// 90, as the official calendar says.
  final bool ramadanIsha;

  static const int maxAdjustment = 30;

  int adjustmentOf(AppPrayer prayer) => adjustments[prayer] ?? 0;

  bool get hasAdjustments => adjustments.values.any((m) => m != 0);

  /// True when everything is as the app was before this setting existed.
  bool get isDefault =>
      method == PrayerCalcMethod.ummAlQura &&
      madhab == AsrMadhab.jumhur &&
      highLatitude == HighLatitudeMode.middleOfNight &&
      !hasAdjustments &&
      ramadanIsha;

  PrayerCalcSettings copyWith({
    PrayerCalcMethod? method,
    AsrMadhab? madhab,
    HighLatitudeMode? highLatitude,
    Map<AppPrayer, int>? adjustments,
    bool? ramadanIsha,
  }) {
    return PrayerCalcSettings(
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
      highLatitude: highLatitude ?? this.highLatitude,
      adjustments: adjustments ?? this.adjustments,
      ramadanIsha: ramadanIsha ?? this.ramadanIsha,
    );
  }

  PrayerCalcSettings withAdjustment(AppPrayer prayer, int minutes) {
    final clamped = minutes.clamp(-maxAdjustment, maxAdjustment);
    return copyWith(adjustments: {...adjustments, prayer: clamped});
  }

  // ---------------------------------------------------------------- storage

  static const String methodKey = 'prayer_method';
  static const String madhabKey = 'prayer_madhab';
  static const String highLatitudeKey = 'prayer_high_lat';
  static const String ramadanIshaKey = 'prayer_ramadan_isha';
  static const String adjustmentPrefix = 'prayer_adj_';

  static String adjustmentKey(AppPrayer prayer) =>
      '$adjustmentPrefix${prayer.name}';

  /// Reads the saved choices; anything missing or unknown falls back to the
  /// default, so an old or damaged value never breaks the prayer times.
  static PrayerCalcSettings load() {
    T pick<T extends Enum>(List<T> values, String key, T fallback) {
      final saved = CacheHelper.getData(key: key);
      for (final value in values) {
        if (value.name == saved) return value;
      }
      return fallback;
    }

    final adjustments = <AppPrayer, int>{};
    for (final prayer in AppPrayer.values) {
      final saved = CacheHelper.getData(key: adjustmentKey(prayer));
      if (saved is int && saved != 0) {
        adjustments[prayer] = saved.clamp(-maxAdjustment, maxAdjustment);
      }
    }

    final ramadan = CacheHelper.getData(key: ramadanIshaKey);
    return PrayerCalcSettings(
      method: pick(PrayerCalcMethod.values, methodKey, PrayerCalcMethod.ummAlQura),
      madhab: pick(AsrMadhab.values, madhabKey, AsrMadhab.jumhur),
      highLatitude: pick(
        HighLatitudeMode.values,
        highLatitudeKey,
        HighLatitudeMode.middleOfNight,
      ),
      adjustments: adjustments,
      ramadanIsha: ramadan is bool ? ramadan : true,
    );
  }

  Future<void> save() async {
    await CacheHelper.saveData(key: methodKey, value: method.name);
    await CacheHelper.saveData(key: madhabKey, value: madhab.name);
    await CacheHelper.saveData(key: highLatitudeKey, value: highLatitude.name);
    await CacheHelper.saveData(key: ramadanIshaKey, value: ramadanIsha);
    for (final prayer in AppPrayer.values) {
      await CacheHelper.saveData(
        key: adjustmentKey(prayer),
        value: adjustmentOf(prayer),
      );
    }
  }
}
