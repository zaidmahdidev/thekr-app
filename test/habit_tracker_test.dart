import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/theme/app_theme.dart';
import 'package:thekr_app/features/habit_tracker/models/daily_habit_model.dart';
import 'package:thekr_app/features/habit_tracker/providers/habit_tracker_provider.dart';
import 'package:thekr_app/features/habit_tracker/screens/habit_tracker_screen.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

Future<HabitTrackerNotifier> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  await CacheHelper.init();
  return HabitTrackerNotifier();
}

Future<void> _fullDay(HabitTrackerNotifier n, DateTime date) async {
  for (final f in HabitField.fard) {
    await n.toggle(date, f);
  }
}

void main() {
  group('the days', () {
    test('a tick is saved for that day only', () async {
      final n = await _fresh();
      final today = DateTime.now();
      await n.toggle(today, HabitField.fajr);
      expect(n.habitFor(today).fajr, true);
      expect(n.habitFor(today.subtract(const Duration(days: 1))).fajr, false);
      await n.toggle(today, HabitField.fajr); // and it can be taken back
      expect(n.habitFor(today).fajr, false);
    });

    test('an earlier day can be filled in', () async {
      final n = await _fresh();
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      await n.toggle(lastWeek, HabitField.asr);
      expect(n.habitFor(lastWeek).asr, true);
    });

    test('a day that has not come is not recorded', () async {
      final n = await _fresh();
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await n.toggle(tomorrow, HabitField.fajr);
      expect(n.habitFor(tomorrow).fajr, false);
    });

    test('the extras do not count toward a full day', () async {
      final n = await _fresh();
      final today = DateTime.now();
      for (final f in HabitField.extras) {
        await n.toggle(today, f);
      }
      expect(n.habitFor(today).fardCount, 0);
      expect(n.habitFor(today).isFardComplete, false);
      await _fullDay(n, today);
      expect(n.habitFor(today).isFardComplete, true);
    });
  });

  group('the streak', () {
    test('counts the days in a row, and today does not break it', () async {
      final n = await _fresh();
      final today = DateTime.now();
      await _fullDay(n, today.subtract(const Duration(days: 1)));
      await _fullDay(n, today.subtract(const Duration(days: 2)));
      expect(n.state.currentStreak, 2); // today is still open
      await _fullDay(n, today);
      expect(n.state.currentStreak, 3);
      expect(n.state.bestStreak, 3);
    });

    test('a missed day ends it, the best one stays', () async {
      final n = await _fresh();
      final today = DateTime.now();
      await _fullDay(n, today.subtract(const Duration(days: 1)));
      await _fullDay(n, today.subtract(const Duration(days: 2)));
      await _fullDay(n, today.subtract(const Duration(days: 4))); // 3 is missed
      expect(n.state.currentStreak, 2);
      await n.toggle(today.subtract(const Duration(days: 1)), HabitField.fajr);
      expect(n.state.currentStreak, 0);
      expect(n.state.bestStreak, 2);
    });
  });

  for (final dark in [false, true]) {
    for (final width in [320.0, 360.0, 411.0]) {
      testWidgets('the screen fits (dark: $dark, width: $width)', (
        tester,
      ) async {
        await initializeDateFormatting('ar', null);
        SharedPreferences.setMockInitialValues({});
        await CacheHelper.init();
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            child: ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (_, __) => MaterialApp(
                locale: const Locale('ar'),
                theme: dark
                    ? AppTheme.dark(AppThemeType.defaultTheme)
                    : AppTheme.light(AppThemeType.defaultTheme),
                builder: (c, child) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                ),
                home: const HabitTrackerScreen(),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);

        // Tick the Fajr chip: today's counter moves.
        expect(find.text('0 من 5'), findsNWidgets(2)); // prayers, and extras
        await tester.tap(find.text('الفجر').first);
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('1 من 5'), findsOneWidget); // the prayers only

        // Open a day of the month and tick Dhuhr there.
        await tester.scrollUntilVisible(
          find.text('تفصيل الشهر'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('a day of the month opens and can be ticked', (tester) async {
    await initializeDateFormatting('ar', null);
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => MaterialApp(
            locale: const Locale('ar'),
            theme: AppTheme.light(AppThemeType.defaultTheme),
            builder: (c, child) =>
                Directionality(textDirection: TextDirection.rtl, child: child!),
            home: const HabitTrackerScreen(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // The 1st of this month is never in the future.
    await tester.scrollUntilVisible(
      find.text('تفصيل الشهر'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('1'),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    expect(find.text('تم'), findsOneWidget);

    await tester.tap(find.text('الظهر').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('1 من 5'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('تم'));
    await tester.pumpAndSettle();
    expect(find.text('تم'), findsNothing);
  });
}
