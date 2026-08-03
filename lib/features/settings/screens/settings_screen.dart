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
import 'package:thekr_app/core/providers/feature_badge_provider.dart';
import 'package:thekr_app/core/widgets/new_feature_badge.dart';
import 'package:thekr_app/features/settings/widgets/durood_settings_sheet.dart';

@RoutePage()
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Settings are loaded automatically via settingsProvider
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> _selectMorningTime(TimeOfDay currentTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null) {
      ref.read(settingsProvider.notifier).updateMorningTime(picked);
    }
  }

  Future<void> _selectEveningTime(TimeOfDay currentTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null) {
      ref.read(settingsProvider.notifier).updateEveningTime(picked);
    }
  }

  Future<void> _updateMorningNotification(bool val) async {
    ref.read(settingsProvider.notifier).toggleMorningNotification(val);
    if (val) {
      showToast(text: 'تم تفعيل تذكير أذكار الصباح');
    } else {
      showToast(text: 'تم إلغاء تذكير أذكار الصباح');
    }
  }

  Future<void> _updateEveningNotification(bool val) async {
    ref.read(settingsProvider.notifier).toggleEveningNotification(val);
    if (val) {
      showToast(text: 'تم تفعيل تذكير أذكار المساء');
    } else {
      showToast(text: 'تم إلغاء تذكير أذكار المساء');
    }
  }

  Future<void> _updateFridayNotification(bool val) async {
    ref.read(settingsProvider.notifier).toggleFridayNotification(val);
    if (val) {
      showToast(text: 'تم تفعيل تذكير سورة الكهف');
    } else {
      showToast(text: 'تم إلغاء تذكير سورة الكهف');
    }
  }

  Future<void> _selectWirdTime(TimeOfDay currentTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null) {
      ref.read(settingsProvider.notifier).updateWirdTime(picked);
    }
  }

  Future<void> _updateWirdNotification(bool val) async {
    ref.read(settingsProvider.notifier).toggleWirdNotification(val);
    if (val) {
      showToast(text: 'تم تفعيل تذكير الورد اليومي');
    } else {
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
                                AppButton(
                                  text:
                                      'الافتراضي ' +
                                      '(${settings.fontSize.toInt()})',
                                  size: AppButtonSize.small,
                                  isFullWidth: false,
                                  onTap: () => ref
                                      .read(settingsProvider.notifier)
                                      .updateFontSize(16.0),
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
                      SettingsTile(
                        title: 'بطاقة المشاركة',
                        subtitle: 'تخصيص شكل ومحتوى بطاقة المشاركة ',
                        icon: Icons.auto_awesome_outlined,
                        iconColor: Colors.orange,
                        onTap: () =>
                            context.pushRoute(const CustomizeShareCardRoute()),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: context.insets.sm),
                        child: SettingsTile(
                          title: 'أذكاري الخاصة',
                          subtitle: 'أضف أذكارك الشخصية وشاركها',
                          icon: Icons.bookmark_added_rounded,
                          onTap: () =>
                              context.router.push(const UserAzkarRoute()),
                          iconColor: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.insets.md),
                  const SectionHeader(title: 'التنبيهات والأذان'),
                  SettingsSection(
                    children: [
                      NewFeatureBadge(
                        featureId: 'prayer_alerts',
                        addedInVersion: '1.3.0',
                        child: SettingsTile(
                          title: 'تنبيه الصلوات',
                          subtitle: 'تخصيص تنبيه الأذان لكل صلاة بشكل منفصل واختيار صوت المؤذن.',
                          icon: Icons.notifications_active_rounded,
                          iconColor: context.colors.primary,
                          onTap: () {
                            ref.read(featureBadgeProvider.notifier).recordFeatureClick('prayer_alerts');
                            context.router.push(const AthanSettingsRoute());
                          },
                        ),
                      ),
                      NewFeatureBadge(
                        featureId: 'durood_reminder',
                        addedInVersion: '1.3.0',
                        child: SettingsTile(
                          title: 'التذكير بالصلاة على النبي',
                          subtitle: settings.duroodInterval == 0 
                              ? 'التذكير متوقف'
                              : settings.duroodInterval == 30
                                  ? 'كل نصف ساعة' 
                              : settings.duroodInterval == 60 
                                  ? 'كل ساعة' 
                                  : settings.duroodInterval == 10080 
                                      ? 'يوم الجمعة فقط' 
                                      : settings.duroodInterval == 1440 
                                          ? 'مرة يومياً' 
                                          : 'كل ${settings.duroodInterval ~/ 60} ساعات',
                          icon: Icons.mosque_rounded,
                          iconColor: Colors.teal,
                          onTap: () {
                            ref.read(featureBadgeProvider.notifier).recordFeatureClick('durood_reminder');
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) => const DuroodSettingsSheet(),
                            );
                          },
                        ),
                      ),
                      SettingsTile(
                        title: 'أذكار الصباح',
                        subtitle: settings.morningNotificationEnabled
                            ? 'تذكير عند ${_formatTime(settings.morningNotificationTime)}'
                            : 'التذكير متوقف',
                        icon: Icons.wb_sunny_rounded,
                        iconColor: Colors.orange,
                        trailing: Switch.adaptive(
                          value: settings.morningNotificationEnabled,
                          onChanged: _updateMorningNotification,
                        ),
                        onTap: settings.morningNotificationEnabled
                            ? () => _selectMorningTime(
                                settings.morningNotificationTime,
                              )
                            : null,
                      ),
                      SettingsTile(
                        title: 'أذكار المساء',
                        subtitle: settings.eveningNotificationEnabled
                            ? 'تذكير عند ${_formatTime(settings.eveningNotificationTime)}'
                            : 'التذكير متوقف',
                        icon: Icons.nightlight_round_rounded,
                        iconColor: Colors.blueAccent,
                        trailing: Switch.adaptive(
                          value: settings.eveningNotificationEnabled,
                          onChanged: _updateEveningNotification,
                        ),
                        onTap: settings.eveningNotificationEnabled
                            ? () => _selectEveningTime(
                                settings.eveningNotificationTime,
                              )
                            : null,
                      ),
                      SettingsTile(
                        title: 'تذكير الورد اليومي',
                        subtitle: settings.wirdNotificationEnabled
                            ? 'تذكير عند ${_formatTime(settings.wirdNotificationTime)}'
                            : 'التذكير متوقف',
                        icon: Icons.menu_book_rounded,
                        iconColor: context.colors.primary,
                        trailing: Switch.adaptive(
                          value: settings.wirdNotificationEnabled,
                          onChanged: _updateWirdNotification,
                        ),
                        onTap: settings.wirdNotificationEnabled
                            ? () =>
                                  _selectWirdTime(settings.wirdNotificationTime)
                            : null,
                      ),
                      SettingsTile(
                        title: 'تذكير سورة الكهف',
                        subtitle: settings.fridayNotificationEnabled
                            ? 'كل يوم جمعة صباحاً'
                            : 'التذكير متوقف',
                        icon: Icons.auto_stories_rounded,
                        iconColor: Colors.green,
                        trailing: Switch.adaptive(
                          value: settings.fridayNotificationEnabled,
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
