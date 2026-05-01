import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
import 'package:thekr_app/main.dart';

enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastColor(BuildContext context, ToastStates state) {
  switch (state) {
    case ToastStates.SUCCESS:
      return context.colors.success;
    case ToastStates.ERROR:
      return context.colors.error;
    case ToastStates.WARNING:
      return context.colors.secondary;
  }
}

void showToast({
  required String text,
  ToastStates state = ToastStates.SUCCESS,
  Color? textColor,
  Color? backgroundColor,
}) {
  final context = scaffoldMessengerKey.currentContext;
  if (context == null) return;

  scaffoldMessengerKey.currentState?.removeCurrentSnackBar();

  final color = backgroundColor ?? chooseToastColor(context, state);

  IconData icon;
  switch (state) {
    case ToastStates.SUCCESS:
      icon = Icons.check_circle_rounded;
      break;
    case ToastStates.ERROR:
      icon = Icons.error_rounded;
      break;
    case ToastStates.WARNING:
      icon = Icons.warning_rounded;
      break;
  }

  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, size: 22.w, color: Colors.white),
          SizedBox(width: context.insets.sm),
          Expanded(
            child: Text(
              text,
              style: context.textStyles.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(
        horizontal: context.insets.lg,
        vertical: context.insets.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.corners.lg),
      ),
      elevation: 6,
    ),
  );
}
