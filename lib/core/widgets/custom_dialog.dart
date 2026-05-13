import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/base_animation_list_view.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onYes;
  final VoidCallback onCancel;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onYes,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BaseAnimationListView(
      index: 0,
      verticalOffset: 200,
      horizontalOffset: 0,
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Theme.of(context).brightness,
        ),
        child: CupertinoAlertDialog(
          title: Text(
            title,
            style: context.textStyles.bodyLarge?.copyWith(
              color: context.colors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: context.textStyles.bodyMedium,
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: onCancel,
              isDefaultAction: true,
              child: Text(
                'لا',
                style: TextStyle(color: context.colors.primary),
              ),
            ),
            CupertinoDialogAction(
              onPressed: onYes,
              isDestructiveAction: true,
              child: const Text('نعم'),
            ),
          ],
          insetAnimationCurve: Curves.easeInOut,
          insetAnimationDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}
