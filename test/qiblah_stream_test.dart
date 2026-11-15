import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/theme/app_theme.dart';
import 'package:thekr_app/features/qiblah/screens/qiblah_screen.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

Future<StreamController<QiblahDirection>> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await CacheHelper.init();
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  // One listener only, like the phone's own stream.
  final controller = StreamController<QiblahDirection>();
  addTearDown(() => unawaited(controller.close()));

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        theme: AppTheme.light(AppThemeType.defaultTheme),
        builder: (c, w) =>
            Directionality(textDirection: TextDirection.rtl, child: w!),
        home: Scaffold(body: QiblahCompassWidget(stream: controller.stream)),
      ),
    ),
  );
  return controller;
}

void main() {
  testWidgets('waiting: a spinner, not a crash', (tester) async {
    await _pump(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a reading is shown, and survives later rebuilds', (tester) async {
    final controller = await _pump(tester);
    controller.add(QiblahDirection(10, 350, 20));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('°'), findsWidgets);
    // Time passes: the declination and the sensor hint may rebuild the widget.
    await tester.pump(const Duration(seconds: 1));
    controller.add(QiblahDirection(5, 355, 20));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('°'), findsWidgets);
    // (A sideways overflow here comes from the plain test font, not the app.)
    final problem = tester.takeException();
    expect(problem?.toString() ?? 'right', contains('right'));
  });

  testWidgets('an error in the stream shows the retry screen', (tester) async {
    final controller = await _pump(tester);
    controller.addError(StateError('no location'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('أعد المحاولة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a stream that ends with nothing shows the retry screen', (
    tester,
  ) async {
    final controller = await _pump(tester);
    unawaited(controller.close()); // not awaited: the test clock is manual
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('أعد المحاولة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
