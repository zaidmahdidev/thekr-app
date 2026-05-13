import 'package:flutter/material.dart';
import 'package:thekr_app/core/widgets/app_bottom_sheet.dart';
import 'package:thekr_app/core/widgets/custom_dialog.dart';

extension UIExtension on BuildContext {
  /// Shows a custom confirmation dialog using the project's [CustomDialog] widget.
  Future<T?> showConfirmDialog<T>({
    required String title,
    required String message,
    required VoidCallback onYes,
    VoidCallback? onCancel,
  }) {
    return showDialog<T>(
      context: this,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        onYes: onYes,
        onCancel: onCancel ?? () => Navigator.pop(context),
      ),
    );
  }

  Future<T?> showSheet<T>({
    required Widget child,
    String? title,
    bool showHandle = true,
    bool showBackgroundOrnament = true,
  }) {
    return AppBottomSheet.show<T>(
      context: this,
      title: title,
      showHandle: showHandle,
      showBackgroundOrnament: showBackgroundOrnament,
      child: child,
    );
  }

  void pop<T>([T? result]) => Navigator.pop(this, result);
}
