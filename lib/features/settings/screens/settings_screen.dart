import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/services/notification_service.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/settings/widgets/settings_section.dart';
import 'package:thekr_app/features/settings/widgets/settings_tile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thekr_app/core/utils/url_helper.dart';

@RoutePage()
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = true;
  bool _morningEnabled = true;
  bool _eveningEnabled = true;
  bool _fridayEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final morningEnabled = await SettingsService.isMorningNotificationEnabled();
    final eveningEnabled = await SettingsService.isEveningNotificationEnabled();
    final fridayEnabled = await SettingsService.isFridayNotificationEnabled();
    final morningTime = await SettingsService.getMorningTime();
    final eveningTime = await SettingsService.getEveningTime();

    if (mounted) {
      setState(() {
        _morningEnabled = morningEnabled;
        _eveningEnabled = eveningEnabled;
        _fridayEnabled = fridayEnabled;
        _morningTime = morningTime;
        _eveningTime = eveningTime;
        _isLoading = false;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> _selectMorningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _morningTime,
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null && picked != _morningTime) {
      setState(() => _morningTime = picked);
      await SettingsService.setMorningTime(picked);
      if (_morningEnabled) {
        await NotificationService.scheduleMorningAzkar(picked);
      }
    }
  }

  Future<void> _selectEveningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _eveningTime,
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null && picked != _eveningTime) {
      setState(() => _eveningTime = picked);
      await SettingsService.setEveningTime(picked);
      if (_eveningEnabled) {
        await NotificationService.scheduleEveningAzkar(picked);
      }
    }
  }

  Future<void> _updateMorningNotification(bool val) async {
    setState(() => _morningEnabled = val);
    await SettingsService.setMorningNotificationEnabled(val);
    if (val) {
      await NotificationService.scheduleMorningAzkar(_morningTime);
      showToast(text: 'تم تفعيل تذكير أذكار الصباح');
    } else {
      await NotificationService.cancelMorningNotification();
      showToast(text: 'تم إلغاء تذكير أذكار الصباح');
    }
  }

  Future<void> _updateEveningNotification(bool val) async {
    setState(() => _eveningEnabled = val);
    await SettingsService.setEveningNotificationEnabled(val);
    if (val) {
      await NotificationService.scheduleEveningAzkar(_eveningTime);
      showToast(text: 'تم تفعيل تذكير أذكار المساء');
    } else {
      await NotificationService.cancelEveningNotification();
      showToast(text: 'تم إلغاء تذكير أذكار المساء');
    }
  }

  Future<void> _updateFridayNotification(bool val) async {
    setState(() => _fridayEnabled = val);
    await SettingsService.setFridayNotificationEnabled(val);
    if (val) {
      await NotificationService.scheduleFridayKahf(
        const TimeOfDay(hour: 8, minute: 0),
      );
      showToast(text: 'تم تفعيل تذكير سورة الكهف');
    } else {
      await NotificationService.cancelFridayNotification();
      showToast(text: 'تم إلغاء تذكير سورة الكهف');
    }
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'المظهر والتنبيهات'),
                  SettingsSection(
                    children: [
                      SettingsTile(
                        title: 'الوضع الليلي',
                        icon: Icons.dark_mode_rounded,
                        iconColor: Colors.indigo,
                        trailing: Switch.adaptive(
                          value: isDarkMode,

                          onChanged: (val) => ref
                              .read(settingsProvider.notifier)
                              .toggleTheme(val),
                        ),
                      ),
                      SettingsTile(
                        title: 'أذكار الصباح',
                        subtitle: _morningEnabled
                            ? 'تذكير عند ${_formatTime(_morningTime)}'
                            : 'التذكير متوقف',
                        icon: Icons.wb_sunny_rounded,
                        iconColor: Colors.orange,
                        trailing: Switch.adaptive(
                          value: _morningEnabled,
                          onChanged: _updateMorningNotification,
                        ),
                        onTap: _morningEnabled ? _selectMorningTime : null,
                      ),
                      SettingsTile(
                        title: 'أذكار المساء',
                        subtitle: _eveningEnabled
                            ? 'تذكير عند ${_formatTime(_eveningTime)}'
                            : 'التذكير متوقف',
                        icon: Icons.nightlight_round_rounded,
                        iconColor: Colors.blueAccent,
                        trailing: Switch.adaptive(
                          value: _eveningEnabled,
                          onChanged: _updateEveningNotification,
                        ),
                        onTap: _eveningEnabled ? _selectEveningTime : null,
                      ),
                      SettingsTile(
                        title: 'تذكير سورة الكهف',
                        subtitle: _fridayEnabled
                            ? 'كل يوم جمعة صباحاً'
                            : 'التذكير متوقف',
                        icon: Icons.menu_book_rounded,
                        iconColor: Colors.green,
                        trailing: Switch.adaptive(
                          value: _fridayEnabled,
                          onChanged: _updateFridayNotification,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.insets.xl),
                  const SectionHeader(title: 'الدعم والمعلومات'),
                  SettingsSection(
                    children: [
                      SettingsTile(
                        title: 'تواصل معنا',
                        icon: Icons.chat_rounded,
                        iconColor: Colors.teal,
                        onTap: () => UrlHelper.launchWhatsApp(
                          phone: '+967774814210',
                          message: 'السلام عليكم، لدي استفسار بخصوص تطبيق ذكر',
                        ),
                      ),
                      SettingsTile(
                        title: 'سياسة الخصوصية',
                        icon: Icons.privacy_tip_rounded,
                        iconColor: Colors.redAccent,
                        onTap: () => UrlHelper.launchURL(
                          'https://zaidmahdidev.github.io/privacy-policy-thekr/',
                        ),
                      ),
                      SettingsTile(
                        title: 'شارك التطبيق',
                        icon: Icons.share_rounded,
                        iconColor: Colors.purple,
                        onTap: () {
                          Share.share(
                            'حمل تطبيق "ذكر" - صدقة جارية\nتطبيق شامل للمصحف الشريف والأذكار والتسبيح\nhttps://play.google.com/store/apps/details?id=com.zaid.thekr_app',
                          );
                        },
                      ),
                      SettingsTile(
                        title: 'عن التطبيق',
                        icon: Icons.info_rounded,
                        iconColor: Colors.grey,
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'تطبيق ذِكر',
                            applicationVersion: '1.1.0',
                            applicationIcon: Image.asset(
                              AppAssets.logo,
                              width: 40.w,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.mosque, size: 30.sp),
                            ),
                            children: [
                              const Text(
                                'تطبيق صدقة جارية يهدف لنشر الأذكار والأدعية الصحيحة.',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: context.insets.xl),
                  Center(
                    child: Text(
                      'الإصدار 1.1.0',
                      style: (context.textStyles.bodySmall ?? const TextStyle())
                          .copyWith(
                            color: context.colors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: 11.sp,
                          ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
