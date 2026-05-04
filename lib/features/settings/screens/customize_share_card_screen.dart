import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:thekr_app/core/widgets/widgets.dart';

@RoutePage()
class CustomizeShareCardScreen extends ConsumerStatefulWidget {
  const CustomizeShareCardScreen({super.key});

  @override
  ConsumerState<CustomizeShareCardScreen> createState() =>
      _CustomizeShareCardScreenState();
}

class _CustomizeShareCardScreenState
    extends ConsumerState<CustomizeShareCardScreen> {
  final TextEditingController _textController = TextEditingController(
    text: '﴿فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ﴾',
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _shareCustomCard(ShareTemplate template) {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      showToast(text: 'يرجى كتابة نص أولاً');
      return;
    }

    ShareService.shareAsImage(
      context,
      template,
      text,
      null,
      isCustomText: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return AppScaffold(
      title: 'بطاقة المشاركة',
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(context.insets.md),
        child: Column(
          children: [
            SizedBox(height: context.insets.md),

            // Card Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: FittedBox(
                fit: BoxFit.cover,
                child: ValueListenableBuilder(
                  valueListenable: _textController,
                  builder: (context, value, child) {
                    return ShareService.buildShareCard(
                      context,
                      settings.shareTemplate,
                      _textController.text.isEmpty
                          ? 'اكتب نصك هنا...'
                          : _textController.text,
                      null,
                      isCustomText: true,
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: context.insets.xl),

            // Template Selector Header
            Text(
              'اختر شكل البطاقة المفضل',
              style: context.textStyles.titleSmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.insets.md),

            // Horizontal Template List
            SizedBox(
              height: 120.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: ShareTemplate.values.length,
                itemBuilder: (context, index) {
                  final template = ShareTemplate.values[index];
                  final isSelected = settings.shareTemplate == template;

                  return GestureDetector(
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .updateShareTemplate(template),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(
                        left: 12.w,
                        bottom: 8.h,
                        top: 4.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.primary.withValues(alpha: 0.1),
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected ? context.shadows.low : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22.r),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: ShareService.buildShareCard(
                            context,
                            template,
                            '﴿فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ﴾',
                            null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: context.insets.xl),

            // Custom Text Section
            Text(
              'اكتب نصك الخاص',
              style: context.textStyles.titleSmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.insets.md),
            TextField(
              controller: _textController,
              maxLines: 3,
              maxLength: 500,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'اكتب آية، حديث، أو خاطرة إيمانية...',
                filled: true,
                fillColor: context.colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: context.colors.primary.withValues(alpha: 0.2),
                  ),
                ),
              ),
              style: context.textStyles.bodyMedium?.copyWith(height: 1.5),
            ),

            SizedBox(height: context.insets.lg),

            AppButton(
              text: 'مشاركة كبطاقة صورة',
              onTap: () => _shareCustomCard(settings.shareTemplate),
            ),

            SizedBox(height: context.insets.xl),
          ],
        ),
      ),
    );
  }
}
