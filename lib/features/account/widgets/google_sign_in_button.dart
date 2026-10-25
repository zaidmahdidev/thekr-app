import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/utils/constants/app_assets.dart';

/// The standard "Sign in with Google" button: the four-colour "G" and the
/// label on a plain surface with a thin border, as people know it from other
/// apps.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(context.corners.xl);
    final enabled = onTap != null && !isLoading;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: colors.textSecondary.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: radius,
        child: SizedBox(
          height: 40.h,
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.insets.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: isLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          )
                        : SvgPicture.asset(AppAssets.googleG),
                  ),
                  SizedBox(width: context.insets.md),
                  Text(
                    'تسجيل الدخول باستخدام Google',
                    style: (context.textStyles.bodyMedium ?? const TextStyle())
                        .copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
