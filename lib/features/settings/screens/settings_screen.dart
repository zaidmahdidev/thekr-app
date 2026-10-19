import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/settings/widgets/developer_social_card.dart';
import 'package:thekr_app/features/settings/widgets/settings_section.dart';
import 'package:thekr_app/features/settings/widgets/settings_tile.dart';
import 'package:thekr_app/core/utils/url_helper.dart';
import 'package:thekr_app/core/services/review_service.dart';
import 'package:thekr_app/core/router/app_router.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';
import 'package:thekr_app/features/settings/widgets/app_share_sheet.dart';
import 'package:thekr_app/core/providers/feature_badge_provider.dart';
import 'package:thekr_app/core/widgets/new_feature_badge.dart';
import 'package:thekr_app/features/settings/widgets/durood_settings_sheet.dart';
import 'package:thekr_app/features/settings/widgets/font_size_settings_sheet.dart';
import 'package:thekr_app/features/settings/widgets/theme_settings_sheet.dart';
import 'package:thekr_app/core/theme/tokens/design_tokens.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/utils/constants/app_icons.dart';
import 'package:hugeicons/hugeicons.dart';

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

  String _getThemeName(AppThemeType type) {
    switch (type) {
      case AppThemeType.defaultTheme:
        return 'الزمردي (الافتراضي)';
      case AppThemeType.desert:
        return 'الصحراوي الدافئ';
      case AppThemeType.forest:
        return 'الزيتي الهادئ';
    }
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
                        subtitle: Theme.of(context).brightness == Brightness.dark
                            ? 'مفعل'
                            : 'متوقف',
                        icon: HugeIcons.strokeRoundedMoon02,
                        iconColor: context.colors.primary,
                        trailing: Switch.adaptive(
                          value: Theme.of(context).brightness == Brightness.dark,
                          activeThumbColor: context.colors.primary,
                          activeTrackColor:
                              context.colors.primary.withValues(alpha: 0.5),
                          onChanged: (val) => ref
                              .read(settingsProvider.notifier)
                              .toggleTheme(
                                val ? ThemeMode.dark : ThemeMode.light,
                              ),
                        ),
                      ),
                      SettingsTile(
                        title: 'ألوان التطبيق',
                        subtitle: _getThemeName(settings.appTheme),
                        icon: HugeIcons.strokeRoundedPalette,
                        iconColor: context.colors.secondary,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.background,
                                borderRadius:
                                    BorderRadius.circular(context.corners.rc360),
                                border: Border.all(
                                  color: context.colors.textSecondary
                                      .withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 11.w,
                                    height: 11.w,
                                    decoration: BoxDecoration(
                                      color: context.colors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Container(
                                    width: 11.w,
                                    height: 11.w,
                                    decoration: BoxDecoration(
                                      color: context.colors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: context.insets.sm),
                            AppIcon(
                              HugeIcons.strokeRoundedArrowRight01,
                              size: 16.sp,
                              color: context.colors.textSecondary,
                            ),
                          ],
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => const ThemeSettingsSheet(),
                          );
                        },
                      ),
                      SettingsTile(
                        title: 'حجم الخط في القراءة',
                        subtitle:
                            '${settings.fontSize.toInt()} نقطة (معاينة حية)',
                        icon: HugeIcons.strokeRoundedTextFont,
                        iconColor: context.colors.primary,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => const FontSizeSettingsSheet(),
                          );
                        },
                      ),
                      SettingsTile(
                        title: 'ترتيب الشاشة الرئيسية',
                        subtitle: 'تحكم في مكان ظهور العناصر في الرئيسية',
                        icon: HugeIcons.strokeRoundedDashboardSquare01,
                        iconColor: context.colors.primary,
                        onTap: () => context.router.push(
                          const CustomizeHomeLayoutRoute(),
                        ),
                      ),
                      SettingsTile(
                        title: 'بطاقة المشاركة',
                        subtitle: 'تخصيص شكل ومحتوى بطاقة المشاركة',
                        icon: HugeIcons.strokeRoundedSparkles,
                        iconColor: context.colors.secondary,
                        onTap: () =>
                            context.pushRoute(const CustomizeShareCardRoute()),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: context.insets.sm),
                        child: SettingsTile(
                          title: 'أذكاري الخاصة',
                          subtitle: 'أضف أذكارك الشخصية وشاركها',
                          icon: HugeIcons.strokeRoundedBookmarkCheck01,
                          iconColor: context.colors.primary,
                          onTap: () =>
                              context.router.push(const UserAzkarRoute()),
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
                        addedInVersion: '1.3.1',
                        child: SettingsTile(
                          title: 'تنبيه الصلوات',
                          subtitle: 'تخصيص تنبيه الأذان لكل صلاة بشكل منفصل واختيار صوت المؤذن.',
                          icon: HugeIcons.strokeRoundedNotification01,
                          iconColor: context.colors.primary,
                          onTap: () {
                            ref.read(featureBadgeProvider.notifier).recordFeatureClick('prayer_alerts');
                            context.router.push(const AthanSettingsRoute());
                          },
                        ),
                      ),
                      NewFeatureBadge(
                        featureId: 'durood_reminder',
                        addedInVersion: '1.3.1',
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
                          icon: HugeIcons.strokeRoundedMosque01,
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
                        icon: HugeIcons.strokeRoundedSun03,
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
                        icon: HugeIcons.strokeRoundedMoon02,
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
                        icon: HugeIcons.strokeRoundedBookOpen01,
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
                        icon: HugeIcons.strokeRoundedBookOpenText,
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
                        icon: HugeIcons.strokeRoundedStar,
                        iconColor: Colors.amber,
                        onTap: () => ReviewService.requestManualReview(),
                      ),
                      SettingsTile(
                        title: 'تواصل معنا',
                        icon: HugeIcons.strokeRoundedMessage01,
                        iconColor: Colors.teal,
                        onTap: () => UrlHelper.launchWhatsApp(
                          phone: AppConstants.whatsappNumber,
                          message: 'السلام عليكم، لدي استفسار بخصوص تطبيق ذكر',
                        ),
                      ),
                      SettingsTile(
                        title: 'سياسة الخصوصية',
                        icon: HugeIcons.strokeRoundedSecurityCheck,
                        iconColor: Colors.redAccent,
                        onTap: () =>
                            UrlHelper.launchURL(AppConstants.privacyPolicyUrl),
                      ),
                      SettingsTile(
                        title: 'شارك التطبيق',
                        icon: AppIcons.share,
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
                            icon: HugeIcons.strokeRoundedGlobe02,
                            color: Colors.blue,
                            onTap: () =>
                                UrlHelper.launchURL(AppConstants.websiteUrl),
                          ),
                          SizedBox(width: context.insets.md),
                          DeveloperSocialCard(
                            icon: HugeIcons.strokeRoundedMail01,
                            color: Colors.redAccent,
                            onTap: () => UrlHelper.launchURL(
                              'mailto:${AppConstants.supportEmail}',
                            ),
                          ),
                          SizedBox(width: context.insets.md),
                          DeveloperSocialCard(
                            icon: HugeIcons.strokeRoundedMessage01,
                            color: Colors.green,
                            onTap: () => UrlHelper.launchWhatsApp(
                              phone: AppConstants.developerNumber,
                            ),
                          ),
                          SizedBox(width: context.insets.md),
                          DeveloperSocialCard(
                            icon: HugeIcons.strokeRoundedCall,
                            color: Colors.cyan,
                            onTap: () => UrlHelper.launchPhone(
                              AppConstants.developerNumber,
                            ),
                          ),
                          SizedBox(width: context.insets.md),
                          DeveloperSocialCard(
                            icon: HugeIcons.strokeRoundedGithub,
                            color: context.colors.textPrimary,
                            onTap: () =>
                                UrlHelper.launchURL(AppConstants.githubUrl),
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
