import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart' as intl;
import 'package:hijri/hijri_calendar.dart';

import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/custom_dialog.dart';
import 'package:thekr_app/features/home/providers/prayer_provider.dart';
import 'package:thekr_app/features/home/providers/time_provider.dart';
import 'package:thekr_app/features/home/widgets/prayer_times_card.dart';
import 'package:thekr_app/features/home/widgets/home_app_bar.dart';
import 'package:thekr_app/features/home/widgets/home_features_grid.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:thekr_app/features/home/models/app_prayer_times.dart';
import 'package:thekr_app/features/home/widgets/inspiration_carousel.dart';
import 'package:thekr_app/features/home/widgets/home_dynamic_sections.dart';
import 'package:thekr_app/features/home/widgets/share_app_card.dart';

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.startFlexibleUpdate();
      }
    } catch (e) {
      debugPrint("Update feature not available: $e");
    }
  }

  String _formatRemainingTime(
    AppPrayerTimes? prayerTimes,
    AppPrayerTimes? tomorrowTimes,
    DateTime now,
  ) {
    if (prayerTimes == null) return "";

    final nextPrayer = prayerTimes.nextPrayer(now);
    DateTime? timeForNext;
    AppPrayer actualNext;

    if (nextPrayer == null) {
      if (tomorrowTimes != null) {
        actualNext = AppPrayer.fajr;
        timeForNext = tomorrowTimes.fajr;
      } else {
        return "";
      }
    } else {
      actualNext = nextPrayer;
      timeForNext = prayerTimes.getTimeFor(actualNext);
    }

    final name = actualNext.nameArabic;
    final diff = timeForNext.difference(now);
    if (diff.isNegative) return "";

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);

    return "متبقي ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} على صلاة $name";
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final tomorrowTimesAsync = ref.watch(tomorrowPrayerTimesProvider);
    final currentTime = ref.watch(currentTimeProvider).value ?? DateTime.now();

    final prayerTimes = prayerTimesAsync.value;
    final tomorrowTimes = tomorrowTimesAsync.value;

    final remainingTime = _formatRemainingTime(
      prayerTimes,
      tomorrowTimes,
      currentTime,
    );
    final todayDate = intl.DateFormat('EEEE, d MMMM', 'ar').format(currentTime);

    // Hijri Date Calculation
    final hijriNow = HijriCalendar.fromDate(currentTime);
    final hijriDate =
        '${hijriNow.hDay} ${hijriNow.getLongMonthName()} ${hijriNow.hYear} هـ';

    final nextPrayer = prayerTimes?.nextPrayer(currentTime);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitMethod(context);
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            HomeAppBar(
              currentTime: currentTime,
              todayDate: todayDate,
              hijriDate: hijriDate,
              remainingTime: remainingTime,
              nextPrayer: nextPrayer,
            ),
            SliverToBoxAdapter(
              child: PrayerTimesCard(prayerTimes: prayerTimes),
            ),
            const InspirationCarousel(),
            const HomeFeaturesGrid(),
            const HomeDynamicSections(),
            const ShareAppCard(),
          ],
        ),
      ),
    );
  }

  void _exitMethod(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'تنويه',
        message: 'هل أنت متأكد أنك تريد الخروج؟',
        onYes: () => SystemNavigator.pop(),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}
