import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isFullWidth;
  final Color? customColor;
  final Color? customTextColor;

  const AppButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isFullWidth = true,
    this.customColor,
    this.customTextColor,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onTap == null || widget.isLoading;

    // Determine dimensions based on size
    double height;
    double fontSize;
    double iconSize;
    EdgeInsets padding;

    switch (widget.size) {
      case AppButtonSize.small:
        height = 32.h;
        fontSize = 11.sp;
        iconSize = 14.w;
        padding = EdgeInsets.symmetric(horizontal: 12.w);
        break;
      case AppButtonSize.medium:
        height = 46.h;
        fontSize = 14.sp;
        iconSize = 20.w;
        padding = EdgeInsets.symmetric(horizontal: 24.w);
        break;
      case AppButtonSize.large:
        height = 54.h;
        fontSize = 16.sp;
        iconSize = 22.w;
        padding = EdgeInsets.symmetric(horizontal: 32.w);
        break;
    }

    // Determine colors based on variant
    Color bgColor;
    Color textColor;
    Border? border;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bgColor = widget.customColor ?? context.colors.primary;
        textColor = widget.customTextColor ?? Colors.white;
        break;
      case AppButtonVariant.secondary:
        bgColor =
            widget.customColor ??
            context.colors.secondary.withValues(alpha: 0.1);
        textColor = widget.customTextColor ?? context.colors.secondary;
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = widget.customTextColor ?? context.colors.primary;
        border = Border.all(
          color: textColor.withValues(alpha: 0.5),
          width: 1.5,
        );
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = widget.customTextColor ?? context.colors.textSecondary;
        break;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.isFullWidth ? double.infinity : null,
          height: height,
          padding: !widget.isFullWidth ? padding : null,
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey.withValues(alpha: 0.2) : bgColor,
            borderRadius: BorderRadius.circular(context.corners.md),
            border: border,
            boxShadow:
                (widget.variant == AppButtonVariant.primary &&
                    !isDisabled &&
                    !_isPressed)
                ? [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: (height * 0.4).h,
                    width: (height * 0.4).h,
                    child: CircularProgressIndicator(
                      color: textColor,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: textColor, size: iconSize),
                        SizedBox(width: context.insets.sm),
                      ],
                      Text(
                        widget.text,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: isDisabled ? Colors.grey : textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
