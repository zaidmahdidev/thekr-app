import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/extensions/ui_extension.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/azkar/providers/user_azkar_provider.dart';
import 'package:thekr_app/features/azkar/widgets/user_thikr_card.dart';
import 'package:thekr_app/features/azkar/widgets/add_thikr_sheet.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

@RoutePage()
class UserAzkarScreen extends ConsumerWidget {
  const UserAzkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAthkar = ref.watch(userAzkarProvider);

    return AppScaffold(
      appBar: BaseAppBar(
        title: 'أذكاري المخصصة',
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase_rounded),
            onPressed: () {
              final currentSize = ref.read(settingsProvider).fontSize;
              if (currentSize < 24) {
                ref.read(settingsProvider.notifier).updateFontSize(currentSize + 2);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease_rounded),
            onPressed: () {
              final currentSize = ref.read(settingsProvider).fontSize;
              if (currentSize > 14) {
                ref.read(settingsProvider.notifier).updateFontSize(currentSize - 2);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        backgroundColor: context.colors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: userAthkar.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(context.insets.md),
              itemCount: userAthkar.length,
              itemBuilder: (context, index) {
                final thikr = userAthkar[index];
                return UserThikrCard(key: ValueKey(thikr.id), thikr: thikr);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 80.sp,
            color: context.colors.primary.withValues(alpha: 0.2),
          ),
          SizedBox(height: 16.h),
          Text('لا توجد أذكار مضافة بعد', style: context.textStyles.bodyLarge),
          SizedBox(height: 8.h),
          Text(
            'أضف أذكارك الخاصة وشاركها مع من تحب',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: AppButton(
              text: 'إضافة ذكر جديد',
              onTap: () => _showAddSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    context.showSheet(title: 'إضافة ذكر جديد', child: const AddThikrSheet());
  }
}
