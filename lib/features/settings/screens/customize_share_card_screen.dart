import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

@RoutePage()
class CustomizeShareCardScreen extends ConsumerWidget {
  const CustomizeShareCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return AppScaffold(
      title: 'بطاقة المشاركة',
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(context.insets.md),
        child: Column(
          children: [
            SizedBox(height: context.insets.md),

            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: FittedBox(
                fit: BoxFit.cover,
                child: ShareService.buildShareCard(
                  context,
                  settings.shareTemplate,
                  '﴿فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ﴾',
                  null,
                ),
              ),
            ),
            SizedBox(height: context.insets.xl),

            // Template Selector Section
            Text(
              'اختر شكل البطاقة المفضل',
              style: context.textStyles.titleSmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.insets.md),

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
                      // width: 200.w,
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
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
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
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: context.colors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: context.insets.md),

            // Image Share Info
            Container(
              padding: EdgeInsets.all(context.insets.md),
              decoration: BoxDecoration(
                color: context.colors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(context.corners.md),
                border: Border.all(
                  color: context.colors.secondary.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: context.colors.secondary,
                    size: 20,
                  ),
                  SizedBox(width: context.insets.sm),
                  Expanded(
                    child: Text(
                      'يتم مشاركة البطاقة المختارة تلقائياً عند مشاركة أي ذكر من داخل التطبيق.',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: context.insets.xl),
          ],
        ),
      ),
    );
  }
}
