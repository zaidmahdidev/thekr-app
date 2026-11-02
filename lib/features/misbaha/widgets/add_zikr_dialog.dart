import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import '../models/misbaha_models.dart';

/// Asks for the user's own dhikr. Returns the text, or null if cancelled.
/// The field is one short line: the limit is enforced while typing.
Future<String?> showAddZikrDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _AddZikrDialog(),
  );
}

class _AddZikrDialog extends StatefulWidget {
  const _AddZikrDialog();

  @override
  State<_AddZikrDialog> createState() => _AddZikrDialogState();
}

class _AddZikrDialogState extends State<_AddZikrDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.corners.xl),
      ),
      title: Text(
        'إضافة ذكر',
        style: context.textStyles.titleMedium?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: maxCustomZikrLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[\r\n]'))],
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        style: context.textStyles.bodyLarge?.copyWith(
          color: colors.textPrimary,
        ),
        decoration: const InputDecoration(hintText: 'مثال: اللهم صلِّ على محمد'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: TextStyle(color: colors.textSecondary)),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            'إضافة',
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
