import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/extensions/ui_extension.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/features/prayer_times/models/prayer_calc_settings.dart';
import 'package:thekr_app/features/prayer_times/providers/prayer_calc_provider.dart';
import 'package:thekr_app/features/prayer_times/providers/prayer_times_providers.dart';
import 'package:thekr_app/features/prayer_times/widgets/prayer_adjustment_row.dart';
import 'package:thekr_app/features/prayer_times/widgets/prayer_calc_preview.dart';
import 'package:thekr_app/features/prayer_times/widgets/prayer_calc_reset_bar.dart';
import 'package:thekr_app/features/prayer_times/widgets/prayer_choice_tile.dart';
import 'package:thekr_app/features/prayer_times/widgets/prayer_method_sheet.dart';
import 'package:thekr_app/features/settings/widgets/settings_section.dart';
import 'package:thekr_app/features/settings/widgets/settings_tile.dart';

/// How prayer times are calculated: method, Asr school, high latitudes and
/// minute adjustments, with the times shown live above.
@RoutePage()
class PrayerCalcSettingsScreen extends ConsumerWidget {
  const PrayerCalcSettingsScreen({super.key});

  /// From this latitude (degrees, north or south) the high-latitude rules are
  /// offered: further out, the evening twilight may never end in summer.
  static const double highLatitudeFrom = 48;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final settings = ref.watch(prayerCalcProvider);
    final notifier = ref.read(prayerCalcProvider.notifier);

    // The northern-regions rules matter only where the night gets very short.
    // Elsewhere they would only confuse, unless they were already changed.
    final latitude = ref
        .watch(prayerLocationProvider)
        .value
        ?.coordinates
        .latitude;
    final showHighLatitude =
        (latitude != null && latitude.abs() >= highLatitudeFrom) ||
        settings.highLatitude != HighLatitudeMode.middleOfNight;

    return AppScaffold(
      title: 'حساب المواقيت',
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(context.insets.lg),
        children: [
          const PrayerCalcPreview(),
          if (!settings.isDefault) PrayerCalcResetBar(onReset: notifier.reset),
          SizedBox(height: context.insets.lg),

          const SectionHeader(title: 'طريقة الحساب'),
          SettingsSection(
            children: [
              SettingsTile(
                title: settings.method.title,
                subtitle: settings.method.detail,
                icon: HugeIcons.strokeRoundedCalculator,
                iconColor: colors.primary,
                onTap: () => context.showSheet<void>(
                  title: 'طريقة الحساب',
                  child: const PrayerMethodSheet(),
                ),
              ),
              if (settings.method == PrayerCalcMethod.ummAlQura)
                SettingsTile(
                  title: 'عشاء رمضان بعد 120 دقيقة',
                  subtitle: 'يكون العشاء بعد المغرب بساعتين في رمضان، كما في التقويم الرسمي',
                  icon: HugeIcons.strokeRoundedMoon02,
                  iconColor: colors.secondary,
                  switchValue: settings.ramadanIsha,
                  onSwitchChanged: notifier.setRamadanIsha,
                ),
            ],
          ),
          SizedBox(height: context.insets.lg),

          const SectionHeader(title: 'وقت العصر'),
          SettingsSection(
            children: [
              for (final madhab in AsrMadhab.values)
                PrayerChoiceTile(
                  title: madhab.title,
                  detail: madhab.detail,
                  selected: madhab == settings.madhab,
                  onTap: () => notifier.setMadhab(madhab),
                ),
            ],
          ),
          SizedBox(height: context.insets.lg),

          const SectionHeader(title: 'تعديل بالدقائق'),
          Padding(
            padding: EdgeInsets.only(
              right: context.insets.sm,
              bottom: context.insets.sm,
            ),
            child: Text(
              'لمطابقة مسجدك: قدّم الوقت أو أخّره بدقائق قليلة.',
              style: (context.textStyles.bodySmall ?? const TextStyle())
                  .copyWith(color: colors.textSecondary),
            ),
          ),
          SettingsSection(
            children: [
              for (final prayer in AppPrayer.values)
                PrayerAdjustmentRow(
                  name: prayer.nameArabic,
                  minutes: settings.adjustmentOf(prayer),
                  onChanged: (delta) => notifier.adjust(prayer, delta),
                ),
            ],
          ),

          if (showHighLatitude) ...[
            SizedBox(height: context.insets.lg),
            const SectionHeader(title: 'المناطق الشمالية'),
            Padding(
              padding: EdgeInsets.only(
                right: context.insets.sm,
                bottom: context.insets.sm,
              ),
              child: Text(
                'للبلاد التي يقصر فيها الليل جداً في الصيف، فيضيع الفجر أو العشاء.',
                style: (context.textStyles.bodySmall ?? const TextStyle())
                    .copyWith(color: colors.textSecondary),
              ),
            ),
            SettingsSection(
              children: [
                for (final mode in HighLatitudeMode.values)
                  PrayerChoiceTile(
                    title: mode.title,
                    detail: mode.detail,
                    selected: mode == settings.highLatitude,
                    onTap: () => notifier.setHighLatitude(mode),
                  ),
              ],
            ),
          ],
          SizedBox(height: context.insets.lg),
        ],
      ),
    );
  }
}
