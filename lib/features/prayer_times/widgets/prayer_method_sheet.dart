import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/prayer_times/models/prayer_calc_settings.dart';
import 'package:thekr_app/features/prayer_times/providers/prayer_calc_provider.dart';
import 'package:thekr_app/features/prayer_times/widgets/prayer_choice_tile.dart';
import 'package:thekr_app/features/settings/widgets/settings_section.dart';

/// The list of calculation methods, opened from the settings screen.
class PrayerMethodSheet extends ConsumerWidget {
  const PrayerMethodSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chosen = ref.watch(prayerCalcProvider).method;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.62,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: context.insets.md),
        children: [
          SettingsSection(
            children: [
              for (final method in PrayerCalcMethod.values)
                PrayerChoiceTile(
                  title: method.title,
                  detail: method.detail,
                  selected: method == chosen,
                  onTap: () {
                    ref.read(prayerCalcProvider.notifier).setMethod(method);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
