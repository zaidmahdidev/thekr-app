import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../shard/components/tools.dart';
import '../../shard/constant/theme.dart';

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
    int totalRepeat = 0;
    int currentCompleted = 0;

    for (var azkar in azkarWithCounters) {
      totalRepeat += azkar['originalCount'] as int;
      currentCompleted +=
          (azkar['originalCount'] as int) - (azkar['currentCount'] as int);
    }

    return totalRepeat > 0 ? currentCompleted / totalRepeat : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: _calculateTotalProgress()),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 6,
              );
            },
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
      final uint8list = await _screenshotController.captureFromWidget(
        Container(
          padding: const EdgeInsets.all(30),
          width: 400,
          decoration: BoxDecoration(
            color: MyTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                MyTheme.primaryColor,
                MyTheme.primaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/thekr.png', width: 90, height: 90),
              const SizedBox(height: 20),
              Text(
                widget.details,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.8,
                ),
              ),
              if (widget.bless != null && widget.bless!.isNotEmpty) ...[
                const SizedBox(height: 15),
                Text(
                  widget.bless!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
              const SizedBox(height: 30),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              Text(
                '(احمدوا الله دومًا)',
                style: GoogleFonts.tajawal(color: Colors.orange, fontSize: 18),
              ),
              Text(
                'تطبيق ذكر - صدقة جارية',
                style: GoogleFonts.tajawal(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/zikr_share.png').create();
      await imagePath.writeAsBytes(uint8list);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text:
            'رابط تحميل التطبيق \n https://play.google.com/store/apps/details?id=com.zaid.thekr_app&pcampaignid=web_share',
      );
      // ], text: 'ذكر من تطبيق ذكر');
    } catch (e) {
      showToast(text: 'حدث خطأ أثناء المشاركة');
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'اختر طريقة المشاركة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.text_fields,
                    color: MyTheme.primaryColor,
                  ),
                  title: const Text('مشاركة كنص'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareAsText();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image, color: MyTheme.primaryColor),
                  title: const Text('مشاركة كبطاقة'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareAsImage();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _shareAsText() {
    String shareText = widget.details;
    if (widget.bless != null && widget.bless!.isNotEmpty) {
      shareText += '\n\n${widget.bless}';
    }
    shareText += '\n\n﴿احمدوا الله دومًا﴾';
    shareText += '\n\nحمل تطبيق ذكر:';
    shareText +=
        '\nhttps://play.google.com/store/apps/details?id=com.zaid.thekr_app';

    Share.share(shareText, subject: 'ذكر من تطبيق ذكر');
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
                        onTap: _showShareOptions,
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
                      fontWeight: FontWeight.w900,
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
