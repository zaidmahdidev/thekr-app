import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/azkar/models/user_thikr.dart';
import 'package:thekr_app/features/azkar/providers/user_azkar_provider.dart';

class AddThikrSheet extends ConsumerStatefulWidget {
  final UserThikr? existingThikr;

  const AddThikrSheet({super.key, this.existingThikr});

  @override
  ConsumerState<AddThikrSheet> createState() => _AddThikrSheetState();
}

class _AddThikrSheetState extends ConsumerState<AddThikrSheet> {
  final _textController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.existingThikr != null) {
      _textController.text = widget.existingThikr!.text;
      _descriptionController.text = widget.existingThikr!.description ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              TextFormField(
                controller: _textController,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'اكتب نص الذكر هنا...',
                  filled: true,
                  fillColor: context.colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.corners.md),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => (val == null || val.isEmpty)
                    ? 'يرجى إدخال نص الذكر'
                    : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'فضل الذكر (اختياري)',
                  filled: true,
                  fillColor: context.colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.corners.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              AppButton(
                text: widget.existingThikr == null ? 'إضافة' : 'حفظ التعديلات',
                onTap: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (widget.existingThikr == null) {
        ref
            .read(userAzkarProvider.notifier)
            .addThikr(
              _textController.text,
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
            );
      } else {
        ref
            .read(userAzkarProvider.notifier)
            .updateThikr(
              widget.existingThikr!.copyWith(
                text: _textController.text,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
              ),
            );
      }
      Navigator.pop(context);
    }
  }
}
