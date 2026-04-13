import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readmore/readmore.dart';
import '../../shard/components/tools.dart';
import '../../shard/constant/theme.dart';
import '../../shard/utils/share_helper.dart';

class AzkarListScreen extends StatefulWidget {
  final List<Map<String, String>> azkarList;
  final String type;

  const AzkarListScreen({Key? key, required this.azkarList, required this.type})
    : super(key: key);

  @override
  State<AzkarListScreen> createState() => _AzkarListScreenState();
}

class _AzkarListScreenState extends State<AzkarListScreen> {
  late List<Map<String, dynamic>> azkarWithCounters;
  bool allCompleted = false;

  @override
  void initState() {
    super.initState();
    azkarWithCounters = widget.azkarList.map((azkar) {
      return {
        'zekr': azkar['zekr']!,
        'repeat': azkar['repeat']!,
        'bless': azkar['bless']!,
        'currentCount': int.parse(azkar['repeat']!),
        'originalCount': int.parse(azkar['repeat']!),
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
      Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type),
        centerTitle: true,
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
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.orange,
                    ),
                    minHeight: 8,
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body: azkarWithCounters.where((azkar) => !azkar['isCompleted']).isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 80),
                  SizedBox(height: 16),
                  Text(
                    'تم إكمال جميع الأذكار',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'تقبل الله منك',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
                        : CustomAzkarWidgetWithCounter(
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

class CustomAzkarWidgetWithCounter extends StatefulWidget {
  final String details;
  final String? bless;
  final int currentCount;
  final int originalCount;
  final VoidCallback onTap;

  const CustomAzkarWidgetWithCounter({
    Key? key,
    required this.details,
    this.bless,
    required this.currentCount,
    required this.originalCount,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomAzkarWidgetWithCounter> createState() =>
      _CustomAzkarWidgetWithCounterState();
}

class _CustomAzkarWidgetWithCounterState
    extends State<CustomAzkarWidgetWithCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    HapticFeedback.vibrate();

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    if (widget.currentCount == 1) {
      HapticFeedback.heavyImpact();
    }

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (widget.originalCount - widget.currentCount) / widget.originalCount;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MyTheme.primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          HapticFeedback.vibrate();
                          Clipboard.setData(
                            ClipboardData(text: widget.details),
                          );
                          showToast(
                            text: 'تم النسخ',
                            textColor: MyTheme.primaryColor,
                            bgColoe: Colors.white,
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => ShareHelper.showShareOptions(
                          context,
                          text: widget.details,
                          extraText: widget.bless,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 20,
                              key: ValueKey('share'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.details,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  if (widget.bless != null && widget.bless!.isNotEmpty) ...[
                    ReadMoreText(
                      widget.bless!,
                      trimLines: 2,
                      textAlign: TextAlign.justify,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: 'قراءة المزيد',
                      trimExpandedText: ' قراءة اقل',
                      lessStyle: const TextStyle(color: Colors.orange),
                      moreStyle: const TextStyle(color: Colors.orange),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 234, 234, 234),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                  const SizedBox(height: 10),
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: widget.currentCount == 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'تم بحمد الله',
                                    key: ValueKey('completed_text'),
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: MyTheme.secondaryColor.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: MyTheme.secondaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                'التكرار : ${widget.currentCount}',
                                key: ValueKey('count_${widget.currentCount}'),
                                style: const TextStyle(
                                  color: MyTheme.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(begin: 0, end: progress),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.currentCount == 0
                                  ? MyTheme.primaryColor.withValues(alpha: 0.3)
                                  : MyTheme.secondaryColor.withValues(
                                      alpha: .8,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
