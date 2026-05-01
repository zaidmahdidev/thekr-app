import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readmore/readmore.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/widgets/my_card.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

class CustomAzkarWidget extends ConsumerStatefulWidget {
  const CustomAzkarWidget({Key? key, required this.details, this.bless})
    : super(key: key);

  final String details;
  final String? bless;

  @override
  ConsumerState<CustomAzkarWidget> createState() => _CustomAzkarWidgetState();
}

class _CustomAzkarWidgetState extends ConsumerState<CustomAzkarWidget> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final fontSize = settings.fontSize;

    return MyCard(
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
                  child: const Icon(Icons.share, size: 20),
                ),
              ),
            ],
          ),
          Text(
            widget.details,
            style: context.textStyles.bodyLarge?.copyWith(
              height: 1.8,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5.h),
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
          ],
        ],
      ),
    );
  }
}
