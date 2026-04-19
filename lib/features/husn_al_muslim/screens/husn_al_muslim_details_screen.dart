import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readmore/readmore.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/widgets/my_card.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
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
      context.router.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
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
    return MyCard(
      onTap: _handleTap,
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
                    textColor: context.colors.primary,
                    backgroundColor: Colors.white,
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.copy, size: 18),
                ),
              ),
              InkWell(
                onTap: () => ShareService.showShareSheet(
                  context,
                  content: widget.text,
                  subtitle: widget.footnote,
                ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.share, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.text,
            style: const TextStyle(
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
              lessStyle: TextStyle(color: context.colors.secondary),
              moreStyle: TextStyle(color: context.colors.secondary),
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
    );
  }
}
