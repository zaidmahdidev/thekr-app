import 'package:flutter/material.dart';
import 'package:thekr_app/features/hadith/data/hadith_nawawi_model.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/features/hadith/widgets/custom_azkar_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/widgets/base_app_bar.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

@RoutePage()
class HadithNawawiScreen extends ConsumerWidget {
  const HadithNawawiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: BaseAppBar(
        title: 'الأربعين النووية',
        actions: [
          IconButton(
            icon: const AppIcon(HugeIcons.strokeRoundedZoomIn),
            onPressed: () {
              final currentSize = ref.read(settingsProvider).fontSize;
              if (currentSize < SettingsState.maxFontSize) {
                ref.read(settingsProvider.notifier).updateFontSize(currentSize + SettingsState.fontSizeStep);
              }
            },
          ),
          IconButton(
            icon: const AppIcon(HugeIcons.strokeRoundedZoomOut),
            onPressed: () {
              final currentSize = ref.read(settingsProvider).fontSize;
              if (currentSize > SettingsState.minFontSize) {
                ref.read(settingsProvider.notifier).updateFontSize(currentSize - SettingsState.fontSizeStep);
              }
            },
          ),
        ],
      ),
      body: Scrollbar(
        child: ListView.builder(
          itemCount: hadithNawawi.length,
          itemBuilder: (context, index) {
            final hadith = hadithNawawi[index]['hadith'];
            final description = hadithNawawi[index]['description'];

            return CustomAzkarWidget(details: hadith, bless: description);
          },
        ),
      ),
    );
  }
}
