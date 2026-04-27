import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readmore/readmore.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/widgets/my_card.dart';
import 'package:thekr_app/core/widgets/widgets.dart';

class HusnAlMuslimItemWidget extends StatefulWidget {
  final String text;
  final String footnote;
  final int currentCount;
  final int originalCount;
  final VoidCallback onTap;

  const HusnAlMuslimItemWidget({
    Key? key,
    required this.text,
    required this.footnote,
    required this.currentCount,
    required this.originalCount,
    required this.onTap,
  }) : super(key: key);

  @override
  State<HusnAlMuslimItemWidget> createState() => _HusnAlMuslimItemWidgetState();
}

class _HusnAlMuslimItemWidgetState extends State<HusnAlMuslimItemWidget>
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
                    backgroundColor: context.colors.background,
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
            style: AppTypography.bodyLarge.copyWith(
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
              lessStyle: AppTypography.bodyMedium.copyWith(
                color: context.colors.secondary,
              ),
              moreStyle: AppTypography.bodyMedium.copyWith(
                color: context.colors.secondary,
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.grey,
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
