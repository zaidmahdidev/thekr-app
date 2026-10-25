import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thekr_app/core/theme/app_theme.dart';
import 'package:thekr_app/features/account/providers/account_provider.dart';
import 'package:thekr_app/features/account/widgets/account_card.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('signed-out card fits (dark: $dark)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountUserProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (_, __) => MaterialApp(
              locale: const Locale('ar'),
              theme: dark
                  ? AppTheme.dark(AppThemeType.defaultTheme)
                  : AppTheme.light(AppThemeType.defaultTheme),
              builder: (c, child) =>
                  Directionality(textDirection: TextDirection.rtl, child: child!),
              home: const Scaffold(body: SingleChildScrollView(child: AccountCard())),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('تسجيل الدخول باستخدام Google'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
