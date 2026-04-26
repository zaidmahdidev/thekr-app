import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thekr_app/core/theme/tokens/typography.dart';
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
      child: CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message, style: AppTypography.bodyMedium),
        actions: [
          CupertinoDialogAction(
            onPressed: onYes,
            isDestructiveAction: true,
            child: const Text('نعم'),
          ),
          CupertinoDialogAction(
            onPressed: onCancel,
            isDefaultAction: true,
            child: const Text('لا'),
          ),
        ],
        insetAnimationCurve: Curves.easeInOut,
        insetAnimationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
