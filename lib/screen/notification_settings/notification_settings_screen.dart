import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../shard/constant/theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _morningEnabled = false;
  bool _eveningEnabled = false;
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
        backgroundColor: MyTheme.primaryColor,
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'إعدادات الإشعارات',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: MyTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Morning Azkar Section
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.wb_sunny,
                                color: Colors.orange,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'أذكار الصباح',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _morningEnabled,
                                onChanged: _updateMorningNotification,
                                activeThumbColor: MyTheme.primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _selectMorningTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'الوقت: ${_formatTime(_morningTime)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.edit, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Evening Azkar Section
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.nightlight_round,
                                color: Colors.indigo,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'أذكار المساء',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _eveningEnabled,
                                onChanged: _updateEveningNotification,
                                activeThumbColor: MyTheme.primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _selectEveningTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'الوقت: ${_formatTime(_eveningTime)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.edit, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Card
                  Card(
                    elevation: 2,
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'سيتم تذكيرك يومياً في الأوقات المحددة',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
