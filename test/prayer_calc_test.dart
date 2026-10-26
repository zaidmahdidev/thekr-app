import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/prayer_service.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:thekr_app/features/prayer_times/models/prayer_calc_settings.dart';

PrayerLocation _riyadh() => PrayerLocation(
  coordinates: Coordinates(24.7136, 46.6753),
  isDefault: false,
  isPermissionOff: false,
);

int _minutes(Duration d) => d.inMinutes;

/// A day of Ramadan 1448 (February 2027) and one outside it.
DateTime _ramadanDay() {
  for (var d = DateTime(2027, 2, 1); d.isBefore(DateTime(2027, 4, 1)); d = d.add(const Duration(days: 1))) {
    if (PrayerService.isRamadan(d)) return d.add(const Duration(days: 8));
  }
  throw StateError('no Ramadan day found');
}

void main() {
  final date = DateTime(2026, 10, 25);

  group('defaults keep the old times', () {
    test('default settings give exactly Umm al-Qura with the Shafi Asr', () {
      final ours = PrayerService.timesFor(
        date,
        _riyadh(),
        settings: const PrayerCalcSettings(),
      );

      final params = CalculationMethod.umm_al_qura.getParameters()
        ..madhab = Madhab.shafi;
      final reference = PrayerTimes(
        Coordinates(24.7136, 46.6753),
        DateComponents.from(date),
        params,
      );

      expect(ours.fajr, reference.fajr);
      expect(ours.dhuhr, reference.dhuhr);
      expect(ours.asr, reference.asr);
      expect(ours.maghrib, reference.maghrib);
      expect(ours.isha, reference.isha);
      expect(const PrayerCalcSettings().isDefault, true);
    });
  });

  group('choices change the times', () {
    test('Hanafi Asr is later than the Jumhur Asr', () {
      final jumhur = PrayerService.timesFor(
        date,
        _riyadh(),
        settings: const PrayerCalcSettings(),
      );
      final hanafi = PrayerService.timesFor(
        date,
        _riyadh(),
        settings: const PrayerCalcSettings(madhab: AsrMadhab.hanafi),
      );
      expect(hanafi.asr.isAfter(jumhur.asr), true);
      expect(_minutes(hanafi.asr.difference(jumhur.asr)), greaterThan(30));
      // Nothing else moves.
      expect(hanafi.fajr, jumhur.fajr);
      expect(hanafi.maghrib, jumhur.maghrib);
    });

    test('a method with other angles moves Fajr', () {
      final umm = PrayerService.timesFor(date, _riyadh(), settings: const PrayerCalcSettings());
      final egypt = PrayerService.timesFor(
        date,
        _riyadh(),
        settings: const PrayerCalcSettings(method: PrayerCalcMethod.egyptian),
      );
      expect(egypt.fajr.isBefore(umm.fajr), true); // 19.5° starts earlier than 18.5°
    });

    test('every method gives the six times in order', () {
      for (final method in PrayerCalcMethod.values) {
        final t = PrayerService.timesFor(
          date,
          _riyadh(),
          settings: PrayerCalcSettings(method: method),
        );
        final order = [t.fajr, t.sunrise, t.dhuhr, t.asr, t.maghrib, t.isha];
        for (var i = 1; i < order.length; i++) {
          expect(order[i].isAfter(order[i - 1]), true, reason: '${method.name} #$i');
        }
      }
    });

    test('a manual adjustment moves only that prayer, by those minutes', () {
      final base = PrayerService.timesFor(date, _riyadh(), settings: const PrayerCalcSettings());
      final moved = PrayerService.timesFor(
        date,
        _riyadh(),
        settings: const PrayerCalcSettings().withAdjustment(AppPrayer.fajr, 5).withAdjustment(AppPrayer.isha, -3),
      );
      expect(moved.fajr.difference(base.fajr), const Duration(minutes: 5));
      expect(moved.isha.difference(base.isha), const Duration(minutes: -3));
      expect(moved.dhuhr, base.dhuhr);
      expect(moved.asr, base.asr);
    });

    test('adjustments are limited to thirty minutes', () {
      final s = const PrayerCalcSettings().withAdjustment(AppPrayer.asr, 99);
      expect(s.adjustmentOf(AppPrayer.asr), PrayerCalcSettings.maxAdjustment);
      final low = s.withAdjustment(AppPrayer.asr, -99);
      expect(low.adjustmentOf(AppPrayer.asr), -PrayerCalcSettings.maxAdjustment);
    });
  });

  group('Ramadan Isha (Umm al-Qura)', () {
    test('is 120 minutes after Maghrib in Ramadan, 90 otherwise', () {
      final ramadan = _ramadanDay();
      expect(PrayerService.isRamadan(ramadan), true);

      final inRamadan = PrayerService.timesFor(ramadan, _riyadh(), settings: const PrayerCalcSettings());
      expect(_minutes(inRamadan.isha.difference(inRamadan.maghrib)), 120);

      final outside = PrayerService.timesFor(date, _riyadh(), settings: const PrayerCalcSettings());
      expect(PrayerService.isRamadan(date), false);
      expect(_minutes(outside.isha.difference(outside.maghrib)), 90);
    });

    test('the switch turns it off', () {
      final t = PrayerService.timesFor(
        _ramadanDay(),
        _riyadh(),
        settings: const PrayerCalcSettings(ramadanIsha: false),
      );
      expect(_minutes(t.isha.difference(t.maghrib)), 90);
    });

    test('does not touch other methods', () {
      final t = PrayerService.timesFor(
        _ramadanDay(),
        _riyadh(),
        settings: const PrayerCalcSettings(method: PrayerCalcMethod.muslimWorldLeague),
      );
      // An angle method: Isha is not tied to Maghrib by a fixed interval.
      expect(_minutes(t.isha.difference(t.maghrib)), isNot(120));
    });
  });

  group('saving', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await CacheHelper.init();
    });

    test('nothing saved means the defaults', () {
      final s = PrayerCalcSettings.load();
      expect(s.isDefault, true);
    });

    test('what is saved is loaded back', () async {
      final chosen = const PrayerCalcSettings(
        method: PrayerCalcMethod.karachi,
        madhab: AsrMadhab.hanafi,
        highLatitude: HighLatitudeMode.seventhOfNight,
        ramadanIsha: false,
      ).withAdjustment(AppPrayer.maghrib, 2);
      await chosen.save();

      final back = PrayerCalcSettings.load();
      expect(back.method, PrayerCalcMethod.karachi);
      expect(back.madhab, AsrMadhab.hanafi);
      expect(back.highLatitude, HighLatitudeMode.seventhOfNight);
      expect(back.ramadanIsha, false);
      expect(back.adjustmentOf(AppPrayer.maghrib), 2);
      expect(back.adjustmentOf(AppPrayer.fajr), 0);
      expect(back.isDefault, false);
    });

    test('an unknown saved value falls back instead of breaking', () async {
      await CacheHelper.saveData(key: PrayerCalcSettings.methodKey, value: 'removed_method');
      await CacheHelper.saveData(key: PrayerCalcSettings.madhabKey, value: 42);
      final s = PrayerCalcSettings.load();
      expect(s.method, PrayerCalcMethod.ummAlQura);
      expect(s.madhab, AsrMadhab.jumhur);
    });
  });
}
