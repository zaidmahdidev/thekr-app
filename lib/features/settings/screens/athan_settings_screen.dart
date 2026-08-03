import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/core/widgets/base_app_bar.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';
import 'package:thekr_app/features/settings/widgets/settings_section.dart';
import 'package:thekr_app/features/settings/widgets/settings_tile.dart';
import 'package:thekr_app/core/services/notification_service.dart';
import 'package:thekr_app/features/home/providers/prayer_provider.dart';

@RoutePage()
class AthanSettingsScreen extends ConsumerWidget {
  const AthanSettingsScreen({super.key});

  void _triggerRefresh(WidgetRef ref) {
    ref.read(prayerTimesProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return AppScaffold(
      title: 'تنبيه الصلوات',
      body: ListView(
        padding: EdgeInsets.all(context.insets.lg),
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.insets.sm),
            child: Text(
              'تفعيل الأذان لكل صلاة',
              style: context.textStyles.titleMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: context.insets.sm),
          SettingsSection(
            children: [
              SettingsTile(
                title: 'صلاة الفجر',
                icon: Icons.brightness_3_rounded,
                iconColor: Colors.indigo,
                trailing: Switch.adaptive(
                  value: settings.fajrAthanEnabled,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleFajrAthan(val);
                    _triggerRefresh(ref);
                  },
                ),
              ),
              SettingsTile(
                title: 'صلاة الظهر',
                icon: Icons.wb_sunny_rounded,
                iconColor: Colors.orange,
                trailing: Switch.adaptive(
                  value: settings.dhuhrAthanEnabled,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleDhuhrAthan(val);
                    _triggerRefresh(ref);
                  },
                ),
              ),
              SettingsTile(
                title: 'صلاة العصر',
                icon: Icons.brightness_low_rounded,
                iconColor: Colors.amber,
                trailing: Switch.adaptive(
                  value: settings.asrAthanEnabled,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleAsrAthan(val);
                    _triggerRefresh(ref);
                  },
                ),
              ),
              SettingsTile(
                title: 'صلاة المغرب',
                icon: Icons.nights_stay_rounded,
                iconColor: Colors.deepOrange,
                trailing: Switch.adaptive(
                  value: settings.maghribAthanEnabled,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleMaghribAthan(val);
                    _triggerRefresh(ref);
                  },
                ),
              ),
              SettingsTile(
                title: 'صلاة العشاء',
                icon: Icons.star_rounded,
                iconColor: Colors.deepPurple,
                trailing: Switch.adaptive(
                  value: settings.ishaAthanEnabled,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleIshaAthan(val);
                    _triggerRefresh(ref);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
