import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/theme/app_theme.dart';
import 'package:thekr_app/core/widgets/new_feature_badge.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

Future<void> _pump(WidgetTester tester, Widget body) async {
  PackageInfo.setMockInitialValues(
    appName: 'thekr',
    packageName: 'thekr',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  SharedPreferences.setMockInitialValues({'first_install_version': '1.0.0'});
  await CacheHelper.init();
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          theme: AppTheme.light(AppThemeType.defaultTheme),
          home: Scaffold(body: body),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('in a list the tile is shown, with the badge', (tester) async {
    await _pump(
      tester,
      ListView(
        children: [
          NewFeatureBadge(
            featureId: 'x',
            addedInVersion: '9.9.9',
            child: const SizedBox(height: 70, child: Center(child: Text('tile'))),
          ),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('جديد'), findsOneWidget);
    expect(find.text('tile'), findsOneWidget); // not swallowed by the badge
    expect(tester.getSize(find.text('tile')).height, greaterThan(0));
  });

  testWidgets('in a grid cell the card fills the cell', (tester) async {
    await _pump(
      tester,
      GridView.count(
        crossAxisCount: 2,
        children: [
          NewFeatureBadge(
            featureId: 'x',
            addedInVersion: '9.9.9',
            child: Container(key: const Key('card'), color: Colors.red),
          ),
        ],
      ),
    );
    expect(find.text('جديد'), findsOneWidget);
    expect(tester.getSize(find.byKey(const Key('card'))), const Size(180, 180));
  });
}
