import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/extensions/ui_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/toast_utils.dart';
import 'package:thekr_app/features/sync/providers/sync_controller.dart';
import '../providers/account_provider.dart';
import '../services/account_service.dart';
import 'account_badge.dart';
import 'account_sheet.dart';
import 'account_sync_text.dart';
import 'google_sign_in_button.dart';

/// Top of the settings screen. Signed out it invites the user to sign in; signed
/// in it is one row (who, and how the backup is doing) that opens the rest.
/// Always optional, never asked for anywhere else.
class AccountCard extends ConsumerStatefulWidget {
  const AccountCard({super.key});

  @override
  ConsumerState<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends ConsumerState<AccountCard> {
  bool _busy = false;

  Future<void> _signIn() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await AccountService.instance.signInWithGoogle();
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case SignInResult.success:
      case SignInResult.cancelled:
        break;
      case SignInResult.notAvailable:
        showToast(
          text: 'الخدمة غير متاحة الآن، حاول لاحقاً',
          state: ToastStates.WARNING,
        );
      case SignInResult.failed:
        showToast(
          text: 'تعذّر تسجيل الدخول، تأكد من الإنترنت وحاول مجدداً',
          state: ToastStates.ERROR,
        );
    }
  }

  void _openSheet() {
    context.showSheet<void>(title: 'حسابي', child: const AccountSheet());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(accountUserProvider).value;
    final colors = context.colors;
    final radius = BorderRadius.circular(context.corners.lg);

    return Container(
      margin: EdgeInsets.only(bottom: context.insets.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius,
        boxShadow: context.shadows.low,
      ),
      child: user == null
          ? Padding(
              padding: EdgeInsets.all(context.insets.md),
              child: _signedOut(context),
            )
          : InkWell(
              onTap: _openSheet,
              borderRadius: radius,
              child: Padding(
                padding: EdgeInsets.all(context.insets.md),
                child: _signedIn(context, user),
              ),
            ),
    );
  }

  Widget _signedOut(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const AccountBadge(icon: HugeIcons.strokeRoundedCloudSavingDone01),
            SizedBox(width: context.insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'احفظ بياناتك',
                    style: (styles.bodyLarge ?? const TextStyle()).copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'اختياري. تبقى أذكارك وتقدّمك معك على أي جهاز',
                    style: (styles.bodySmall ?? const TextStyle()).copyWith(
                      color: colors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: context.insets.md),
        GoogleSignInButton(onTap: _signIn, isLoading: _busy),
      ],
    );
  }

  Widget _signedIn(BuildContext context, User user) {
    final colors = context.colors;
    final styles = context.textStyles;
    final sync = ref.watch(syncControllerProvider);
    final name = (user.displayName ?? '').trim();
    final photo = user.photoURL;

    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: colors.primary.withValues(alpha: 0.1),
          backgroundImage: photo != null ? NetworkImage(photo) : null,
          child: photo == null
              ? AppIcon(
                  HugeIcons.strokeRoundedUserCircle,
                  color: colors.primary,
                  size: 24.sp,
                )
              : null,
        ),
        SizedBox(width: context.insets.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? (user.email ?? 'مرحباً بك') : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (styles.bodyLarge ?? const TextStyle()).copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                accountSyncText(sync),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (styles.bodySmall ?? const TextStyle()).copyWith(
                  color: sync.phase == SyncPhase.failed
                      ? colors.error
                      : colors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        AppIcon(
          HugeIcons.strokeRoundedArrowRight01,
          size: 18.sp,
          color: colors.textSecondary.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}
