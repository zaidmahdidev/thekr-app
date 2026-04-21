import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readmore/readmore.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/widgets/my_card.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';

class CustomAzkarWidget extends StatefulWidget {
  const CustomAzkarWidget({Key? key, required this.details, this.bless})
    : super(key: key);

  final String details;
  final String? bless;

  @override
  State<CustomAzkarWidget> createState() => _CustomAzkarWidgetState();
}

class _CustomAzkarWidgetState extends State<CustomAzkarWidget> {
  @override
  Widget build(BuildContext context) {
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
            style: AppTypography.bodyLarge.copyWith(
              height: 1.8,
              fontWeight: FontWeight.bold,
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
              lessStyle: AppTypography.bodyMedium.copyWith(
                color: context.colors.secondary,
              ),
              moreStyle: AppTypography.bodyMedium.copyWith(
                color: context.colors.secondary,
              ),
              style: AppTypography.bodyMedium.copyWith(),
            ),
          ],
        ],
      ),
    );
  }
}
