import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/extensions/ui_extension.dart';
import 'package:thekr_app/core/widgets/app_button.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:thekr_app/features/settings/widgets/settings_section.dart';
import 'package:thekr_app/features/settings/widgets/settings_tile.dart';
import 'package:thekr_app/features/sync/providers/sync_controller.dart';
import '../services/account_service.dart';
import 'account_sync_text.dart';

/// What the account card hides because it is rarely needed: saving by hand,
/// the automatic backup switch, signing out and deleting the account.
class AccountSheet extends ConsumerStatefulWidget {
  const AccountSheet({super.key});

  @override
  ConsumerState<AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends ConsumerState<AccountSheet> {
  bool _busy = false;

  void _confirmSignOut() {
    context.showConfirmDialog(
      title: 'تسجيل الخروج',
      message:
          'ستبقى بياناتك محفوظة على هذا الجهاز، ويمكنك الدخول مجدداً في أي وقت.',
      onYes: () async {
        context.pop();
        await AccountService.instance.signOut();
        if (mounted) context.pop();
      },
    );
  }

  void _confirmDelete() {
    context.showConfirmDialog(
      title: 'حذف حسابي وبياناتي',
      message:
          'سيُحذف حسابك والنسخة المحفوظة في السحابة نهائياً، وتبقى بياناتك '
          'على هذا الجهاز. لا يمكن التراجع عن هذا.',
      onYes: () {
        context.pop();
        _deleteAccount();
      },
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _busy = true);
    final ok = await ref.read(syncControllerProvider.notifier).deleteAccount();
    if (!mounted) return;
    setState(() => _busy = false);
    showToast(
      text: ok
          ? 'تم حذف حسابك وبياناتك السحابية'
          : 'تعذّر حذف الحساب، حاول مجدداً',
      state: ok ? ToastStates.SUCCESS : ToastStates.ERROR,
    );
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sync = ref.watch(syncControllerProvider);
    final controller = ref.read(syncControllerProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(bottom: context.insets.md),
      child: SettingsSection(
        children: [
          SettingsTile(
            title: 'النسخ الاحتياطي',
            subtitle: accountSyncText(sync),
            icon: HugeIcons.strokeRoundedCloudSavingDone01,
            iconColor: colors.success,
            trailing: AppButton(
              text: 'احفظ الآن',
              size: AppButtonSize.small,
              variant: AppButtonVariant.secondary,
              isFullWidth: false,
              isLoading: sync.isSyncing,
              onTap: _busy ? null : controller.syncNow,
            ),
          ),
          SettingsTile(
            title: 'النسخ التلقائي',
            subtitle: sync.autoSync
                ? 'عند فتح التطبيق وتركه'
                : 'متوقف، احفظ يدوياً عند الحاجة',
            icon: HugeIcons.strokeRoundedRefresh,
            iconColor: colors.secondary,
            switchValue: sync.autoSync,
            onSwitchChanged: controller.setAutoSync,
          ),
          SettingsTile(
            title: 'تسجيل الخروج',
            subtitle: 'تبقى بياناتك على هذا الجهاز',
            icon: HugeIcons.strokeRoundedLogout01,
            iconColor: colors.primary,
            onTap: _busy ? null : _confirmSignOut,
          ),
          SettingsTile(
            title: 'حذف حسابي وبياناتي',
            subtitle: 'يحذف الحساب والنسخة السحابية نهائياً',
            icon: HugeIcons.strokeRoundedDelete02,
            iconColor: colors.error,
            onTap: _busy ? null : _confirmDelete,
          ),
        ],
      ),
    );
  }
}
