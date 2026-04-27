import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/notification_service.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';
import 'package:thekr_app/core/widgets/widgets.dart';

import '../widgets/setting_card.dart';
import '../widgets/appearance_card.dart';
import '../widgets/settings_info_card.dart';
import '../widgets/settings_share_card.dart';

@RoutePage()
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _morningEnabled = true;
  bool _eveningEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 19, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final morningEnabled =
          await SettingsService.isMorningNotificationEnabled();
      final eveningEnabled =
          await SettingsService.isEveningNotificationEnabled();
      final morningTime = await SettingsService.getMorningTime();
      final eveningTime = await SettingsService.getEveningTime();

      setState(() {
        _morningEnabled = morningEnabled;
        _eveningEnabled = eveningEnabled;
        _morningTime = morningTime;
        _eveningTime = eveningTime;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMorningNotification(bool enabled) async {
    setState(() {
      _morningEnabled = enabled;
    });

    await SettingsService.setMorningNotificationEnabled(enabled);

    if (enabled) {
      await NotificationService.scheduleMorningAzkar(_morningTime);
      showToast(
        text: 'تم تفعيل تذكير أذكار الصباح',
        backgroundColor: context.colors.background,
      );
    } else {
      await NotificationService.cancelMorningNotification();
      showToast(
        text: 'تم إلغاء تذكير أذكار الصباح',
        // backgroundColor: context.colors.background,
      );
    }
  }

  Future<void> _updateEveningNotification(bool enabled) async {
    setState(() {
      _eveningEnabled = enabled;
    });

    await SettingsService.setEveningNotificationEnabled(enabled);

    if (enabled) {
      await NotificationService.scheduleEveningAzkar(_eveningTime);
      showToast(
        text: 'تم تفعيل تذكير أذكار المساء',
        backgroundColor: context.colors.background,
      );
    } else {
      await NotificationService.cancelEveningNotification();
      showToast(
        text: 'تم إلغاء تذكير أذكار المساء',
        backgroundColor: context.colors.background,
      );
    }
  }

  Future<void> _selectMorningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _morningTime,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != _morningTime) {
      setState(() {
        _morningTime = picked;
      });

      await SettingsService.setMorningTime(picked);

      if (_morningEnabled) {
        await NotificationService.scheduleMorningAzkar(picked);

        showToast(
          text: 'تم تحديث وقت أذكار الصباح',
          backgroundColor: context.colors.background,
        );
      }
    }
  }

  Future<void> _selectEveningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _eveningTime,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != _eveningTime) {
      setState(() {
        _eveningTime = picked;
      });

      await SettingsService.setEveningTime(picked);

      if (_eveningEnabled) {
        await NotificationService.scheduleEveningAzkar(picked);
        showToast(
          text: 'تم تحديث وقت أذكار المساء',
          backgroundColor: context.colors.background,
        );
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDarkMode = settings.themeMode == ThemeMode.dark;

    return AppScaffold(
      title: 'الإعدادات',
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.insets.lg,
                vertical: context.insets.lg,
              ),
              child: Column(
                children: [
                  // Appearance Section
                  AppearanceCard(
                    isDarkMode: isDarkMode,
                    onThemeChanged: (val) =>
                        ref.read(settingsProvider.notifier).toggleTheme(val),
                  ),

                  SizedBox(height: context.insets.md),

                  // Morning Azkar Section
                  SettingCard(
                    title: 'أذكار الصباح',
                    icon: Icons.wb_sunny_rounded,
                    iconColor: context.colors.secondary,
                    isEnabled: _morningEnabled,
                    onToggle: _updateMorningNotification,
                    time: _morningTime,
                    onTimeTap: _selectMorningTime,
                    formatTime: _formatTime,
                  ),

                  SizedBox(height: context.insets.md),

                  // Evening Azkar Section
                  SettingCard(
                    title: 'أذكار المساء',
                    icon: Icons.nightlight_round_rounded,
                    iconColor: context.colors.primary,
                    isEnabled: _eveningEnabled,
                    onToggle: _updateEveningNotification,
                    time: _eveningTime,
                    onTimeTap: _selectEveningTime,
                    formatTime: _formatTime,
                  ),

                  SizedBox(height: context.insets.lg),

                  // Info Section
                  const SettingsInfoCard(),

                  SizedBox(height: context.insets.md),

                  // Share App Section
                  const SettingsShareCard(),
                ],
              ),
            ),
    );
  }
}
