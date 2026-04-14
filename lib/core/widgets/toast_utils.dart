import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/main.dart';

enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastColor(BuildContext context, ToastStates state) {
  Color color;

  switch (state) {
    case ToastStates.SUCCESS:
      color = context.colors.success;
      break;
    case ToastStates.ERROR:
      color = context.colors.error;
      break;
    case ToastStates.WARNING:
      color = context.colors.secondary;
      break;
  }

  return color;
}

void showToast({
  required String text,
  Color? textColor = Colors.white,
  Color? bgColoe,
}) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor, fontSize: 16.0),
      ),
      backgroundColor:
          bgColoe ?? const Color(0xFF008080), // Teal fallback if null
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
