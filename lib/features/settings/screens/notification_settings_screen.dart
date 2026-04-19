import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thekr_app/core/services/notification_service.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/extensions/size_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import '../../../core/widgets/widgets.dart';

@RoutePage()
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _morningEnabled = true;
  bool _eveningEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 19, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final morningEnabled =
          await NotificationSettingsService.isMorningNotificationEnabled();
      final eveningEnabled =
          await NotificationSettingsService.isEveningNotificationEnabled();
      final morningTime = await NotificationSettingsService.getMorningTime();
      final eveningTime = await NotificationSettingsService.getEveningTime();

      setState(() {
        _morningEnabled = morningEnabled;
        _eveningEnabled = eveningEnabled;
        _morningTime = morningTime;
        _eveningTime = eveningTime;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMorningNotification(bool enabled) async {
    setState(() {
      _morningEnabled = enabled;
    });

    await NotificationSettingsService.setMorningNotificationEnabled(enabled);

    if (enabled) {
      await NotificationService.scheduleMorningAzkar(_morningTime);
      _showSnackBar('تم تفعيل تذكير أذكار الصباح');
    } else {
      await NotificationService.cancelMorningNotification();
      _showSnackBar('تم إلغاء تذكير أذكار الصباح');
    }
  }

  Future<void> _updateEveningNotification(bool enabled) async {
    setState(() {
      _eveningEnabled = enabled;
    });

    await NotificationSettingsService.setEveningNotificationEnabled(enabled);

    if (enabled) {
      await NotificationService.scheduleEveningAzkar(_eveningTime);
      _showSnackBar('تم تفعيل تذكير أذكار المساء');
    } else {
      await NotificationService.cancelEveningNotification();
      _showSnackBar('تم إلغاء تذكير أذكار المساء');
    }
  }

  Future<void> _selectMorningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _morningTime,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != _morningTime) {
      setState(() {
        _morningTime = picked;
      });

      await NotificationSettingsService.setMorningTime(picked);

      if (_morningEnabled) {
        await NotificationService.scheduleMorningAzkar(picked);
        _showSnackBar('تم تحديث وقت أذكار الصباح');
      }
    }
  }

  Future<void> _selectEveningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _eveningTime,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != _eveningTime) {
      setState(() {
        _eveningTime = picked;
      });

      await NotificationSettingsService.setEveningTime(picked);

      if (_eveningEnabled) {
        await NotificationService.scheduleEveningAzkar(picked);
        _showSnackBar('تم تحديث وقت أذكار المساء');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: context.colors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'إعدادات الإشعارات',
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  // Morning Azkar Section
                  _buildSettingCard(
                    title: 'أذكار الصباح',
                    icon: Icons.wb_sunny_rounded,
                    iconColor: context.colors.secondary,
                    isEnabled: _morningEnabled,
                    onToggle: _updateMorningNotification,
                    time: _morningTime,
                    onTimeTap: _selectMorningTime,
                  ),

                  const SizedBox(height: 20),

                  // Evening Azkar Section
                  _buildSettingCard(
                    title: 'أذكار المساء',
                    icon: Icons.nightlight_round_rounded,
                    iconColor: context.colors.primary,
                    isEnabled: _eveningEnabled,
                    onToggle: _updateEveningNotification,
                    time: _eveningTime,
                    onTimeTap: _selectEveningTime,
                  ),

                  const SizedBox(height: 30),

                  // Info Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: context.colors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: context.colors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'سيتم تذكيرك يومياً بذكر الله في الأوقات التي تختارها.',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Share App Section (Themed like Home)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            AppAssets.logo,
                            width: context.getWidth(12),
                            height: context.getWidth(12),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'شارك التطبيق',
                                style: AppTypography.h3.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'ساهم في نشر الخير بين أحبائك',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Share.share(
                              'حمل تطبيق "ذكر" - صدقة جارية\nتطبيق شامل للمصحف الشريف والأذكار والتسبيح\nhttps://play.google.com/store/apps/details?id=com.zaid.thekr_app',
                            );
                          },
                          icon: const Icon(
                            Icons.share_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isEnabled,
    required Function(bool) onToggle,
    required TimeOfDay time,
    required VoidCallback onTimeTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEnabled
              ? context.colors.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            title: Text(
              title,
              style: AppTypography.h3.copyWith(color: context.colors.primary),
            ),
            trailing: Switch.adaptive(
              value: isEnabled,
              onChanged: onToggle,
              activeThumbColor: context.colors.primary,
              activeTrackColor: context.colors.primary.withValues(alpha: 0.3),
            ),
          ),
          if (isEnabled) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: InkWell(
                onTap: onTimeTap,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xfff8f9fa),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        color: context.colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ضبط الوقت: ',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        _formatTime(time),
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.primary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
