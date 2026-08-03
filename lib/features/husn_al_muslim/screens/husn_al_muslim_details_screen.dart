import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/husn_al_muslim/widgets/husn_al_muslim_item_widget.dart';
import 'package:thekr_app/core/widgets/base_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

@RoutePage()
class HusinAlMuslimDetailsScreen extends ConsumerStatefulWidget {
  final String title;
  final Map<String, dynamic> dhikrData;

  const HusinAlMuslimDetailsScreen({
    Key? key,
    required this.title,
    required this.dhikrData,
  }) : super(key: key);

  @override
  ConsumerState<HusinAlMuslimDetailsScreen> createState() =>
      _HusinAlMuslimDetailsScreenState();
}

class _HusinAlMuslimDetailsScreenState
    extends ConsumerState<HusinAlMuslimDetailsScreen> {
  late List<Map<String, dynamic>> dhikrWithCounters;
  bool allCompleted = false;

  @override
  void initState() {
    super.initState();
    List<String> textList = List<String>.from(widget.dhikrData['text'] ?? []);
    List<String> footnoteList = List<String>.from(
      widget.dhikrData['footnote'] ?? [],
    );

    dhikrWithCounters = textList.asMap().entries.map((entry) {
      int index = entry.key;
      String text = entry.value;

      return {
        'text': text,
        'footnote': index < footnoteList.length ? footnoteList[index] : '',
        'currentCount': 1,
        'originalCount': 1,
        'isCompleted': false,
      };
    }).toList();
  }

  void _decrementCounter(int index) {
    setState(() {
      if (dhikrWithCounters[index]['currentCount'] > 0) {
        HapticFeedback.lightImpact();
        dhikrWithCounters[index]['currentCount']--;

        if (dhikrWithCounters[index]['currentCount'] == 0) {
          HapticFeedback.mediumImpact();

          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                dhikrWithCounters[index]['isCompleted'] = true;
              });
              _checkAllCompleted();
            }
          });
        }
      }
    });
  }

  void _checkAllCompleted() {
    bool allDone = dhikrWithCounters.every((dhikr) => dhikr['isCompleted']);
    if (allDone && !allCompleted) {
      setState(() {
        allCompleted = true;
      });
      context.router.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: BaseAppBar(
        title: widget.title,
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
      body: dhikrWithCounters.where((dhikr) => !dhikr['isCompleted']).isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: context.colors.primary,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تم إكمال جميع الأذكار',
                    style: context.textStyles.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'تقبل الله منك',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: dhikrWithCounters.length,
              itemBuilder: (context, index) {
                var dhikr = dhikrWithCounters[index];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: dhikr['isCompleted'] ? 0 : null,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: dhikr['isCompleted'] ? 0.0 : 1.0,
                    child: dhikr['isCompleted']
                        ? const SizedBox.shrink()
                        : HusnAlMuslimItemWidget(
                            text: dhikr['text'],
                            footnote: dhikr['footnote'],
                            currentCount: dhikr['currentCount'],
                            originalCount: dhikr['originalCount'],
                            onTap: () => _decrementCounter(index),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
