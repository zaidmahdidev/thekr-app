import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readmore/readmore.dart';
import '../../shard/components/tools.dart';
import '../../shard/constant/theme.dart';
import '../../shard/utils/share_helper.dart';

class HusinAlMuslimDetailsScreen extends StatefulWidget {
  final String title;
  final Map<String, dynamic> dhikrData;

  const HusinAlMuslimDetailsScreen({
    Key? key,
    required this.title,
    required this.dhikrData,
  }) : super(key: key);

  @override
  State<HusinAlMuslimDetailsScreen> createState() =>
      _HusinAlMuslimDetailsScreenState();
}

class _HusinAlMuslimDetailsScreenState
    extends State<HusinAlMuslimDetailsScreen> {
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
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: dhikrWithCounters.where((dhikr) => !dhikr['isCompleted']).isEmpty
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
                        : CustomHusinAlMuslimWidget(
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

class CustomHusinAlMuslimWidget extends StatefulWidget {
  final String text;
  final String footnote;
  final int currentCount;
  final int originalCount;
  final VoidCallback onTap;

  const CustomHusinAlMuslimWidget({
    Key? key,
    required this.text,
    required this.footnote,
    required this.currentCount,
    required this.originalCount,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomHusinAlMuslimWidget> createState() =>
      _CustomHusinAlMuslimWidgetState();
}

class _CustomHusinAlMuslimWidgetState extends State<CustomHusinAlMuslimWidget>
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
                          Clipboard.setData(ClipboardData(text: widget.text));
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
                          text: widget.text,
                          extraText: widget.footnote.isNotEmpty
                              ? widget.footnote
                              : null,
                          fileName: 'husn_al_muslim_share',
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  if (widget.footnote.isNotEmpty) ...[
                    ReadMoreText(
                      widget.footnote,
                      trimLines: 2,
                      textAlign: TextAlign.justify,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: 'قراءة المزيد',
                      trimExpandedText: ' قراءة اقل',
                      lessStyle: const TextStyle(color: Colors.orange),
                      moreStyle: const TextStyle(color: Colors.orange),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
