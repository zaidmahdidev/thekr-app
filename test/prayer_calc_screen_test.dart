import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/prayer_service.dart';
import 'package:thekr_app/core/theme/app_theme.dart';
import 'package:thekr_app/features/prayer_times/models/prayer_calc_settings.dart';
import 'package:thekr_app/features/prayer_times/providers/prayer_calc_provider.dart';
import 'package:thekr_app/features/prayer_times/providers/prayer_times_providers.dart';
import 'package:thekr_app/features/prayer_times/screens/prayer_calc_settings_screen.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required bool dark,
  double latitude = 24.7136,
}) async {
  // The app does this in main().
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('ar', null);
  SharedPreferences.setMockInitialValues({});
  await CacheHelper.init();
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      prayerLocationProvider.overrideWith(
        (ref) async => PrayerLocation(
          coordinates: Coordinates(latitude, 46.6753),
          isDefault: false,
          isPermissionOff: false,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          locale: const Locale('ar'),
          theme: dark
              ? AppTheme.dark(AppThemeType.defaultTheme)
              : AppTheme.light(AppThemeType.defaultTheme),
          builder: (c, child) =>
              Directionality(textDirection: TextDirection.rtl, child: child!),
          home: const PrayerCalcSettingsScreen(),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return container;
}

void main() {
  for (final dark in [false, true]) {
    testWidgets('screen fits at 360 wide (dark: $dark)', (tester) async {
      await _pump(tester, dark: dark);
      expect(find.text('طريقة الحساب'), findsOneWidget);
      expect(find.text('أم القرى (مكة المكرمة)'), findsOneWidget);
      expect(find.text('عشاء رمضان بعد 120 دقيقة'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Scroll down through the whole screen: nothing overflows.
      await tester.scrollUntilVisible(
        find.text('تعديل بالدقائق'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await tester.pump();
      expect(tester.takeException(), isNull);
      // Far from the north: the high-latitude rules are not offered.
      expect(find.text('المناطق الشمالية'), findsNothing);
    });
  }

  testWidgets('the northern-regions rules appear only far north', (tester) async {
    await _pump(tester, dark: false, latitude: 60); // Oslo
    await tester.scrollUntilVisible(
      find.text('المناطق الشمالية'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('المناطق الشمالية'), findsOneWidget);
    expect(find.text('سُبع الليل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the reset bar shows only after a change and puts the defaults back', (tester) async {
    final container = await _pump(tester, dark: false);
    expect(find.text('إعدادات مخصّصة'), findsNothing);

    await container.read(prayerCalcProvider.notifier).setMadhab(AsrMadhab.hanafi);
    await tester.pump();
    expect(find.text('إعدادات مخصّصة'), findsOneWidget);

    await tester.tap(find.text('إعادة الضبط'));
    await tester.pump();
    expect(container.read(prayerCalcProvider).isDefault, true);
    expect(find.text('إعدادات مخصّصة'), findsNothing);
    // Let the delayed recalculation finish before the test ends.
    await tester.pump(PrayerCalcNotifier.recalculateDelay + const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('choosing a method and an adjustment is saved and updates the times', (tester) async {
    final container = await _pump(tester, dark: false);
    final notifier = container.read(prayerCalcProvider.notifier);

    final before = container.read(prayerCalcPreviewProvider).value!;
    await notifier.setMadhab(AsrMadhab.hanafi);
    await tester.pump();
    final after = container.read(prayerCalcPreviewProvider).value!;
    expect(after.asr.isAfter(before.asr), true);

    await notifier.setMethod(PrayerCalcMethod.karachi);
    await tester.pump();
    expect(container.read(prayerCalcProvider).method, PrayerCalcMethod.karachi);
    // The Ramadan switch belongs to Umm al-Qura only.
    expect(find.text('عشاء رمضان بعد 120 دقيقة'), findsNothing);

    // What was chosen is on disk, so it survives a restart.
    expect(PrayerCalcSettings.load().method, PrayerCalcMethod.karachi);
    expect(PrayerCalcSettings.load().madhab, AsrMadhab.hanafi);

    await notifier.reset();
    await tester.pump();
    expect(container.read(prayerCalcProvider).isDefault, true);

    // The heavy recalculation waits a moment after the last change.
    await tester.pump(PrayerCalcNotifier.recalculateDelay + const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
