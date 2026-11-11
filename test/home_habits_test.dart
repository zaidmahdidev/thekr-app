import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/theme/app_theme.dart';
import 'package:thekr_app/features/habit_tracker/providers/habit_tracker_provider.dart';
import 'package:thekr_app/features/home/widgets/home_habits_card.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

void main() {
  group('the home order', () {
    test('a new phone has the habits right after the services', () async {
      SharedPreferences.setMockInitialValues({});
      await CacheHelper.init();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final sections = container.read(settingsProvider).homeSections;
      expect(
        sections.indexOf(HomeSection.habits),
        sections.indexOf(HomeSection.features) + 1,
      );
    });

    test('an order saved before the habits existed gets them added', () async {
      SharedPreferences.setMockInitialValues({
        // The user had moved the services to the top.
        'homeSections': [
          'features',
          'prayerTimes',
          'inspiration',
          'dynamicSections',
          'shareCard',
        ],
      });
      await CacheHelper.init();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final sections = container.read(settingsProvider).homeSections;
      expect(sections.length, HomeSection.values.length);
      expect(sections.first, HomeSection.features); // their order is kept
      expect(sections[1], HomeSection.habits); // and it sits under the services
    });
  });

  for (final dark in [false, true]) {
    for (final width in [320.0, 360.0, 411.0]) {
      testWidgets('the strip fits and ticks (dark: $dark, $width)', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        await CacheHelper.init();
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final container = ProviderContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (_, __) => MaterialApp(
                theme: dark
                    ? AppTheme.dark(AppThemeType.defaultTheme)
                    : AppTheme.light(AppThemeType.defaultTheme),
                builder: (c, child) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                ),
                home: const Scaffold(body: HomeHabitsCard()),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
        expect(find.text('0 من 5'), findsOneWidget);

        await tester.tap(find.text('الفجر'));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('1 من 5'), findsOneWidget);
        expect(container.read(habitTrackerProvider).revision, 1);
        expect(tester.takeException(), isNull);

        // Take it back, frame by frame: the animation must not overshoot into
        // a negative shadow (that threw "blur radius should be non-negative").
        await tester.tap(find.text('الفجر'));
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 20));
          expect(tester.takeException(), isNull);
        }
        expect(find.text('0 من 5'), findsOneWidget);
      });
    }
  }
}
