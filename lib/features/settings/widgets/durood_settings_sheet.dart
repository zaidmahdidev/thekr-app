import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/services/notification_service.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

class DuroodSettingsSheet extends ConsumerStatefulWidget {
  const DuroodSettingsSheet({super.key});

  @override
  ConsumerState<DuroodSettingsSheet> createState() => _DuroodSettingsSheetState();
}

class _DuroodSettingsSheetState extends ConsumerState<DuroodSettingsSheet> {
  int _selectedInterval = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentInterval();
  }

  Future<void> _loadCurrentInterval() async {
    final interval = await SettingsService.getDuroodInterval();
    setState(() {
      _selectedInterval = interval;
    });
  }

  Future<void> _updateInterval(int minutes) async {
    await SettingsService.setDuroodInterval(minutes);
    ref.read(settingsProvider.notifier).updateDuroodInterval(minutes);
    setState(() {
      _selectedInterval = minutes;
    });
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.corners.xl),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -50,
            left: -50,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(AppAssets.bg, width: 250.w),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(context.insets.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: context.insets.lg),
                    decoration: BoxDecoration(
                      color: context.colors.textSecondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(context.corners.sm),
                    ),
                  ),

                  Text(
                    'التذكير بالصلاة على النبي',
                    style: context.textStyles.titleSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: context.insets.sm),

                  Text(
                    'اختر معدل تكرار التذكير الذي يناسبك، الإشعارات ستعمل في الخلفية لتذكيرك دائماً.',
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),

                  SizedBox(height: context.insets.lg),

                  _buildOption(
                    title: 'كل نصف ساعة',
                    minutes: 30,
                    icon: Icons.timer_outlined,
                  ),
                  _buildOption(
                    title: 'كل ساعة',
                    minutes: 60,
                    icon: Icons.hourglass_empty_rounded,
                  ),
                  _buildOption(
                    title: 'كل 3 ساعات',
                    minutes: 180,
                    icon: Icons.access_time_outlined,
                  ),
                  _buildOption(
                    title: 'كل 6 ساعات',
                    minutes: 360,
                    icon: Icons.av_timer_outlined,
                  ),
                  _buildOption(
                    title: 'مرة يومياً',
                    minutes: 1440,
                    icon: Icons.calendar_today_outlined,
                  ),
                  _buildOption(
                    title: 'يوم الجمعة فقط',
                    minutes: 10080,
                    icon: Icons.auto_awesome_outlined,
                  ),
                  _buildOption(
                    title: 'إيقاف التذكير',
                    minutes: 0,
                    icon: Icons.notifications_off_outlined,
                    isDestructive: true,
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required int minutes,
    required IconData icon,
    bool isDestructive = false,
  }) {
    final isSelected = _selectedInterval == minutes;
    
    return InkWell(
      onTap: () => _updateInterval(minutes),
      borderRadius: BorderRadius.circular(context.corners.md),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.insets.md,
          vertical: context.insets.sm,
        ),
        margin: EdgeInsets.only(bottom: context.insets.sm),
        decoration: BoxDecoration(
          color: isSelected 
              ? context.colors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(context.corners.md),
          border: Border.all(
            color: isSelected
                ? context.colors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive 
                  ? Colors.redAccent 
                  : (isSelected ? context.colors.primary : context.colors.textSecondary),
              size: 24.sp,
            ),
            SizedBox(width: context.insets.md),
            Expanded(
              child: Text(
                title,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: isDestructive 
                      ? Colors.redAccent 
                      : (isSelected ? context.colors.primary : context.colors.textPrimary),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: context.colors.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
