import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/widgets/my_card.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

class HusnAlMuslimItemWidget extends ConsumerStatefulWidget {
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
  ConsumerState<HusnAlMuslimItemWidget> createState() => _HusnAlMuslimItemWidgetState();
}

class _HusnAlMuslimItemWidgetState extends ConsumerState<HusnAlMuslimItemWidget>
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
    final settings = ref.watch(settingsProvider);
    final fontSize = settings.fontSize;

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
                  ref,
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
            style: context.textStyles.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.8,
              fontSize: fontSize,
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
              lessStyle: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.secondary,
                fontSize: fontSize * 0.8,
              ),
              moreStyle: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.secondary,
                fontSize: fontSize * 0.8,
              ),
              style: context.textStyles.bodyMedium?.copyWith(
                color: Colors.grey,
                height: 1.6,
                fontSize: fontSize * 0.8,
              ),
            ),
            const SizedBox(height: 15),
          ],
        ],
      ),
    );
  }
}
