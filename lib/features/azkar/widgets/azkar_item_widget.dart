import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/widgets/my_card.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

class AzkarItemWidget extends ConsumerStatefulWidget {
  final String details;
  final String? bless;
  final int currentCount;
  final int originalCount;
  final VoidCallback onTap;

  const AzkarItemWidget({
    Key? key,
    required this.details,
    this.bless,
    required this.currentCount,
    required this.originalCount,
    required this.onTap,
  }) : super(key: key);

  @override
  ConsumerState<AzkarItemWidget> createState() => _AzkarItemWidgetState();
}

class _AzkarItemWidgetState extends ConsumerState<AzkarItemWidget>
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
    
    final progress =
        (widget.originalCount - widget.currentCount) / widget.originalCount;

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
                  Clipboard.setData(ClipboardData(text: widget.details));
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
                  content: widget.details,
                  subtitle: widget.bless,
                ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.share,
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
            style: context.textStyles.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.8,
              fontSize: fontSize,
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
              lessStyle: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.secondary,
                fontSize: fontSize * 0.8,
              ),
              moreStyle: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.secondary,
                fontSize: fontSize * 0.8,
              ),
              style: context.textStyles.bodyMedium?.copyWith(
                fontSize: fontSize * 0.8,
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'تم بحمد الله',
                            key: const ValueKey('completed_text'),
                            style: context.textStyles.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
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
                        color: context.colors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.colors.secondary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Text(
                        'التكرار : ${widget.currentCount}',
                        key: ValueKey('count_${widget.currentCount}'),
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.secondary,
                          fontWeight: FontWeight.bold,
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
              color: Colors.grey.withValues(alpha: 0.2),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
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
                          ? context.colors.primary.withValues(alpha: 0.3)
                          : context.colors.secondary.withValues(alpha: .8),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
