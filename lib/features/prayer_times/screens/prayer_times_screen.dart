import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/services/prayer_service.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/core/widgets/base_app_bar.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:thekr_app/features/home/providers/prayer_provider.dart';
import 'package:thekr_app/features/prayer_times/providers/prayer_times_providers.dart';
import 'package:thekr_app/features/prayer_times/widgets/prayer_location_notice.dart';
import 'package:thekr_app/features/prayer_times/widgets/prayer_month_table.dart';

/// Prayer times timetable of the month (Gregorian + Hijri), opened on today.
/// Times are calculated on the device, so everything works without internet.
@RoutePage()
class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  Future<void> _requestLocation(WidgetRef ref) async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      showToast(text: 'يرجى تفعيل صلاحية الموقع من إعدادات الهاتف');
      return;
    }
    await Geolocator.requestPermission();
    await PrayerService.refreshLocation();
    ref.invalidate(prayerLocationProvider);
    ref.invalidate(prayerTimesProvider);
    ref.invalidate(tomorrowPrayerTimesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(prayerLocationProvider).value;
    final showNotice =
        location != null && (location.isDefault || location.isPermissionOff);

    return AppScaffold(
      appBar: BaseAppBar(
        title: 'مواقيت الصلاة',
        showBlur: true,
        actions: [
          IconButton(
            tooltip: 'إعدادات الأذان',
            onPressed: () => context.pushRoute(const AthanSettingsRoute()),
            icon: const AppIcon(HugeIcons.strokeRoundedSettings02),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          context.insets.md,
          context.insets.sm,
          context.insets.md,
          context.insets.md,
        ),
        child: Column(
          children: [
            if (showNotice) ...[
              PrayerLocationNotice(
                isDefaultLocation: location.isDefault,
                onRequestLocation: () => _requestLocation(ref),
              ),
              SizedBox(height: context.insets.sm),
            ],
            const Expanded(child: PrayerMonthTable()),
          ],
        ),
      ),
    );
  }
}
