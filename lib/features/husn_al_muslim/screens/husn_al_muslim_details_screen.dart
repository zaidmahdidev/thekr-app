import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
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
  final ScreenshotController _screenshotController = ScreenshotController();

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

  Future<void> _shareAsImage() async {
    try {
      // Precache logo to ensure it's ready for capture
      await precacheImage(const AssetImage('assets/images/thekr.png'), context);

      final uint8list = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30),
                width: 400,
                decoration: BoxDecoration(
                  color: const Color(0xfffffbec), // Light Cream Background
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Image.asset(
                        'assets/images/thekr.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(
                      color: context.colors.primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '(احمدوا الله دومًا)',
                      style: TextStyle(
                        color: context.colors.secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'تطبيق ذكر - صدقة جارية',
                      style: TextStyle(
                        color: context.colors.primary.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        context: context,
        delay: const Duration(milliseconds: 500),
        pixelRatio: 2.0,
      );

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/husn_al_muslim_share.png',
      ).create();
      await imagePath.writeAsBytes(uint8list);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text:
            'رابط تحميل التطبيق \n https://play.google.com/store/apps/details?id=com.zaid.thekr_app',
      );
    } catch (e) {
      showToast(text: 'حدث خطأ أثناء المشاركة');
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                'خيارات المشاركة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _shareOptionItem(
                    icon: Icons.text_fields,
                    label: 'نص فقط',
                    onTap: () {
                      Navigator.pop(context);
                      _shareAsText();
                    },
                  ),
                  _shareOptionItem(
                    icon: Icons.image_outlined,
                    label: 'صورة مميزة',
                    onTap: () {
                      Navigator.pop(context);
                      _shareAsImage();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _shareAsText() async {
    try {
      String shareText = widget.text;
      if (widget.footnote.isNotEmpty) {
        shareText += '\n\n${widget.footnote}';
      }

      shareText += '\n\n﴿احمدوا الله دومًا﴾';
      shareText += '\n\nحمل تطبيق ذكر:';
      shareText +=
          '\nhttps://play.google.com/store/apps/details?id=com.zaid.thekr_app';

      await Share.share(shareText, subject: 'ذكر من تطبيق ذكر');
    } catch (e) {
      Clipboard.setData(ClipboardData(text: widget.text));
      showToast(
        text: 'تم نسخ الذكر',
        textColor: context.colors.primary,
        bgColoe: Colors.white,
      );
    }
  }

  Widget _shareOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.colors.primary, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
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
                color: context.colors.primary,
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
                            textColor: context.colors.primary,
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
                        onTap: _showShareOptions,
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
            ),
          ),
        );
      },
    );
  }
}
