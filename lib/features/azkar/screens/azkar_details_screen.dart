import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/azkar/widgets/azkar_item_widget.dart';
import 'package:thekr_app/features/azkar/widgets/azkar_paged_view.dart';
import 'package:thekr_app/core/services/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

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
  PageController _pageController = PageController();

  /// The thikr the user is on, kept when the layout is switched so the other
  /// layout opens at the same place instead of at the top.
  int _currentIndex = 0;
  final GlobalKey _listKey = GlobalKey();
  late final List<GlobalKey> _itemKeys;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    AnalyticsService.logZekrSelected(widget.type, widget.type);
    _itemKeys = List.generate(widget.azkarList.length, (_) => GlobalKey());
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

  /// The first thikr still showing at the top of the list.
  void _rememberListPosition() {
    final list = _listKey.currentContext?.findRenderObject();
    if (list is! RenderBox || !list.attached) return;
    final top = list.localToGlobal(Offset.zero).dy;
    for (var i = 0; i < _itemKeys.length; i++) {
      final box = _itemKeys[i].currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      final bottom = box.localToGlobal(Offset(0, box.size.height)).dy;
      if (bottom > top + 1) {
        _currentIndex = i;
        return;
      }
    }
  }

  /// Switches between the list and the swiped pages, staying on the same thikr.
  void _switchLayout(bool wasHorizontal) {
    HapticFeedback.selectionClick();
    if (wasHorizontal) {
      // Pages to list: scroll the list to the thikr the pages were on.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _itemKeys[_currentIndex].currentContext;
        if (target != null) {
          Scrollable.ensureVisible(target, duration: Duration.zero);
        }
      });
    } else {
      // List to pages: open the pages at the thikr the list was on.
      _rememberListPosition();
      final old = _pageController;
      _pageController = PageController(initialPage: _currentIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
    ref
        .read(settingsProvider.notifier)
        .setAzkarLayout(
          wasHorizontal ? AzkarLayout.vertical : AzkarLayout.horizontal,
        );
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
              _advanceFrom(index);
            }
          });
        }
      }
    });
  }

  /// In the horizontal layout, moves on to the next unfinished thikr once one
  /// is completed.
  void _advanceFrom(int index) {
    if (ref.read(settingsProvider).azkarLayout != AzkarLayout.horizontal ||
        !_pageController.hasClients) {
      return;
    }
    final next = azkarWithCounters.indexWhere(
      (azkar) => !azkar['isCompleted'],
      index + 1,
    );
    if (next == -1) return;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
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

  /// How much of the whole is done, counted in repetitions: every tap moves the
  /// bar by the same amount. (Counting each thikr as one equal part made the bar
  /// stand still through a thikr said 33 times, then jump on one said once.)
  double _calculateTotalProgress() {
    var total = 0;
    var done = 0;
    for (final azkar in azkarWithCounters) {
      final original = azkar['originalCount'] as int;
      final current = azkar['currentCount'] as int;
      if (original <= 0) continue;
      total += original;
      done += original - current;
    }
    return total == 0 ? 0.0 : done / total;
  }

  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(settingsProvider.select((s) => s.azkarLayout));
    final isHorizontal = layout == AzkarLayout.horizontal;

    return AppScaffold(
      appBar: BaseAppBar(
        title: widget.type,
        actions: [
          IconButton(
            tooltip: isHorizontal ? 'عرض كقائمة' : 'عرض بالتمرير الأفقي',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: AppIcon(
                isHorizontal
                    ? HugeIcons.strokeRoundedLayout2Row
                    : HugeIcons.strokeRoundedLayout2Column,
                key: ValueKey(isHorizontal),
              ),
            ),
            onPressed: () => _switchLayout(isHorizontal),
          ),
          IconButton(
            icon: const AppIcon(HugeIcons.strokeRoundedZoomIn),
            onPressed: () {
              final currentSize = ref.read(settingsProvider).fontSize;
              if (currentSize < SettingsState.maxFontSize) {
                ref
                    .read(settingsProvider.notifier)
                    .updateFontSize(currentSize + SettingsState.fontSizeStep);
              }
            },
          ),
          IconButton(
            icon: const AppIcon(HugeIcons.strokeRoundedZoomOut),
            onPressed: () {
              final currentSize = ref.read(settingsProvider).fontSize;
              if (currentSize > SettingsState.minFontSize) {
                ref
                    .read(settingsProvider.notifier)
                    .updateFontSize(currentSize - SettingsState.fontSizeStep);
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
                  const AppIcon(
                    HugeIcons.strokeRoundedCheckmarkCircle02,
                    color: Colors.green,
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
          : isHorizontal
          ? AzkarPagedView(
              items: azkarWithCounters,
              controller: _pageController,
              onTapItem: _decrementCounter,
              onPageChanged: (page) => _currentIndex = page,
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (_) {
                _rememberListPosition();
                return false;
              },
              child: ListView.builder(
                key: _listKey,
                padding: const EdgeInsets.only(top: 10),
                // The list is short; building all of it lets the position of any
                // thikr be found when the layout is switched.
                cacheExtent: 100000,
                itemCount: azkarWithCounters.length,
                itemBuilder: (context, index) {
                  var azkar = azkarWithCounters[index];

                  return AnimatedContainer(
                    key: _itemKeys[index],
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
            ),
    );
  }
}
