import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readmore/readmore.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/widgets/my_card.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/azkar/widgets/azkar_item_widget.dart';
import 'package:thekr_app/core/services/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

@RoutePage()
class AzkarListScreen extends ConsumerStatefulWidget {
  final List<Map<String, String>> azkarList;
  final String type;

  const AzkarListScreen({Key? key, required this.azkarList, required this.type})
    : super(key: key);

  @override
  ConsumerState<AzkarListScreen> createState() => _AzkarListScreenState();
}

class _AzkarListScreenState extends ConsumerState<AzkarListScreen> {
  late List<Map<String, dynamic>> azkarWithCounters;
  bool allCompleted = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logZekrSelected(widget.type, widget.type);
    azkarWithCounters = widget.azkarList.map((azkar) {
      final repeatStr = azkar['repeat'] ?? '1';
      final count = int.tryParse(repeatStr) ?? 1;
      return {
        'zekr': azkar['zekr']!,
        'repeat': repeatStr,
        'bless': azkar['bless']!,
        'currentCount': count,
        'originalCount': count,
        'isCompleted': false,
      };
    }).toList();
  }

  void _decrementCounter(int index) {
    setState(() {
      if (azkarWithCounters[index]['currentCount'] > 0) {
        HapticFeedback.lightImpact();
        azkarWithCounters[index]['currentCount']--;

        if (azkarWithCounters[index]['currentCount'] == 0) {
          HapticFeedback.mediumImpact();

          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                azkarWithCounters[index]['isCompleted'] = true;
              });
              _checkAllCompleted();
            }
          });
        }
      }
    });
  }

  void _checkAllCompleted() {
    bool allDone = azkarWithCounters.every((azkar) => azkar['isCompleted']);
    if (allDone && !allCompleted) {
      setState(() {
        allCompleted = true;
      });
      context.router.back();
    }
  }

  double _calculateTotalProgress() {
    if (azkarWithCounters.isEmpty) return 0.0;

    double totalProgress = 0.0;
    for (var azkar in azkarWithCounters) {
      int original = azkar['originalCount'] as int;
      int current = azkar['currentCount'] as int;
      if (original > 0) {
        totalProgress += (original - current) / original;
      }
    }

    return totalProgress / azkarWithCounters.length;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: BaseAppBar(
        title: widget.type,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0, end: _calculateTotalProgress()),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.secondary,
                    ),
                    minHeight: 6,
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body: azkarWithCounters.where((azkar) => !azkar['isCompleted']).isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
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
              padding: const EdgeInsets.only(top: 10),
              itemCount: azkarWithCounters.length,
              itemBuilder: (context, index) {
                var azkar = azkarWithCounters[index];

                return AnimatedContainer(
                  key: ValueKey(azkar['zekr']),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  height: azkar['isCompleted'] ? 0 : null,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: azkar['isCompleted'] ? 0.0 : 1.0,
                    child: azkar['isCompleted']
                        ? const SizedBox.shrink()
                        : AzkarItemWidget(
                            details: azkar['zekr'],
                            bless: azkar['bless'],
                            currentCount: azkar['currentCount'],
                            originalCount: azkar['originalCount'],
                            onTap: () => _decrementCounter(index),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
