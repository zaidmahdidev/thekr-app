import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/services/notification_service.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/settings/widgets/developer_social_card.dart';
import 'package:thekr_app/features/settings/widgets/settings_section.dart';
import 'package:thekr_app/features/settings/widgets/settings_tile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thekr_app/core/utils/url_helper.dart';
import 'package:thekr_app/core/services/review_service.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';
import 'package:thekr_app/features/settings/widgets/app_share_sheet.dart';

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
  bool _wirdEnabled = false;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _wirdTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final morningEnabled = await SettingsService.isMorningNotificationEnabled();
    final eveningEnabled = await SettingsService.isEveningNotificationEnabled();
    final fridayEnabled = await SettingsService.isFridayNotificationEnabled();
    final wirdEnabled = await SettingsService.isWirdNotificationEnabled();
    final morningTime = await SettingsService.getMorningTime();
    final eveningTime = await SettingsService.getEveningTime();
    final wirdTime = await SettingsService.getWirdTime();

    if (mounted) {
      setState(() {
        _morningEnabled = morningEnabled;
        _eveningEnabled = eveningEnabled;
        _fridayEnabled = fridayEnabled;
        _wirdEnabled = wirdEnabled;
        _morningTime = morningTime;
        _eveningTime = eveningTime;
        _wirdTime = wirdTime;
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

  Future<void> _selectWirdTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wirdTime,
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null && picked != _wirdTime) {
      setState(() => _wirdTime = picked);
      await SettingsService.setWirdTime(picked);
      if (_wirdEnabled) {
        await NotificationService.scheduleWirdNotification(picked);
      }
    }
  }

  Future<void> _updateWirdNotification(bool val) async {
    setState(() => _wirdEnabled = val);
    await SettingsService.setWirdNotificationEnabled(val);
    if (val) {
      await NotificationService.scheduleWirdNotification(_wirdTime);
      showToast(text: 'تم تفعيل تذكير الورد اليومي');
    } else {
      await NotificationService.cancelWirdNotification();
      showToast(text: 'تم إلغاء تذكير الورد اليومي');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      title: 'الإعدادات',
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            )
          : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: context.insets.md,
                vertical: context.insets.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'المظهر والتخصيص'),
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
                              .toggleTheme(
                                val ? ThemeMode.dark : ThemeMode.light,
                              ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(context.insets.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.palette_rounded,
                                  size: 20.sp,
                                  color: Colors.teal,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'ألوان التطبيق (الثيمات)',
                                  style: context.textStyles.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: context.insets.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: AppThemeType.values.map((theme) {
                                final isSelected = settings.appTheme == theme;
                                Color primaryColor;
                                switch (theme) {
                                  case AppThemeType.defaultTheme:
                                    primaryColor = const Color(0xFF0E645C);
                                    break;
                                  case AppThemeType.desert:
                                    primaryColor = const Color(0xFFC19A6B);
                                    break;
                                  case AppThemeType.forest:
                                    primaryColor = const Color(0xFF2D5A27);
                                    break;
                                }

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => ref
                                        .read(settingsProvider.notifier)
                                        .updateAppTheme(theme),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? primaryColor.withValues(
                                                alpha: 0.1,
                                              )
                                            : context.colors.surface,
                                        borderRadius: BorderRadius.circular(
                                          context.corners.md,
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? primaryColor
                                              : primaryColor.withValues(
                                                  alpha: 0.2,
                                                ),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          width: isSelected ? 28.w : 32.w,
                                          height: isSelected ? 28.w : 32.w,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            shape: BoxShape.circle,
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: primaryColor
                                                          .withValues(
                                                            alpha: 0.4,
                                                          ),
                                                      blurRadius: 10,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: isSelected
                                                ? const Icon(
                                                    Icons.check,
                                                    key: ValueKey('check'),
                                                    color: Colors.white,
                                                    size: 18,
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.insets.lg,
                          vertical: context.insets.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // SizedBox(width: context.insets.sm),
                                Text(
                                  'حجم الخط في القراءة',
                                  style: context.textStyles.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => ref
                                      .read(settingsProvider.notifier)
                                      .updateFontSize(16.0),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 2.h,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    backgroundColor: context.colors.primary,
                                  ),
                                  child: Text(
                                    'الافتراضي',
                                    style: context.textStyles.bodySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                SizedBox(width: context.insets.sm),
                                Text(
                                  '${settings.fontSize.toInt()}',
                                  style: context.textStyles.bodySmall?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Slider.adaptive(
                              value: settings.fontSize.clamp(14.0, 24.0),
                              min: 14.0,
                              max: 24.0,
                              divisions: 5,
                              activeColor: context.colors.primary,
                              onChanged: (val) => ref
                                  .read(settingsProvider.notifier)
                                  .updateFontSize(val),
                            ),
                          ],
                        ),
                      ),
                      SettingsTile(
                        title: 'ترتيب الشاشة الرئيسية',
                        subtitle: 'تحكم في مكان ظهور العناصر في الرئيسية',
                        icon: Icons.dashboard_customize_rounded,
                        onTap: () => context.router.push(
                          const CustomizeHomeLayoutRoute(),
                        ),
                        iconColor: Colors.purple,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: context.insets.sm),
                        child: SettingsTile(
                          title: 'بطاقة المشاركة',
                          subtitle: 'تخصيص شكل ومحتوى بطاقة المشاركة ',
                          icon: Icons.auto_awesome_outlined,
                          iconColor: Colors.orange,
                          onTap: () => context.pushRoute(
                            const CustomizeShareCardRoute(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.insets.md),
                  const SectionHeader(title: 'التنبيهات'),
                  SettingsSection(
                    children: [
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
                        title: 'تذكير الورد اليومي',
                        subtitle: _wirdEnabled
                            ? 'تذكير عند ${_formatTime(_wirdTime)}'
                            : 'التذكير متوقف',
                        icon: Icons.menu_book_rounded,
                        iconColor: context.colors.primary,
                        trailing: Switch.adaptive(
                          value: _wirdEnabled,
                          onChanged: _updateWirdNotification,
                        ),
                        onTap: _wirdEnabled ? _selectWirdTime : null,
                      ),
                      SettingsTile(
                        title: 'تذكير سورة الكهف',
                        subtitle: _fridayEnabled
                            ? 'كل يوم جمعة صباحاً'
                            : 'التذكير متوقف',
                        icon: Icons.auto_stories_rounded,
                        iconColor: Colors.green,
                        trailing: Switch.adaptive(
                          value: _fridayEnabled,
                          onChanged: _updateFridayNotification,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.insets.md),
                  const SectionHeader(title: 'الدعم والمعلومات'),
                  SettingsSection(
                    children: [
                      SettingsTile(
                        title: 'تقييم التطبيق',
                        icon: Icons.star_rounded,
                        iconColor: Colors.amber,
                        onTap: () => ReviewService.requestManualReview(),
                      ),
                      SettingsTile(
                        title: 'تواصل معنا',
                        icon: Icons.chat_rounded,
                        iconColor: Colors.teal,
                        onTap: () => UrlHelper.launchWhatsApp(
                          phone: AppConstants.whatsappNumber,
                          message: 'السلام عليكم، لدي استفسار بخصوص تطبيق ذكر',
                        ),
                      ),
                      SettingsTile(
                        title: 'سياسة الخصوصية',
                        icon: Icons.privacy_tip_rounded,
                        iconColor: Colors.redAccent,
                        onTap: () =>
                            UrlHelper.launchURL(AppConstants.privacyPolicyUrl),
                      ),
                      SettingsTile(
                        title: 'شارك التطبيق',
                        icon: Icons.share_rounded,
                        iconColor: Colors.purple,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => const AppShareSheet(),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: context.insets.xl),
                  Column(
                    children: [
                      Text(
                        'تم التطوير بكل ❤️ بواسطة',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.textSecondary,
                          fontSize: 10.sp,
                        ),
                      ),
                      SizedBox(height: context.insets.sm),
                      Text(
                        AppConstants.developerName,
                        style: context.textStyles.bodyLarge?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: context.insets.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DeveloperSocialCard(
                            icon: Icons.language_rounded,
                            color: Colors.blue,
                            onTap: () =>
                                UrlHelper.launchURL(AppConstants.websiteUrl),
                          ),
                          SizedBox(width: context.insets.md),
                          DeveloperSocialCard(
                            icon: Icons.email_rounded,
                            color: Colors.redAccent,
                            onTap: () => UrlHelper.launchURL(
                              'mailto:${AppConstants.supportEmail}',
                            ),
                          ),
                          SizedBox(width: context.insets.md),
                          DeveloperSocialCard(
                            icon: Icons.chat_rounded,
                            color: Colors.green,
                            onTap: () => UrlHelper.launchWhatsApp(
                              phone: AppConstants.developerNumber,
                            ),
                          ),
                          SizedBox(width: context.insets.md),
                          DeveloperSocialCard(
                            icon: Icons.phone,
                            color: Colors.cyan,
                            onTap: () => UrlHelper.launchPhone(
                              AppConstants.developerNumber,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.insets.lg),
                      Text(
                        'إصدار ${AppConstants.appVersion}',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.textPrimary.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 10.sp,
                        ),
                      ),
                      SizedBox(height: context.insets.sm),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
