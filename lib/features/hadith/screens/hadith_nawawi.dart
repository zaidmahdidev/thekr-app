import 'package:flutter/material.dart';
import 'package:thekr_app/features/hadith/data/hadith_nawawi_model.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:thekr_app/features/hadith/widgets/custom_azkar_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/widgets/base_app_bar.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

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
            icon: const Icon(Icons.text_increase_rounded),
            onPressed: () {
              final currentSize = ref.read(settingsProvider).fontSize;
              if (currentSize < 24) {
                ref.read(settingsProvider.notifier).updateFontSize(currentSize + 2);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease_rounded),
            onPressed: () {
              final currentSize = ref.read(settingsProvider).fontSize;
              if (currentSize > 14) {
                ref.read(settingsProvider.notifier).updateFontSize(currentSize - 2);
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
