import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import '../providers/radio_providers.dart';

/// Search box for stations; matches names without regard to diacritics.
class RadioSearchField extends ConsumerStatefulWidget {
  const RadioSearchField({super.key});

  @override
  ConsumerState<RadioSearchField> createState() => _RadioSearchFieldState();
}

class _RadioSearchFieldState extends ConsumerState<RadioSearchField> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.corners.xl),
      borderSide: BorderSide(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = ref.watch(radioSearchProvider).isNotEmpty;
    final outline = context.colors.textSecondary.withValues(alpha: 0.15);

    return TextField(
      controller: _search,
      textInputAction: TextInputAction.search,
      onChanged: (value) =>
          ref.read(radioSearchProvider.notifier).state = value,
      style: context.textStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: 'ابحث عن قارئ أو إذاعة',
        hintStyle: context.textStyles.bodyMedium?.copyWith(
          color: context.colors.textSecondary,
        ),
        filled: true,
        fillColor: context.colors.surface,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.insets.md,
          vertical: context.insets.sm + 4.w,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.insets.sm + 2.w),
          child: AppIcon(
            HugeIcons.strokeRoundedSearch01,
            size: 20.w,
            color: context.colors.textSecondary,
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 40.w),
        suffixIcon: hasQuery
            ? IconButton(
                onPressed: () {
                  _search.clear();
                  ref.read(radioSearchProvider.notifier).state = '';
                },
                icon: AppIcon(
                  HugeIcons.strokeRoundedCancel01,
                  size: 18.w,
                  color: context.colors.textSecondary,
                ),
              )
            : null,
        border: _border(outline),
        enabledBorder: _border(outline),
        focusedBorder: _border(context.colors.primary),
      ),
    );
  }
}

/// Horizontally scrolling category chips.
class RadioFilterChips extends ConsumerWidget {
  const RadioFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(radioFilterProvider);

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: context.insets.md),
      itemCount: RadioFilter.values.length,
      separatorBuilder: (_, _) => SizedBox(width: context.insets.sm),
      itemBuilder: (context, index) {
        final filter = RadioFilter.values[index];
        final isSelected = filter == selected;
        return ChoiceChip(
          label: Text(filter.label),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (_) =>
              ref.read(radioFilterProvider.notifier).state = filter,
          labelStyle: context.textStyles.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : context.colors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          selectedColor: context.colors.primary,
          backgroundColor: context.colors.surface,
          side: BorderSide(
            color: isSelected
                ? context.colors.primary
                : context.colors.textSecondary.withValues(alpha: 0.2),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.corners.xl),
          ),
        );
      },
    );
  }
}
