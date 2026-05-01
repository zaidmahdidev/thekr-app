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
                      const Divider(height: 1, indent: 20, endIndent: 20),
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
                                  style: context.textStyles.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                    child: Container(
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
                                        child: Container(
                                          width: 32.w,
                                          height: 32.w,
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
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 20,
                                                )
                                              : null,
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
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      SettingsTile(
                        title: 'ترتيب الشاشة الرئيسية',
                        subtitle: 'تحكم في مكان ظهور العناصر في الرئيسية',
                        icon: Icons.dashboard_customize_rounded,
                        onTap: () => context.router.push(
                          const CustomizeHomeLayoutRoute(),
                        ),
                        iconColor: Colors.purple,
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      // Font Size Adjustment (Moved here)
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
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      // Share Card Settings (Moved here)
                      Padding(
                        padding: EdgeInsets.all(context.insets.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'شكل بطاقة المشاركة',
                              style: context.textStyles.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: context.insets.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: ShareTemplate.values.map((template) {
                                final isSelected =
                                    settings.shareTemplate == template;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => ref
                                        .read(settingsProvider.notifier)
                                        .updateShareTemplate(template),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? context.colors.primary.withValues(
                                                alpha: 0.1,
                                              )
                                            : context.colors.surface,
                                        borderRadius: BorderRadius.circular(
                                          context.corners.md,
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? context.colors.primary
                                              : context.colors.primary
                                                    .withValues(alpha: 0.1),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            template == ShareTemplate.classic
                                                ? Icons.auto_awesome_rounded
                                                : template ==
                                                      ShareTemplate.luxury
                                                ? Icons
                                                      .workspace_premium_rounded
                                                : Icons.waves_rounded,
                                            color: isSelected
                                                ? context.colors.primary
                                                : context.colors.textSecondary,
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            template.title.split(' ')[0],
                                            style: context.textStyles.bodySmall
                                                ?.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: isSelected
                                                      ? context.colors.primary
                                                      : context
                                                            .colors
                                                            .textPrimary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: context.insets.lg),
                            // Live Preview Card
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'معاينة بطاقة المشاركة',
                                    style: context.textStyles.bodySmall
                                        ?.copyWith(
                                          color: context.colors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  SizedBox(height: context.insets.sm),
                                  SizedBox(
                                    width: 0.6.sw,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: ShareService.buildShareCard(
                                        context,
                                        settings.shareTemplate,
                                        '﴿فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ﴾',
                                        null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                  Center(
                    child: Text(
                      'الإصدار ${AppConstants.appVersion}',
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
